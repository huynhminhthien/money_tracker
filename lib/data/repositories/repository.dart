import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/core/themes/my_flutter_app_icons.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/data_providers/data_provider.dart';
import 'package:money_tracker/data/data_providers/restore_and_backup.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/brandico_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:money_tracker/logic/debug/logger.dart';

import 'notification_manager.dart';

Map<String, IconData> mapIconAccount = {
  "dollar_sign": FontAwesome5.dollar_sign,
  "visa": Brandico.visa,
  "mastercard": Brandico.mastercard,
  "money_outlined": Icons.money_outlined,
  "savings_outlined": Icons.savings_outlined,
  "payment_outlined": Icons.payment_outlined,
  "account_balance_wallet_outlined": Icons.account_balance_wallet_outlined,
  "account_balance_outlined": Icons.account_balance_outlined,
  "credit_card": Entypo.credit_card,
  "card_membership_outlined": Icons.card_membership_outlined,
  "card_travel_outlined": Icons.card_travel_outlined,
  "wallet": Linecons.wallet,
};

Map<String, IconData> mapIconCatalog = {
  "more_horiz_outlined": Icons.more_horiz_outlined,
  "heart_pulse": LineariconsFree.heart_pulse,
  "home": LineariconsFree.home,
  "train": LineariconsFree.train,
  "car": LineariconsFree.car,
  "phone_handset": LineariconsFree.phone_handset,
  "gift": LineariconsFree.gift,
  "bicycle": LineariconsFree.bicycle,
  "dinner": LineariconsFree.dinner,
  "coffee_cup": LineariconsFree.coffee_cup,
  "smile": LineariconsFree.smile,
  "shirt": LineariconsFree.shirt,
  "store": LineariconsFree.store,
  "cart": LineariconsFree.cart,
  "users": LineariconsFree.users,
  "film_play": LineariconsFree.film_play,
  "graduation_hat": LineariconsFree.graduation_hat,
  "leaf": LineariconsFree.leaf,
  "cloud": LineariconsFree.cloud_2,
  "tag": Icons.tag,
  "food": Linecons.food,
  "money2": MyFlutterApp.money2,
  "handMoney": MyFlutterApp.handMoney,
  "money4": MyFlutterApp.money4,
  "moneyBag": MyFlutterApp.moneyBag,
  "atmmachine": MyFlutterApp.atmmachine,
  "groceries": MyFlutterApp.groceries,
  "lipstick": MyFlutterApp.lipstick,
  "piggy": MyFlutterApp.piggy,
  "shoppingonline": MyFlutterApp.shoppingonline,
};

extension ParseIcon on String {
  IconData? toIconData() {
    if (mapIconCatalog.containsKey(this)) {
      return mapIconCatalog[this];
    } else if (mapIconAccount.containsKey(this)) {
      return mapIconAccount[this];
    }
    return Icons.error_outline;
  }
}

List<Catalog> listCatalogExpenseDefault = [
  const Catalog("grocery", "cart"),
  const Catalog("transport", "car"),
  const Catalog("Other Expense", "moneyBag"),
];

List<Catalog> listCatalogIncomeDefault = [
  const Catalog("Salary", "money2"),
  const Catalog("Other Income", "handMoney"),
];

List<Catalog> listCatalogTransferDefault = [
  const Catalog("ATM", "atmmachine"),
  const Catalog("Other Transfer", "more_horiz_outlined"),
];

Map<String, Account> listAccountDefault = {
  "Cash": const Account("money_outlined", "Cash", 0, EVisibility.visible),
  "BIDV": const Account("payment_outlined", "BIDV", 0, EVisibility.visible),
  "Saving": const Account("savings_outlined", "Saving", 0, EVisibility.hidden),
  // ==============
  "Cash.init": const Account("money_outlined", "Cash", 0, EVisibility.visible),
  "BIDV.init":
      const Account("payment_outlined", "BIDV", 0, EVisibility.visible),
  "Saving.init":
      const Account("savings_outlined", "Saving", 0, EVisibility.hidden),
};

final List<TransactionTypePackage> listTransactionType = [
  const TransactionTypePackage(
      TransactionType.expense, MyFlutterApp.expense, Colors.red),
  const TransactionTypePackage(
      TransactionType.income, MyFlutterApp.income, Colors.green),
  const TransactionTypePackage(
      TransactionType.transfer, MyFlutterApp.transfer, Colors.grey),
];

class Repository {
  static final Repository _instance = Repository._internal();
  factory Repository() {
    return _instance;
  }
  Repository._internal();

  final DataProvider _provider = DataProvider();

  final Map<String, int> _dateTime = {};
  bool _showAllAccount = false;

