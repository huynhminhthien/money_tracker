import 'dart:developer';

import 'package:hive/hive.dart';

import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/logic/debug/logger.dart';

class DataProvider {
  int _lastKeyTransaction = 0;

  DataProvider() {
    final items = Hive.box<TransactionItem>(Strings.transactionBox);
    if (items.isEmpty) return;
    _lastKeyTransaction = items.toMap().cast().entries.last.key;
  }

  void adaptChangeNotify() {
    final notify = Hive.box(Strings.settingBox).get(SettingKey.notification);
    if (notify is bool) {
      Hive.box(Strings.settingBox).delete(SettingKey.notification);
      Hive.box(Strings.settingBox).put(SettingKey.notification, "");
    }
  }

  bool isFisrtStarting() =>
      Hive.box(Strings.settingBox).get(SettingKey.init) == null;

  void set2Initialized() =>
      Hive.box(Strings.settingBox).put(SettingKey.init, 'yes');

  void writeSetting(String key, dynamic value) =>
      Hive.box(Strings.settingBox).put(key, value);

  dynamic readSetting(String key) {
    final valueKey = Hive.box(Strings.settingBox).get(key);
    if (valueKey == null) {
      final defaultValue = key != SettingKey.notification ? false : "";
      writeSetting(key, defaultValue);
      return defaultValue;
    }
    return valueKey;
  }

  void addCatalog(TransactionType type, Catalog items) {
    Hive.box<Catalog>(Strings.catalogBox)
        .put('${items.name}.${type.toShortString()}', items);
  }

  List<Catalog> getAllCatalog(TransactionType type) {
    if (type == TransactionType.all) {
      return Hive.box<Catalog>(Strings.catalogBox).values.toList();
    }
    Map<String, Catalog> items =
        Hive.box<Catalog>(Strings.catalogBox).toMap().cast();
    items.removeWhere((key, value) => !key.contains(type.toShortString()));
    return items.entries.map((e) => e.value).toList();
  }

  bool isExistedCatalog(Catalog item) {
    bool isExists = false;
    List<TransactionType> types = [
      TransactionType.expense,
      TransactionType.income,
      TransactionType.transfer
    ];
    for (var type in types) {
      final key = '${item.name}.${type.toShortString()}';
      isExists = Hive.box<Catalog>(Strings.catalogBox).containsKey(key) &&
          Hive.box<Catalog>(Strings.catalogBox).get(key) == item;
      if (isExists) break;
    }
    return isExists;
  }

  void deleteCatalog(TransactionType type, Catalog item) {
    Hive.box<Catalog>(Strings.catalogBox)
        .delete('${item.name}.${type.toShortString()}');
  }

  void putAllAccount(Map<String, Account> items) =>
      Hive.box<Account>(Strings.primaryAccountBox).putAll(items);

  void deleteAccount(String key) =>
      Hive.box<Account>(Strings.primaryAccountBox).delete(key);

  List<Account> getAllAccount() {
    Map<String, Account> items =
        Hive.box<Account>(Strings.primaryAccountBox).toMap().cast();
    items.removeWhere((key, value) => key.contains('init'));
    return items.entries.map((e) => e.value).toList();
  }

  Map<String, Account> getAllAccountAsMap(bool toggleIsInit) {
    Map<String, Account> items =
        Hive.box<Account>(Strings.primaryAccountBox).toMap().cast();
    if (toggleIsInit) {
      items.removeWhere((key, value) => !key.contains('init'));
    } else {
      items.removeWhere((key, value) => key.contains('init'));
    }
    return items;
  }

  bool isExistedAccount(String key) =>
      Hive.box<Account>(Strings.primaryAccountBox).containsKey(key);

  List<TransactionItem> getAllTransactionItem() {
    final itemMap = Hive.box<TransactionItem>(Strings.transactionBox).toMap();
    log(itemMap.toString());
    logger.d("path ${Hive.box<TransactionItem>(Strings.transactionBox).path}");
    return Hive.box<TransactionItem>(Strings.transactionBox).values.toList();
  }

  // if key available this is run as update transaction
  void addTransactionItem(TransactionItem item, {int? key}) {
    final itemWithKey = item.copyWith(key: key ?? ++_lastKeyTransaction);
    Hive.box<TransactionItem>(Strings.transactionBox)
        .put(itemWithKey.key, itemWithKey);
  }

  void deleteTransactionItem(TransactionItem item) {
    late int key;
    if (item.key == null) {
      final itemMap = Hive.box<TransactionItem>(Strings.transactionBox).toMap();
      key = itemMap.keys.firstWhere((key) => itemMap[key] == item);
    } else {
      key = item.key!;
    }
    Hive.box<TransactionItem>(Strings.transactionBox).delete(key);
  }

  void putAllTransaction(Map<dynamic, TransactionItem> entries) =>
      Hive.box<TransactionItem>(Strings.transactionBox).putAll(entries);

  Map<dynamic, TransactionItem> getAllTransactionItemAsMap() =>
      Hive.box<TransactionItem>(Strings.transactionBox).toMap();

  void clearAll() {
    Hive.box<TransactionItem>(Strings.transactionBox).clear();
    Hive.box<Account>(Strings.primaryAccountBox).clear();
    Hive.box<Catalog>(Strings.catalogBox).clear();
    Hive.box(Strings.settingBox).clear();
  }
}
