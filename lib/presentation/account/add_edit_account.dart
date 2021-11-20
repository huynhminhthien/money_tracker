import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/presentation/widget/choice_chip.dart';
import 'package:money_tracker/presentation/widget/dismiss_keyboard.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';

typedef SaveCallback = Function(Account item);

class AddEditAccount extends StatefulWidget {
  final SaveCallback onSave;
  final bool isEditing;
  final Account? item;
  const AddEditAccount({
    Key? key,
    required this.onSave,
    required this.isEditing,
    this.item,
  }) : super(key: key);

  @override
  _AddEditAccountState createState() => _AddEditAccountState();
}

class _AddEditAccountState extends State<AddEditAccount> {
  String _name = "";
  int _starterAmount = 0;
  late EVisibility _visibility;
  late String _icon;
  late List<Catalog> _iconMap;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _iconMap = mapIconAccount.entries.map((e) => Catalog("", e.key)).toList();
    _icon = widget.isEditing ? widget.item!.icon : _iconMap[0].icon;
    _name = widget.isEditing ? widget.item!.name : "";
    _visibility =
        widget.isEditing ? widget.item!.visibility : EVisibility.visible;
    _starterAmount = widget.isEditing ? widget.item!.overBalance : 0;
    _controller.text = widget.isEditing
        ? widget.item!.overBalance.asMoneyDisplay(unit: '')
        : "";
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
          centerTitle: true,
          title: Text(
            "${widget.isEditing ? "Edit" : "Add"} account",
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_name.isEmpty) {
                  showNotify(context, "Please input Name");
                  return;
                }
                widget.onSave(
                  Account(
                    _icon,
                    _name,
                    _starterAmount,
                    _visibility,
                  ),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(
              width: 10,
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
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
        body: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                "Starter amount",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _controller,
                onChanged: (text) {
                  _starterAmount = text.isNotEmpty ? int.parse(text) : 0;
                  final amount = formatString(text, unit: '');
                  _controller.value = TextEditingValue(
                    text: amount,
                    selection: TextSelection.collapsed(offset: amount.length),
                  );
                },
                decoration: const InputDecoration(
                  hintText: "1000000",
                  prefixIcon: Icon(FontAwesome.dollar),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                "Category name",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                initialValue: widget.isEditing ? widget.item!.name : "",
                onChanged: (text) {
                  _name = text;
                },
                decoration: const InputDecoration(
                  hintText: "Enter category name",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItems: true,
                items: [
                  EVisibility.visible.toShortString(),
                  EVisibility.hidden.toShortString(),
                ],
                dropdownSearchDecoration: const InputDecoration(
                  labelText: "Visibility",
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value != null) _visibility = value.toEnumVisibility();
                },
                selectedItem: _visibility.toShortString(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, top: 20),
              child: Text(
                "Icon",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Center(
              child: MultiChoiceCatalog(
                filterList: _iconMap,
                onSelectionChanged: (item) {
                  _icon = item.icon;
                },
                initSelect: Catalog("", _icon),
                isHorizontalScroll: false,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
