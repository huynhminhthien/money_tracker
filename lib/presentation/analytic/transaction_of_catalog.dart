import 'package:flutter/material.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/presentation/transactions/transaction_list.dart';

class TransactionOfCatalog extends StatelessWidget {
  const TransactionOfCatalog({Key? key, required this.items}) : super(key: key);
  final List<TransactionItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(items[0].catalog.name),
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
      body: GroupedList(
        items: items,
        disableEdit: true,
      ),
    );
  }
}
