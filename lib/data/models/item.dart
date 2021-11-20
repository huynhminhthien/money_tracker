import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_tracker/core/constants/enums.dart';

import 'package:money_tracker/core/helpers/parse_data_helper.dart';

part 'item.g.dart';

// flutter packages pub run build_runner build

@HiveType(typeId: 4)
enum EVisibility {
  @HiveField(0)
  visible,
  @HiveField(1)
  hidden,
}

@HiveType(typeId: 3)
enum TransactionType {
  @HiveField(0)
  all,
  @HiveField(1)
  expense,
  @HiveField(2)
  income,
  @HiveField(3)
  transfer,
}

class TransactionTypePackage extends Equatable {
  final TransactionType type;
  final IconData icon;
  final Color color;
  const TransactionTypePackage(
    this.type,
    this.icon,
    this.color,
  );

  String getName() {
    return type.toShortString();
  }

  @override
  List<Object?> get props => [type, icon, color];
}

@HiveType(typeId: 2)
class Catalog extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String icon;
  const Catalog(this.name, this.icon);

  @override
  List<Object?> get props => [name, icon];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
    };
  }

  factory Catalog.fromJson(Map<String, dynamic> map) {
    return Catalog(
      map['name'],
      map['icon'],
    );
  }
}

@HiveType(typeId: 1)
class Account extends Equatable {
  @HiveField(0)
  final String icon;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int overBalance;
  @HiveField(3)
  final EVisibility visibility;
  const Account(this.icon, this.name, this.overBalance, this.visibility);

  Account copyWith(
      {String? icon, String? name, int? overBalance, EVisibility? visibility}) {
    return Account(
      icon ?? this.icon,
      name ?? this.name,
      overBalance ?? this.overBalance,
      visibility ?? this.visibility,
    );
  }

  @override
  String toString() {
    return "name: $name, over balance: $overBalance, visibility: ${visibility.toShortString()}";
  }

  @override
  List<Object?> get props => [name, icon, overBalance, visibility];

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'name': name,
      'overBalance': overBalance,
      'visibility': visibility.toShortString(),
    };
  }

  factory Account.fromJson(Map<String, dynamic> map) {
    return Account(
      map['icon'],
      map['name'],
      map['overBalance'],
      "${map['visibility']}".toEnumVisibility(),
    );
  }
}

@HiveType(typeId: 0)
class TransactionItem extends Equatable {
  @HiveField(0)
  final TransactionType type;
  @HiveField(1)
  final Catalog catalog;
  @HiveField(2)
  final Account? fromAccount;
  @HiveField(3)
  final Account? toAccount;
  @HiveField(4)
  final int amount;
  @HiveField(5)
  final String note;
  @HiveField(6)
  final String date;
  @HiveField(7)
  final String? image;
  @HiveField(8)
  final int? key;

  const TransactionItem(
      this.type, this.catalog, this.amount, this.note, this.date,
      {this.fromAccount, this.toAccount, this.image, this.key});

  TransactionItem copyWith({
    TransactionType? type,
    Catalog? catalog,
    Account? fromAccount,
    Account? toAccount,
    int? amount,
    String? note,
    String? date,
    String? image,
    int? key,
  }) {
    return TransactionItem(
      type ?? this.type,
      catalog ?? this.catalog,
      amount ?? this.amount,
      note ?? this.note,
      date ?? this.date,
      image: image ?? this.image,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      key: key ?? this.key,
    );
  }

  @override
  String toString() {
    String data = "\n";
    data += "========== TransactionItem ==========\n";
    data += "key: $key\n";
    data += "name: ${catalog.name} \n";
    data += "traction type: $type \n";
    if (fromAccount != null) data += "from account: ${fromAccount!.name} \n";
    if (toAccount != null) data += "to account: ${toAccount!.name} \n";
    data += "date: $date \n";
    data += "amount: $amount \n";
    data += "note: $note \n";
    data += "base64 from image: $image \n";
    data += "=====================================\n";

    return data;
  }

  @override
  List<Object?> get props =>
      [type, catalog, fromAccount, toAccount, amount, note, date, image];

  Map<String, dynamic> toJson() {
    return {
      'type': type.toShortString(),
      'catalog': catalog.toJson(),
      'fromAccount': fromAccount?.toJson(),
      'toAccount': toAccount?.toJson(),
      'amount': amount,
      'note': note,
      'date': date,
      'image': image,
      'key': key,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> map) {
    return TransactionItem(
      "${map['type']}".toEnumType(),
      Catalog.fromJson(map['catalog']),
      map['amount'],
      map['note'],
      map['date'],
      image: map['image'],
      fromAccount: map['fromAccount'] != null
          ? Account.fromJson(map['fromAccount'])
          : null,
      toAccount:
          map['toAccount'] != null ? Account.fromJson(map['toAccount']) : null,
      key: map['key'],
    );
  }
}

class CatalogPercentage extends Equatable {
  final Catalog catalog;

  ///Percent value between 0.0 and 1.0
  final double percentage;
  final int amount;
  final List<TransactionItem> transactions;

  const CatalogPercentage({
    required this.catalog,
    required this.percentage,
    required this.amount,
    required this.transactions,
  });

  @override
  List<Object?> get props => [catalog, percentage, amount, transactions];
}

class Result {
  final ReturnCode rc;
  final String message;

  const Result(this.rc, [this.message = ""]);
}