  void cleanAllDatabase() {
    _provider.clearAll();
    _provider.set2Initialized();
  }

  void initDefaultApp() {
    // _provider.clearAll();
    _provider.adaptChangeNotify();
    if (_provider.isFisrtStarting()) {
      _provider.set2Initialized();
      _addCatalogDefault();
      _provider.putAllAccount(listAccountDefault);

      _provider.writeSetting(SettingKey.fingerprint, false);
      _provider.writeSetting(SettingKey.notification, "");
      _provider.writeSetting(SettingKey.showAllAccount, true);
    } else {
      String notificationTime = readSetting(SettingKey.notification);
      if (notificationTime.isNotEmpty) {
        final timeSplits = notificationTime.split(":");
        final hour = int.parse(timeSplits[0]);
        final minute = int.parse(timeSplits[1]);
        NotificationManager()
            .zonedScheduleNotification(TimeOfDay(hour: hour, minute: minute));
      }
    }
    _initValue();
  }

  void _initValue() {
    _showAllAccount = _provider.readSetting(SettingKey.showAllAccount);

    getAllTransactionItem().forEach((element) {
      _updateDateTimeMap(_dateTimeSplit(element.date), true);
    });
  }

  int _compareDateTime(String date1, String date2) => date2
      .parseToDateTimeWithoutDay()
      .compareTo(date1.parseToDateTimeWithoutDay());

  void _updateDateTimeMap(String key, bool increase) {
    if (_dateTime.containsKey(key)) {
      if (increase) {
        _dateTime[key] = _dateTime[key]! + 1;
      } else {
        if (_dateTime[key] == 1) {
          _dateTime.remove(key);
        } else {
          _dateTime[key] = _dateTime[key]! - 1;
        }
      }
    } else if (increase) {
      _dateTime[key] = 1;
    }
  }

  void _addCatalogDefault() {
    for (var element in listCatalogExpenseDefault) {
      _provider.addCatalog(TransactionType.expense, element);
    }
    for (var element in listCatalogIncomeDefault) {
      _provider.addCatalog(TransactionType.income, element);
    }
    for (var element in listCatalogTransferDefault) {
      _provider.addCatalog(TransactionType.transfer, element);
    }
  }

  bool isEnableFingerprint() => _provider.readSetting(SettingKey.fingerprint);

  dynamic readSetting(String key) => _provider.readSetting(key);

  void writeSetting(String key, dynamic value) {
    // assert(key == SettingKey.notification && value is String,
    //     "Write setting ${SettingKey.notification} must be 'String' type");
    // assert(key != SettingKey.notification && value is bool,
    //     "Write setting $key must be 'String' type");
    _provider.writeSetting(key, value);
    if (key == SettingKey.showAllAccount) {
      if (value is bool) {
        _showAllAccount = value;
      } else {
        logger.e("unexpected type when setting show all account");
      }
    }
  }

  List<String> monthCollection() {
    final listDateTime = _dateTime.entries.map((e) => e.key).toList();
    listDateTime.sort(_compareDateTime);
    return listDateTime;
  }

  String _dateTimeSplit(String dateTime) {
    List<String> splited = dateTime.split('/');
    return "${splited[1]}/${splited[2]}";
  }

  List<Account> getAcounts([bool forceGetAll = false]) {
    List<Account> items = _provider.getAllAccount();
    if (forceGetAll || _showAllAccount) return items;
    List<Account> filtered = items
        .where((element) => element.visibility == EVisibility.visible)
        .toList();
    return filtered;
  }

  bool addAccount(Account item) {
    if (_provider.isExistedAccount(item.name)) return false;
    _provider.putAllAccount({item.name: item});
    _provider.putAllAccount({"${item.name}.init": item});
    return true;
  }

  bool updateAccount(Account oldAcc, Account newAcc) {
    if (oldAcc.name == newAcc.name) {
      _provider.putAllAccount({newAcc.name: newAcc});
      _provider.putAllAccount({"${newAcc.name}.init": newAcc});
    } else {
      if (!addAccount(newAcc)) return false;
      deleteAccount(oldAcc);
    }
    return true;
  }

  void deleteAccount(Account item) {
    _provider.deleteAccount(item.name);
    _provider.deleteAccount("${item.name}.init");
  }

  List<Catalog> getAllCatalog(TransactionType type) =>
      _provider.getAllCatalog(type);

  void addCatalog(Catalog item, TransactionType type) =>
      _provider.addCatalog(type, item);

  bool isExistedCatalog(Catalog item) => _provider.isExistedCatalog(item);

