import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/presentation/widget/choice_chip.dart';
import 'package:money_tracker/presentation/widget/dismiss_keyboard.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:flutter/material.dart';

typedef SaveCallback = Function(Catalog item, TransactionType type);

class AddEditCatalog extends StatefulWidget {
  final SaveCallback onSave;
  final bool isEditing;
  final Catalog? item;
  final TransactionType? type;
  const AddEditCatalog({
    Key? key,
    required this.onSave,
    required this.isEditing,
    this.item,
    this.type,
  }) : super(key: key);

  @override
  _AddEditCatalogState createState() => _AddEditCatalogState();
}

class _AddEditCatalogState extends State<AddEditCatalog> {
  String _name = "";
  late TransactionType _type;
  late String _icon;
  late List<Catalog> _iconMap;

  @override
  void initState() {
    super.initState();
    _type = widget.isEditing ? widget.type! : listTransactionType[0].type;
    _iconMap = mapIconCatalog.entries.map((e) => Catalog("", e.key)).toList();
    _icon = widget.isEditing ? widget.item!.icon : _iconMap[0].icon;
    _name = widget.isEditing ? widget.item!.name : "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => dismissKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "${widget.isEditing ? "Edit" : "Add"} category",
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_name.isEmpty) {
                  showNotify(context, "Please input category name");
                  return;
                }
                widget.onSave(Catalog(_name, _icon), _type);
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
              margin: const EdgeInsets.only(left: 20, top: 20),
              child: Text(
                "Kind of transaction?",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            MultiChoiceType(
              filterList: listTransactionType,
              initSelect: listTransactionType
                  .firstWhere((element) => element.type == _type),
              onSelectionChanged: (selected) {
                _type = selected.type;
              },
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
              child: Text(
                "Category name",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
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
          ],
        ),
      ),
    );
  }
}
