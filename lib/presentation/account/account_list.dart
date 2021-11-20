import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/logic/cubit/account_cubit.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:money_tracker/presentation/widget/in_progress.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

import 'account_item.dart';

class AccountList extends StatefulWidget {
  const AccountList({Key? key}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocConsumer<AccountCubit, AccountState>(
        listenWhen: (previous, current) => current.failureMessage.isNotEmpty,
        listener: (context, state) {
          if (state.status == StateStatus.failure &&
              state.failureMessage.isNotEmpty) {
            showNotify(context, state.failureMessage);
            BlocProvider.of<AccountCubit>(context).cleanFailureMessage();
          }
        },
        buildWhen: (previous, current) =>
            previous.items != current.items ||
            previous.status != current.status,
        builder: (context, state) {
          if (state.status == StateStatus.initial) {
            return const InProgress();
          } else {
            return SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.addAccount);
                    },
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10.0),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesome5.plus,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Add",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return AccountListItem(
                        item: state.items[index],
                      );
                    },
                    itemCount: state.items.length,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
