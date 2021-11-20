import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/logic/cubit/account_cubit.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class AccountListItem extends StatelessWidget {
  const AccountListItem({Key? key, required this.item}) : super(key: key);
  final Account item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Wrap(
              children: [
                ListTile(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRouter.editAccount,
                      arguments: item,
                    );
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.edit),
                  title: Text('Edit ${item.name}'),
                ),
                ListTile(
                  onTap: () async {
                    await showWarningMessage(
                      context: context,
                      message:
                          "${item.name} account will be removed if you accept",
                      onAccept: () {
                        BlocProvider.of<AccountCubit>(context)
                            .deleteAccount(item);
                      },
                    );
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.delete),
                  title: Text('Delete ${item.name}'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(10),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 80,
              child: RadiantGradientMask(
                child: Icon(
                  item.icon.toIconData(),
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              item.overBalance.asMoneyDisplay(showSign: true),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              item.name,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }
}
