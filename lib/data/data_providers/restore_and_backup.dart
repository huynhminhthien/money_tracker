import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'package:encrypt/encrypt.dart';
import 'package:hive/hive.dart';
import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/logic/debug/logger.dart';
// import 'package:password/password.dart';

// Future<bool> restoreBackup(String restorePath) async {
//   File restoreFile = File('$restorePath/moneyTrackerBackup');
//   if (!restoreFile.existsSync()) return false;
//   try {
//     String jsonString = await restoreFile.readAsString();
//     Map<String, dynamic> fromJson = json.decode(jsonString);

//     final boxs = [
//       Strings.transactionBox,
//       Strings.primaryAccountBox,
//       Strings.catalogBox,
//       Strings.settingBox
//     ];

//     for (var box in boxs) {
//       if (!fromJson.containsKey(box)) return false;
//     }

//     for (var box in boxs) {
//       dynamic dataOfBox = fromJson[box];
//       switch (box) {
//         case Strings.catalogBox:
//           Map<String, Catalog> restoreMap = (dataOfBox as Map)
//               .map((key, value) => MapEntry(key, Catalog.fromJson(value)))
//               .cast();
//           Hive.box<Catalog>(box).putAll(restoreMap);
//           break;
//         case Strings.primaryAccountBox:
//           Map<String, Account> restoreMap = (dataOfBox as Map)
//               .map((key, value) => MapEntry(key, Account.fromJson(value)))
//               .cast();
//           Hive.box<Account>(box).putAll(restoreMap);
//           break;
//         case Strings.transactionBox:
//           Map<int, TransactionItem> restoreMap = (dataOfBox as Map)
//               .map((key, value) =>
//                   MapEntry(int.parse(key), TransactionItem.fromJson(value)))
//               .cast();
//           Hive.box<TransactionItem>(box).putAll(restoreMap);
//           break;
//         case Strings.settingBox:
//           final restoreMap = (dataOfBox as Map).cast();
//           Hive.box(box).putAll(restoreMap);
//           break;
//         default:
//           logger.e("unexpected box");
//       }
//     }
//   } catch (e) {
//     logger.e(e);
//     return false;
//   }
//   return true;
// }

String fillKey(String input) {
  const maxLen = 32;
  String myKey = "";
  for (var i = 0; i < maxLen; i++) {
    myKey += i % 2 == 0 ? "@" : ".";
  }
  return (input + myKey).substring(0, maxLen);
}

class BackupAndRestore {
  BackupAndRestore(String password, this.path) {
    //   this.password = fillKey(password);
    //   _key = Key.fromUtf8(this.password);
  }
  // late final Key _key;
  // final _iv = IV.fromLength(16);
  late final String password;
  final String path;

  dynamic _getDataFromBox<T>(String boxName) {
    final itemMap = Hive.box<T>(boxName).toMap();
    if (T == TransactionItem) {
      Map<String, T> convertStringKey =
          itemMap.map((key, value) => MapEntry(key.toString(), value));
      return convertStringKey;
    }
    return itemMap;
  }

  Future<bool> createBackupFile() async {
    Map<String, dynamic> backupMap = {};
    try {
      backupMap[Strings.transactionBox] =
          _getDataFromBox<TransactionItem>(Strings.transactionBox);
      backupMap[Strings.primaryAccountBox] =
          _getDataFromBox<Account>(Strings.primaryAccountBox);
      backupMap[Strings.catalogBox] =
          _getDataFromBox<Catalog>(Strings.catalogBox);
      backupMap[Strings.settingBox] = _getDataFromBox(Strings.settingBox);

      final encoded = json.encode(backupMap);
      // final encryptedText = _encryptData(encoded);
      // final hashPass = Password.hash(password, PBKDF2());
      // logger.d(hashPass);
      // await File('$path/moneyTrackerBackup')
      //     .writeAsString(hashPass + "\n", mode: FileMode.write);
      await File('$path/moneyTrackerBackup')
          .writeAsString(encoded, mode: FileMode.write);
    } catch (e) {
      logger.e(e);
      return false;
    }
    return true;
  }

  Future<bool> restoreBackup() async {
    File restoreFile = File('$path/moneyTrackerBackup');
    if (!restoreFile.existsSync()) return false;
    try {
      // List<String> rawString = await restoreFile.readAsLines();
      // if (rawString.length != 2) return false;
      // logger.d(rawString[0]);
      // if (!Password.verify(password, rawString[0])) {
      //   logger.w("wrong password");
      //   return false;
      // }

      String jsonString = await restoreFile.readAsString();
      Map<String, dynamic> fromJson = json.decode(jsonString);

      final boxs = [
        Strings.transactionBox,
        Strings.primaryAccountBox,
        Strings.catalogBox,
        Strings.settingBox
      ];

      for (var box in boxs) {
        if (!fromJson.containsKey(box)) return false;
      }

      for (var box in boxs) {
        dynamic dataOfBox = fromJson[box];
        switch (box) {
          case Strings.catalogBox:
            Map<String, Catalog> restoreMap = (dataOfBox as Map)
                .map((key, value) => MapEntry(key, Catalog.fromJson(value)))
                .cast();
            await Hive.box<Catalog>(box).putAll(restoreMap);
            break;
          case Strings.primaryAccountBox:
            Map<String, Account> restoreMap = (dataOfBox as Map)
                .map((key, value) => MapEntry(key, Account.fromJson(value)))
                .cast();
            await Hive.box<Account>(box).putAll(restoreMap);
            break;
          case Strings.transactionBox:
            Map<int, TransactionItem> restoreMap = (dataOfBox as Map)
                .map((key, value) =>
                    MapEntry(int.parse(key), TransactionItem.fromJson(value)))
                .cast();
            await Hive.box<TransactionItem>(box).putAll(restoreMap);
            break;
          case Strings.settingBox:
            final restoreMap = (dataOfBox as Map).cast();
            await Hive.box(box).putAll(restoreMap);
            break;
          default:
            logger.e("unexpected box");
        }
      }
    } catch (e) {
      logger.e(e);
      return false;
    }
    return true;
  }

  // String _encryptData(String plainText) {
  //   final encrypted = Encrypter(AES(_key)).encrypt(plainText, iv: _iv);
  //   return encrypted.base64;
  // }

  // String _decryptData(String encryptedText) {
  //   return Encrypter(AES(_key)).decrypt64(encryptedText, iv: _iv);
  // }
}
