import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/core/themes/app_theme.dart';
import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/logic/cubit/analysis_cubit.dart';
import 'package:money_tracker/presentation/analytic/catalog_percentage.dart';
import 'package:money_tracker/presentation/widget/choice_chip.dart';

class AnalyticTab extends StatelessWidget {
  const AnalyticTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(
            height: 40,
          ),
          SelectorAnalytic(),
          TotalAmountView(),
          Expanded(child: CategoryAnalyticView()),
        ],
      ),
    );
  }
}

class TotalAmountView extends StatelessWidget {
  const TotalAmountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: BlocBuilder<AnalysisCubit, AnalysisState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (state.totalIncome - state.totalExpense)
                    .asMoneyDisplay(showSign: true),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline6,
              ),
              const Divider(
                indent: 20,
                endIndent: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AmountView(
                    type: TransactionType.expense,
                    amount: state.totalExpense,
                  ),
                  AmountView(
                    type: TransactionType.income,
                    amount: state.totalIncome,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class AmountView extends StatelessWidget {
  const AmountView({Key? key, required this.type, required this.amount})
      : super(key: key);
  final TransactionType type;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          type.toShortString(),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Row(
          children: [
            CustomPaint(
              painter: PointPainter(
                type == TransactionType.income
                    ? Theme.of(context).greenColor
                    : Theme.of(context).redColor,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              amount.asMoneyDisplay(),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ],
    );
  }
}

class SelectorAnalytic extends StatelessWidget {
  const SelectorAnalytic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> dateType = [
      DateType.month.toShortString(),
      DateType.year.toShortString(),
    ];
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Analytic",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline5,
          ),
          Row(
            children: [
              DropDownButtonCustom(
                items: dateType,
                onChanged: (value) {
                  BlocProvider.of<AnalysisCubit>(context).processing(
                    dateType: value.toEnumDateType(),
                  );
                },
                initValue: dateType[0],
              ),
              BlocBuilder<AnalysisCubit, AnalysisState>(
                builder: (context, state) {
                  return MultiChoiceChip(
                    filterList: state.dateList,
                    initSelect: state.dateSelected,
                    isHorizontalScroll: false,
                    onSelectionChanged: (selected) {
                      BlocProvider.of<AnalysisCubit>(context)
                          .processing(dateSelected: selected);
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DropDownButtonCustom extends StatefulWidget {
  const DropDownButtonCustom(
      {Key? key, required this.onChanged, required this.items, this.initValue})
      : super(key: key);
  final void Function(String) onChanged;
  final List<String> items;
  final String? initValue;

  @override
  _DropDownButtonCustomState createState() => _DropDownButtonCustomState();
}

class _DropDownButtonCustomState extends State<DropDownButtonCustom> {
  late String _value;

  @override
  void initState() {
    if (widget.initValue != null) {
      _value = widget.initValue!;
    } else {
      _value = widget.items.isNotEmpty ? widget.items[0] : "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: _value,
      items: widget.items.map((item) {
        return DropdownMenuItem<String>(
          child: Text(
            item,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          value: item,
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _value = value!;
        });
        widget.onChanged(_value);
      },
    );
  }
}

class CategoryAnalyticView extends StatelessWidget {
  const CategoryAnalyticView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, top: 10),
          child: Text(
            "Categories",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        const Expanded(child: CatalogPercentageList())
      ],
    );
  }
}
