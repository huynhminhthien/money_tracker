import 'package:hive/hive.dart';
import 'package:money_tracker/core/helpers/hive_helper.dart';
import 'package:money_tracker/data/models/isolate_model.dart';
import 'package:money_tracker/data/repositories/repository.dart';

import 'debug/logger.dart';

void isolateHandler(IsolateBackupParam msg) async {
  bool rc = false;
  Hive.init(msg.hivePath);
  await registerAndOpenBox();

  if (msg.isBackup) {
    rc = await Repository().backupData(msg.backupPath);
  } else {
    rc = await Repository().restoreData(msg.backupPath);
  }
  msg.sendPort.send((msg.isBackup ? "Backup" : "Restore") +
      " is " +
      (rc ? "successful" : "failure"));
  logger.d("_isolateHandler done");
  Hive.close();
}
