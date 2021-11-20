part of 'setting_cubit.dart';

class SettingState extends Equatable {
  const SettingState({
    this.notification = "",
    this.fingerprint = false,
    this.showAllAccount = true,
    this.message = "",
  });

  final String notification;
  final bool fingerprint;
  final bool showAllAccount;
  final String message;

  SettingState copyWith({
    String? notification,
    bool? fingerprint,
    bool? showAllAccount,
    String? message,
  }) {
    return SettingState(
      notification: notification ?? this.notification,
      fingerprint: fingerprint ?? this.fingerprint,
      showAllAccount: showAllAccount ?? this.showAllAccount,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props =>
      [notification, fingerprint, showAllAccount, message];
}
