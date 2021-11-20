import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/logic/cubit/item_cubit.dart';
import 'package:money_tracker/logic/cubit/transaction_cubit.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:money_tracker/core/themes/app_theme.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem(
      {Key? key, required this.item, required this.disableEdit})
      : super(key: key);
  final TransactionItem item;
  final bool disableEdit;

  @override
  Widget build(BuildContext context) {
    if (disableEdit) {
      return GestureDetector(
        onTap: () => onTapGesture(context),
        child: itemWidget(context),
      );
    } else {
      return Slidable(
        actionPane: const SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: [
          IconSlideAction(
            caption: 'Edit',
            color: Theme.of(context).greenColor,
            icon: Icons.edit,
            onTap: () {
              BlocProvider.of<ItemCubit>(context)
                  .updateTransactionType(item.type);
              Navigator.pushNamed(
                context,
                AppRouter.editItem,
                arguments: item,
              );
            },
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Theme.of(context).redColor,
            icon: Icons.delete,
            onTap: () async {
              await showWarningMessage(
                context: context,
                message: "This item will be removed if you accept",
                onAccept: () {
                  BlocProvider.of<TransactionCubit>(context)
                      .removeItemOfTransaction(item);
                },
              );
            },
          ),
        ],
        child: GestureDetector(
          onTap: () => onTapGesture(context),
          child: itemWidget(context),
        ),
      );
    }
  }

  void onTapGesture(BuildContext context) {
    if (item.image!.isNotEmpty) {
      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            backgroundColor: Colors.black87,
          ),
          body: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: base64String2Image(item.image!),
            ),
          ),
        ),
      );
    }
  }

  Container itemWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      height: 90,
      // width: MediaQuery.of(context).size.width * 0.87,
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
              color: item.type == TransactionType.income
                  ? Theme.of(context).greenColor
                  : item.type == TransactionType.expense
                      ? Theme.of(context).redColor
                      : Colors.grey,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(100.0),
                topRight: Radius.circular(100.0),
              ),
            ),
          ),
          if (item.image!.isNotEmpty)
            Positioned(
              top: 15,
              right: 25,
              child: CustomPaint(
                painter: PointPainter(Theme.of(context).primaryColor, 6),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.catalog.name,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        item.note,
                        maxLines: 3,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (item.type == TransactionType.income
                                ? "+"
                                : item.type == TransactionType.expense
                                    ? "-"
                                    : "") +
                            item.amount.asMoneyDisplay(),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          (item.type != TransactionType.income
                                  ? item.fromAccount!.name
                                  : "") +
                              (item.type == TransactionType.transfer
                                  ? " - "
                                  : "") +
                              (item.type != TransactionType.expense
                                  ? item.toAccount!.name
                                  : ""),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
