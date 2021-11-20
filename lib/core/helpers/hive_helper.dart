import 'package:hive/hive.dart';
import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/data/models/item.dart';

Future<void> registerAndOpenBox() async {
  // const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  // final containsEncryptionKey = await secureStorage.containsKey(key: 'key');
  // if (!containsEncryptionKey) {
  //   final key = Hive.generateSecureKey();
  //   await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  // }
  // final vaulueOfKey = await secureStorage.read(key: 'key');
  // final encryptionKey = base64Url.decode(vaulueOfKey!);
  // logger.i(vaulueOfKey);
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(CatalogAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TransactionItemAdapter());
  Hive.registerAdapter(EVisibilityAdapter());

  await Hive.openBox<TransactionItem>(
    Strings.transactionBox,
    // encryptionCipher: HiveAesCipher(encryptionKey),
  );
  await Hive.openBox<Account>(
    Strings.primaryAccountBox,
    // encryptionCipher: HiveAesCipher(encryptionKey),
  );
  await Hive.openBox<Catalog>(
    Strings.catalogBox,
    // encryptionCipher: HiveAesCipher(encryptionKey),
  );
  await Hive.openBox(
    Strings.settingBox,
    // encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
