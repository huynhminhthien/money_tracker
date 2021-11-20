import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/logic/cubit/transaction_cubit.dart';
import 'package:money_tracker/presentation/transactions/transaction_list.dart';
import 'package:money_tracker/presentation/widget/choice_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionView extends StatelessWidget {
  const TransactionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> filterList = [
      TransactionType.all.toShortString(),
      TransactionType.expense.toShortString(),
      TransactionType.income.toShortString(),
      TransactionType.transfer.toShortString()
    ];
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Transactions",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    "Show",
                    style: Theme.of(context).textTheme.overline,
                  ),
                ),
                Expanded(
                  child: BlocBuilder<TransactionCubit, TransactionState>(
                    buildWhen: (previous, current) =>
                        previous.filters[FilterKey.transaction] !=
                        current.filters[FilterKey.transaction],
                    builder: (context, state) {
                      return MultiChoiceChip(
                        filterList: filterList,
                        initSelect:
                            state.filters[FilterKey.transaction]!.capitalize(),
                        onSelectionChanged: (selected) {
                          BlocProvider.of<TransactionCubit>(context)
                              .filteringTransactions(
                                  {FilterKey.transaction: selected});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: TransactionList(),
          ),
        ],
      ),
    );
  }
}
