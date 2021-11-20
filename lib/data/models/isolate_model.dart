import 'dart:isolate';

class IsolateBackupParam {
  final bool isBackup;
  final String backupPath;
  final String hivePath;
  final SendPort sendPort;
  const IsolateBackupParam(
    this.isBackup,
    this.backupPath,
    this.hivePath,
    this.sendPort,
  );
}
