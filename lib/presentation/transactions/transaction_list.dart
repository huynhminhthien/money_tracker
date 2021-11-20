import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/logic/cubit/account_cubit.dart';
import 'package:money_tracker/logic/cubit/analysis_cubit.dart';
import 'package:money_tracker/logic/cubit/transaction_cubit.dart';
import 'package:money_tracker/presentation/transactions/transaction_item.dart';
import 'package:money_tracker/presentation/widget/in_progress.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocConsumer<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state.status == StateStatus.success) {
            BlocProvider.of<AccountCubit>(context).getAccounts();
            BlocProvider.of<AnalysisCubit>(context).processing();
          } else if (state.status == StateStatus.failure &&
              state.failureMessage.isNotEmpty) {
            showNotify(context, state.failureMessage);
          }
        },
        buildWhen: (previous, current) =>
            previous.items != current.items ||
            previous.status != current.status,
        builder: (context, state) {
          if (state.status == StateStatus.initial) {
            return const InProgress();
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 200));
                BlocProvider.of<TransactionCubit>(context)
                    .filteringTransactions();
              },
              child: GroupedList(items: state.items),
            );
          }
        },
      ),
    );
  }
}

class GroupedList extends StatelessWidget {
  const GroupedList({Key? key, required this.items, this.disableEdit = false})
      : super(key: key);
  final List<TransactionItem> items;
  final bool disableEdit;
  @override
  Widget build(BuildContext context) {
    return GroupedListView<dynamic, String>(
      controller: BlocProvider.of<TransactionCubit>(context).scrollController,
      elements: items,
      order: GroupedListOrder.DESC,
      useStickyGroupSeparators: true,
      stickyHeaderBackgroundColor: Colors.transparent,
      physics: const AlwaysScrollableScrollPhysics(),
      groupBy: (element) => element.date,
      groupComparator: (value1, value2) => _compareDateTime(value1, value2),
      itemComparator: (element1, element2) =>
          element1.key.compareTo(element2.key),
      groupSeparatorBuilder: (String dateTime) => Container(
        padding: const EdgeInsets.only(left: 30.0, top: 10.0),
        child: Text(
          dateTime.refomartDataTime(),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      itemBuilder: (context, element) =>
          TransactionListItem(item: element, disableEdit: disableEdit),
    );
  }

  int _compareDateTime(String date1, String date2) =>
      date1.parseToDateTime().compareTo(date2.parseToDateTime());
}