  bool updateCatalog(
      Catalog oldCatalog, Catalog newCatalog, TransactionType type) {
    if (isExistedCatalog(newCatalog)) return false;
    if (isUsedCatalog(oldCatalog)) {
      final entries = _provider.getAllTransactionItemAsMap();
      entries.removeWhere((key, value) => value.catalog != oldCatalog);
      entries.updateAll(
          (key, value) => value = value.copyWith(catalog: newCatalog));
      _provider.putAllTransaction(entries);
    }
    // make sure delete before add to prevent update fails when same name
    deleteCatalog(oldCatalog, type);
    addCatalog(newCatalog, type);
    return true;
  }

  bool isUsedCatalog(Catalog item) {
    for (var element in _provider.getAllTransactionItem()) {
      if (element.catalog == item) {
        return true;
      }
    }
    return false;
  }

  bool isUsedAccount(Account item) {
    for (var element in _provider.getAllTransactionItem()) {
      if ((element.fromAccount != null &&
              element.fromAccount!.name == item.name) ||
          (element.toAccount != null && element.toAccount!.name == item.name)) {
        return true;
      }
    }
    return false;
  }

  void deleteCatalog(Catalog item, TransactionType type) =>
      _provider.deleteCatalog(type, item);

  List<TransactionTypePackage> getAllTransactionType() => listTransactionType;

  bool addTransactionItem(TransactionItem item, {int? key}) {
    final accoutAsMap = _provider.getAllAccountAsMap(false);
    if (_updateAmountAccount(accoutAsMap, item, true)) {
      _provider.addTransactionItem(item, key: key);
      _updateDateTimeMap(_dateTimeSplit(item.date), true);
      _provider.putAllAccount(accoutAsMap);
      return true;
    }
    return false;
  }

  List<TransactionItem> getAllTransactionItem() =>
      _provider.getAllTransactionItem();

  bool removeTransactionItem(TransactionItem item) {
    final accoutAsMap = _provider.getAllAccountAsMap(false);
    if (!_updateAmountAccount(accoutAsMap, item, false)) return false;
    _provider.deleteTransactionItem(item);
    _updateDateTimeMap(_dateTimeSplit(item.date), false);
    _provider.putAllAccount(accoutAsMap);
    return true;
  }

  bool updateTransactionItem(TransactionItem oldItem, TransactionItem newItem) {
    bool rc = removeTransactionItem(oldItem);
    if (!rc) return rc;
    addTransactionItem(newItem, key: oldItem.key);
    return rc;
  }

  bool _accountExchange(Map<String, Account> currentAccount, Account account,
      int amount, bool increase) {
    if (!currentAccount.containsKey(account.name)) return false;
    currentAccount[account.name] = account.copyWith(
        overBalance: increase
            ? currentAccount[account.name]!.overBalance + amount
            : currentAccount[account.name]!.overBalance - amount);
    return true;
  }

  bool _updateAmountAccount(Map<String, Account> currentAccount,
      TransactionItem item, bool createType) {
    bool rc = false;
    switch (item.type) {
      case TransactionType.income:
        rc = _accountExchange(currentAccount, item.toAccount!, item.amount,
            createType ? true : false);
        break;
      case TransactionType.expense:
        rc = _accountExchange(currentAccount, item.fromAccount!, item.amount,
            createType ? false : true);
        break;
      case TransactionType.transfer:
        rc = _accountExchange(currentAccount, item.fromAccount!, item.amount,
            createType ? false : true);
        if (!rc) return rc;
        rc = _accountExchange(currentAccount, item.toAccount!, item.amount,
            createType ? true : false);
        break;
      default:
        logger.e("Transaction type is unexpected");
    }
    return rc;
  }

  List<Account> reFilterAccount() {
    final listAccount = _provider.getAllAccountAsMap(true);
    Map<String, Account> reNewAccout = {};
    listAccount.forEach((key, value) {
      String account = key.split('.')[0];
      reNewAccout[account] = value;
    });
    for (var item in _provider.getAllTransactionItem()) {
      _updateAmountAccount(reNewAccout, item, true);
    }
    _provider.putAllAccount(reNewAccout);
    return getAcounts();
  }

  Future<bool> backupData(String path, [String password = ""]) async {
    if (!await BackupAndRestore("", path).createBackupFile()) {
      logger.w("Data backup failure");
      return false;
    }
    return true;
  }

  Future<bool> restoreData(String path, [String password = ""]) async {
    bool rc = true;

    if (!await BackupAndRestore("", path).restoreBackup()) {
      logger.e("Data restoring failure");
      rc = false;
    }

    _provider.adaptChangeNotify();
    if (rc) {
      _dateTime.clear();
      _initValue();
      writeSetting(SettingKey.fingerprint, false);
    }
    return rc;
  }
}
