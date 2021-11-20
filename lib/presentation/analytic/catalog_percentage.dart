import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker/core/themes/app_theme.dart';
import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/logic/cubit/analysis_cubit.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CatalogPercentageList extends StatelessWidget {
  const CatalogPercentageList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisCubit, AnalysisState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            BlocProvider.of<AnalysisCubit>(context).processing();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: state.catalogPercentages.length,
            itemBuilder: (context, index) {
              return CatalogPercentageItem(
                item: state.catalogPercentages[index],
                type: state.transactionType,
              );
            },
          ),
        );
      },
    );
  }
}

class CatalogPercentageItem extends StatelessWidget {
  const CatalogPercentageItem(
      {Key? key, required this.item, required this.type})
      : super(key: key);
  final CatalogPercentage item;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.transactionOfCatalog,
          arguments: item.transactions),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        height: 90,
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
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 12,
              decoration: BoxDecoration(
                color: type == TransactionType.income
                    ? Theme.of(context).greenColor
                    : Theme.of(context).redColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(100.0),
                  topRight: Radius.circular(100.0),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: RadiantGradientMask(
                    child: Icon(
                      item.catalog.icon.toIconData(),
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.catalog.name,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              "${(item.percentage * 100).toStringAsFixed(1)} %",
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item.transactions.length} transaction",
                              maxLines: 3,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              (type == TransactionType.income ? "+" : "-") +
                                  item.amount.asMoneyDisplay(),
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: LinearPercentIndicator(
                          lineHeight: 7.0,
                          percent: item.percentage,
                          backgroundColor: Colors.grey,
                          linearGradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Color(item.percentage * 100 > 5
                                  ? 0xFFAA76FF
                                  : 0xFF4400D5),
                              const Color(0xFF4400D5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
