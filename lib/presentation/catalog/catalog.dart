import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/logic/cubit/catalog_cubit.dart';
import 'package:money_tracker/logic/cubit/transaction_cubit.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:money_tracker/presentation/widget/choice_chip.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/entypo_icons.dart';

import 'catalog_item.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> filterList = [
      TransactionType.expense.toShortString(),
      TransactionType.income.toShortString(),
      TransactionType.transfer.toShortString()
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Categorise",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Entypo.plus,
            ),
            onPressed: () => Navigator.pushNamed(context, AppRouter.addCatalog),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Text(
              "Kind of categorise?",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          BlocConsumer<CatalogCubit, CatalogState>(
            listener: (context, state) {
              if (state.status == StateStatus.failure &&
                  state.failureMessage.isNotEmpty) {
                showNotify(context, state.failureMessage);
                BlocProvider.of<CatalogCubit>(context).clearFailureMessage();
              } else if (state.status == StateStatus.success) {
                BlocProvider.of<TransactionCubit>(context)
                    .filteringTransactions();
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      MultiChoiceChip(
                        filterList: filterList,
                        initSelect: filterList[state.type.index - 1],
                        onSelectionChanged: (selected) {
                          BlocProvider.of<CatalogCubit>(context)
                              .getAllCatalogOfType(selected.toEnumType());
                        },
                      ),
                    ],
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<CatalogCubit>(context)
                          .getAllCatalogOfType(state.type);
                    },
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) => CatalogItem(
                        item: state.items[index],
                        type: state.type,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
