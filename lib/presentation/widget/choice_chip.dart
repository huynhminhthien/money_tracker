import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MultiChoiceChip extends StatefulWidget {
  const MultiChoiceChip({
    Key? key,
    required this.filterList,
    required this.onSelectionChanged,
    required this.initSelect,
    this.isHorizontalScroll = true,
  }) : super(key: key);

  final List<String> filterList;
  final Function(String) onSelectionChanged;
  final String initSelect;
  final bool isHorizontalScroll;

  @override
  _MultiChoiceChipState createState() => _MultiChoiceChipState();
}

class _MultiChoiceChipState extends State<MultiChoiceChip> {
  String selectedChoice = "";
  bool isInitalized = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontalScroll) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildChoiceList(),
        ),
      );
    }
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      children: _buildChoiceList(),
    );
  }

  _buildChoiceList() {
    List<Widget> choices = [];
    for (var item in widget.filterList) {
      choices.add(
        CustomChoice(
          text: item,
          isSelected: selectedChoice == item ||
              (widget.initSelect == item && !isInitalized),
          onTap: () {
            setState(() {
              selectedChoice = item;
              isInitalized = true;
              widget.onSelectionChanged(selectedChoice);
            });
          },
        ),
      );
    }
    return choices;
  }
}

class CustomChoice extends StatelessWidget {
  const CustomChoice({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                if (isSelected) const Color(0xFFAA76FF),
                if (isSelected) const Color(0xFF4400D5),
                if (!isSelected) Colors.grey,
                if (!isSelected) Colors.grey,
              ],
              tileMode: TileMode.repeated,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .overline!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class MultiChoiceCatalog extends StatefulWidget {
  const MultiChoiceCatalog({
    Key? key,
    required this.filterList,
    required this.onSelectionChanged,
    required this.initSelect,
    this.isHorizontalScroll = true,
  }) : super(key: key);

  final List<Catalog> filterList;
  final Function(Catalog) onSelectionChanged;
  final Catalog initSelect;
  final bool isHorizontalScroll;

  @override
  _MultiChoiceCatalogState createState() => _MultiChoiceCatalogState();
}

class _MultiChoiceCatalogState extends State<MultiChoiceCatalog> {
  dynamic selectedChoice;
  bool initialized = false;
  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontalScroll) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 10),
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildChoiceList(),
        ),
      );
    }
    return Wrap(
      children: _buildChoiceList(),
    );
  }

  _buildChoiceList() {
    List<Widget> choices = [];
    for (var item in widget.filterList) {
      choices.add(
        ChoiceCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RadiantGradientMask(
                child: Icon(
                  item.icon.toIconData(),
                  size: 35,
                  color: Colors.white,
                ),
              ),
              if (item.name.isNotEmpty)
                const SizedBox(
                  height: 5,
                ),
              if (item.name.isNotEmpty)
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          isSelected: selectedChoice == item ||
              (widget.initSelect == item && !initialized),
          onTap: () {
            setState(() {
              selectedChoice = item;
              initialized = true;
              widget.onSelectionChanged(selectedChoice);
            });
          },
        ),
      );
    }
    return choices;
  }
}

class MultiChoiceType extends StatefulWidget {
  const MultiChoiceType({
    Key? key,
    required this.filterList,
    required this.onSelectionChanged,
    required this.initSelect,
  }) : super(key: key);

  final List<TransactionTypePackage> filterList;
  final Function(TransactionTypePackage) onSelectionChanged;
  final TransactionTypePackage initSelect;
  @override
  _MultiChoiceTypeState createState() => _MultiChoiceTypeState();
}

class _MultiChoiceTypeState extends State<MultiChoiceType> {
  dynamic selectedChoice;
  bool initialized = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 10),
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _buildChoiceList(),
      ),
    );
  }

  _buildChoiceList() {
    List<Widget> choices = [];
    for (var item in widget.filterList) {
      choices.add(
        ChoiceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: item.color,
                size: 35,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                item.getName(),
                style: Theme.of(context).textTheme.subtitle2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          isSelected: selectedChoice == item ||
              (widget.initSelect == item && !initialized),
          onTap: () {
            setState(() {
              selectedChoice = item;
              initialized = true;
              widget.onSelectionChanged(selectedChoice);
            });
          },
        ),
      );
    }
    return choices;
  }
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.child,
  }) : super(key: key);
  final bool isSelected;
  final Widget child;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        width: 90,
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).selectedRowColor
                : Colors.transparent,
            width: 2,
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
        child: child,
      ),
    );
  }
}
