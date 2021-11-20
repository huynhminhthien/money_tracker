import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/repositories/notification_manager.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:equatable/equatable.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit({required this.repository}) : super(const SettingState());
  final Repository repository;

  void getSetting() {
    emit(
      state.copyWith(
        fingerprint: repository.readSetting(SettingKey.fingerprint),
        notification: repository.readSetting(SettingKey.notification),
        showAllAccount: repository.readSetting(SettingKey.showAllAccount),
      ),
    );
  }

  void showAllAccount(bool value) {
    repository.writeSetting(SettingKey.showAllAccount, value);
    emit(state.copyWith(showAllAccount: value));
  }

  void notificationChange([TimeOfDay? time]) {
    if (time != null) {
      NotificationManager().zonedScheduleNotification(time);
    } else {
      NotificationManager().cancal();
    }
    final timeString = time != null ? time.toShortString() : "";
    repository.writeSetting(SettingKey.notification, timeString);
    emit(state.copyWith(notification: timeString));
  }

  Future<bool> _isSupportAuthentication() async {
    final _auth = LocalAuthentication();
    bool isBiometricSupported = await _auth.isDeviceSupported();
    bool canCheckBiometrics = await _auth.canCheckBiometrics;
    return isBiometricSupported && canCheckBiometrics;
  }

  Future<void> fingerprintChange(bool value) async {
    if (!value) {
      repository.writeSetting(SettingKey.fingerprint, false);
      emit(state.copyWith(fingerprint: false));
      return;
    }
    final isSupport = await _isSupportAuthentication();
    if (isSupport) {
      repository.writeSetting(SettingKey.fingerprint, true);
      emit(state.copyWith(fingerprint: true));
    } else {
      emit(state.copyWith(
          fingerprint: false, message: "fingerprint is not support"));
    }
  }

  Future<void> backupData(String path) async {
    final rc = await repository.backupData(path);
    emit(state.copyWith(message: "Backup is ${rc ? "successful" : "failure"}"));
  }

  Future<void> restoreData(String path) async {
    final rc = await repository.restoreData(path);
    if (rc) {
      emit(
        state.copyWith(
          fingerprint: repository.readSetting(SettingKey.fingerprint),
          notification: repository.readSetting(SettingKey.notification),
          showAllAccount: repository.readSetting(SettingKey.showAllAccount),
          message: "Restore is successful",
        ),
      );
    } else {
      emit(state.copyWith(message: "Data restoring failure"));
    }
  }

  void clearAllDatabase() {
    repository.cleanAllDatabase();
    emit(state.copyWith(message: "Clear data is successful"));
  }

  void clearMessage() {
    emit(state.copyWith(message: ""));
  }
}
