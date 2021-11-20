import 'package:flutter/material.dart';

import 'account_list.dart';

class AccountView extends StatelessWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 15, top: 5),
          child: Text(
            "Accounts",
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        const AccountList(),
      ],
    );
  }
}
