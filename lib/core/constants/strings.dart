class Strings {
  const Strings._();
  // App
  static const appTitle = 'Money Tracker';
  static const transactionBox = 'transactionList';
  static const primaryAccountBox = 'accountList';
  static const catalogBox = 'catalogList';
  static const settingBox = 'settings';
}

class SettingKey {
  const SettingKey._();
  static const init = 'init';
  static const notification = 'notification';
  static const fingerprint = 'fingerprint';
  static const showAllAccount = 'showAllAccount';
}

class FilterKey {
  const FilterKey._();
  static const transaction = "transaction";
  static const catalog = "catalog";
  static const account = "account";
  static const month = "month";
  static const search = "search";
}
