import 'dart:io';

import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/logic/cubit/item_cubit.dart';
import 'package:money_tracker/logic/debug/logger.dart';
import 'package:money_tracker/presentation/transactions/calculator.dart';
import 'package:money_tracker/presentation/widget/choice_chip.dart';
import 'package:money_tracker/presentation/widget/dismiss_keyboard.dart';
import 'package:money_tracker/presentation/widget/in_progress.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:image_picker/image_picker.dart';

typedef SaveCallback = Function(TransactionItem item);

class AddEditItem extends StatefulWidget {
  final SaveCallback onSave;
  final bool isEditing;
  final TransactionItem? item;
  const AddEditItem({
    Key? key,
    required this.onSave,
    required this.isEditing,
    this.item,
  }) : super(key: key);

  @override
  _AddEditItemState createState() => _AddEditItemState();
}

class _AddEditItemState extends State<AddEditItem> {
  TransactionType? _type;
  Catalog? _catalog;
  Account? _from;
  Account? _to;
  String _note = "";
  int _amount = 0;
  late DateTime _date;
  bool _initialized = false;

  final ImagePicker _picker = ImagePicker();
  String _base64Image = "";
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _controller.text =
        widget.isEditing ? widget.item!.amount.asMoneyDisplay(unit: '') : "";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => dismissKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          elevation: 5,
          centerTitle: true,
          title: Text(
            "${widget.isEditing ? "Edit" : "Add"} transaction",
          ),
          actions: [
            IconButton(
              onPressed: () => _onSubmit(context),
              icon: const Icon(Icons.check),
            ),
            const SizedBox(
              width: 10,
            )
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              // borderRadius: BorderRadius.only(
              //   bottomLeft: Radius.circular(20),
              //   bottomRight: Radius.circular(20),
              // ),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFAA76FF),
                  Color(0xFF4400D5),
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<ItemCubit, ItemState>(
          builder: (context, state) {
            switch (state.status) {
              case StateStatus.success:
                if (!_initialized) {
                  if (widget.isEditing) {
                    _type = widget.item!.type;
                    _catalog = widget.item!.catalog;
                    _from = widget.item!.fromAccount;
                    _to = widget.item!.toAccount;
                    _amount = widget.item!.amount;
                    _note = widget.item!.note;
                    _date = widget.item!.date.parseToDateTime();
                    _base64Image = widget.item!.image!;
                  } else {
                    _type = state.type;
                    _catalog = state.catalogs[0];
                    _from = state.fromAccounts[0];
                    _to = state.toAccounts[0];
                  }
                  _initialized = true;
                }
                return ListView(
                  children: _getChildren(state),
                );
              case StateStatus.failure:
                return Center(
                  child: Text(
                    "Account and category does not exists",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                );
              default:
                return const InProgress();
            }
          },
        ),
      ),
    );
  }

  List<Widget> _getChildren(ItemState state) => [
        Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child: Text(
            "Kind of transaction?",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        MultiChoiceType(
          filterList: state.types,
          initSelect: widget.isEditing
              ? state.types
                  .firstWhere((element) => element.type == widget.item!.type)
              : state.types[0],
          onSelectionChanged: (selected) {
            if (_type != selected.type) _initialized = false;
            _type = selected.type;
            BlocProvider.of<ItemCubit>(context)
                .updateTransactionType(selected.type);
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          margin: const EdgeInsets.only(left: 20),
          child: Text(
            "Choose category",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        MultiChoiceCatalog(
          filterList: state.catalogs,
          initSelect: _catalog!,
          onSelectionChanged: (catalog) {
            _catalog = catalog;
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Text(
                  "Account",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Row(
                children: [
                  if (_type != TransactionType.income)
                    Expanded(
                      child: DropdownSearch<Account>(
                        mode: Mode.BOTTOM_SHEET,
                        showSelectedItems: true,
                        items: state.fromAccounts,
                        dropdownSearchDecoration: const InputDecoration(
                          labelText: "From Accout",
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (from) {
                          _from = from;
                        },
                        selectedItem: _from,
                        compareFn: (item, selectedItem) =>
                            _compareFnDropSearch(item, selectedItem),
                        dropdownBuilder: _customdropdownBuilderAccount,
                        popupItemBuilder: _customPopupItemBuilderAccount,
                      ),
                    ),
                  if (_type == TransactionType.transfer)
                    const SizedBox(
                      width: 10,
                    ),
                  if (_type != TransactionType.expense)
                    Expanded(
                      child: DropdownSearch<Account>(
                        mode: Mode.BOTTOM_SHEET,
                        showSelectedItems: true,
                        items: state.toAccounts,
                        dropdownSearchDecoration: const InputDecoration(
                          labelText: "To Accout",
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (to) {
                          _to = to;
                        },
                        selectedItem: _to,
                        compareFn: (item, selectedItem) =>
                            _compareFnDropSearch(item, selectedItem),
                        dropdownBuilder: _customdropdownBuilderAccount,
                        popupItemBuilder: _customPopupItemBuilderAccount,
                      ),
                    ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                child: Text(
                  "Amount",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _controller,
                        onChanged: (text) {
                          _amount = text.isNotEmpty ? int.parse(text) : 0;
                          final amount = formatString(text, unit: '');
                          _controller.value = TextEditingValue(
                            text: amount,
                            selection:
                                TextSelection.collapsed(offset: amount.length),
                          );
                        },
                        decoration: const InputDecoration(
                          hintText: "Input",
                          prefixIcon: Icon(FontAwesome.dollar),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Wrap(
                              children: [
                                Calculator(
                                  callback: (value) {
                                    _amount = value;
                                    _controller.text =
                                        value.asMoneyDisplay(unit: '');
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFFAA76FF),
                            Color(0xFF4400D5),
                          ],
                          tileMode: TileMode.repeated,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(10, 0, 0, 0),
                            blurRadius: 4.0,
                            spreadRadius: 0.0,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Icon(
                        Typicons.calculator,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                child: Text(
                  "Notes",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        initialValue: widget.isEditing ? widget.item!.note : "",
                        // maxLines: 3,
                        onChanged: (text) {
                          _note = text;
                        },
                        decoration: const InputDecoration(
                          hintText: "Comments",
                          // border: OutlineInputBorder(),
                          // labelText: 'Note',
                        ),
                      ),
                    ),
                  ),
                  loadImageButton(),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: _date.subtract(const Duration(days: 100)),
                    lastDate: _date.add(const Duration(days: 100)),
                    helpText: 'Select a date',
                  );
                  setState(() {
                    if (newDate != null) _date = newDate;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 115,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFAA76FF),
                        Color(0xFF4400D5),
                      ],
                      tileMode: TileMode.repeated,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(10, 0, 0, 0),
                        blurRadius: 4.0,
                        spreadRadius: 0.0,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _date.isCurrentDate() ? "TODAY" : _date.dayOfWeek,
                        style: Theme.of(context).textTheme.headline3!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _date.parseAsDisplay(),
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              if (_base64Image.isNotEmpty) base64String2Image(_base64Image),
            ],
          ),
        ),
      ];

  GestureDetector loadImageButton() {
    return GestureDetector(
      onTap: () => _handleLoadImage(context),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFAA76FF),
              Color(0xFF4400D5),
            ],
            tileMode: TileMode.repeated,
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(10, 0, 0, 0),
              blurRadius: 4.0,
              spreadRadius: 0.0,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: const Icon(
          FontAwesome.picture,
          color: Colors.white,
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_type != null && _catalog != null) {
      switch (_type) {
        case TransactionType.transfer:
          if (_from == null || _to == null || _from == _to || _amount == 0) {
            showNotify(context, "Invalid input transfer");
            return;
          }
          break;
        case TransactionType.income:
          if (_to == null) {
            showNotify(context, "Invalid input income");
            return;
          }
          break;
        case TransactionType.expense:
          if (_from == null) {
            showNotify(context, "Invalid input expense");
            return;
          }
          break;
        default:
      }

      widget.onSave(
        TransactionItem(
          _type!,
          _catalog!,
          _amount,
          _note,
          _date.parseAsString(),
          toAccount: _type != TransactionType.expense ? _to : null,
          fromAccount: _type != TransactionType.income ? _from : null,
          image: _base64Image,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<dynamic> _handleLoadImage(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              onTap: () {
                _onImageButtonPressed(ImageSource.camera);
                Navigator.pop(context);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
            ),
            ListTile(
              onTap: () {
                _onImageButtonPressed(ImageSource.gallery);
                Navigator.pop(context);
              },
              leading: const Icon(Icons.photo),
              title: const Text('Pick Image from gallery'),
            ),
            if (_base64Image.isNotEmpty)
              ListTile(
                onTap: () {
                  setState(() {
                    _base64Image = "";
                  });
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.photo),
                title: const Text('Delete current image'),
              ),
          ],
        );
      },
    );
  }

  void _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
      );
      setState(() {
        if (pickedFile != null) {
          _base64Image = image2Base64String(pickedFile.path);
          File(pickedFile.path).deleteSync();
        }
      });
    } catch (e) {
      logger.e("_onImageButtonPressed fail: $e");
    }
  }

  Widget _customdropdownBuilderAccount(
    BuildContext context,
    Account? item,
  ) {
    if (item!.name.isEmpty) {
      return Container();
    }
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: RadiantGradientMask(
        child: Icon(
          item.icon.toIconData(),
          size: 35,
          color: Colors.white,
        ),
      ),
      title: Text(item.name),
    );
  }

  Widget _customPopupItemBuilderAccount(
    BuildContext context,
    Account item,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Text(item.name),
        leading: RadiantGradientMask(
          child: Icon(
            item.icon.toIconData(),
            size: 35,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _compareFnDropSearch<T>(T item, T? selectedItem) {
    return item == selectedItem;
  }
}
