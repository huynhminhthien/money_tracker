part of 'account_cubit.dart';

class AccountState extends Equatable {
  const AccountState({
    this.status = StateStatus.initial,
    this.items = const <Account>[],
    this.totals = 0,
    this.failureMessage = "",
    this.visibleTotal = false,
  });

  final StateStatus status;
  final List<Account> items;
  final int totals;
  final String failureMessage;
  final bool visibleTotal;

  AccountState copyWith({
    StateStatus? status,
    List<Account>? items,
    String? failureMessage,
    bool? visibleTotal,
  }) {
    int total = 0;
    if (items != null) {
      for (var element in items) {
        total += element.overBalance;
      }
    }
    return AccountState(
      items: items ?? this.items,
      status: status ?? this.status,
      totals: items != null ? total : totals,
      failureMessage: failureMessage ?? this.failureMessage,
      visibleTotal: visibleTotal ?? this.visibleTotal,
    );
  }

  @override
  List<Object> get props =>
      [status, items, totals, failureMessage, visibleTotal];
}
