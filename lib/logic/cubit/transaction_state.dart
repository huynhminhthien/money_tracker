part of 'transaction_cubit.dart';

class TransactionState extends Equatable {
  const TransactionState({
    this.status = StateStatus.initial,
    this.filters = const <String, String>{
      FilterKey.transaction: "all",
      FilterKey.catalog: "all",
      FilterKey.account: "all",
      FilterKey.month: "all",
      FilterKey.search: "",
    },
    this.filterData = const <String, List<String>>{
      FilterKey.catalog: [],
      FilterKey.account: [],
      FilterKey.month: [],
    },
    this.items = const <TransactionItem>[],
    this.showFloatingButton = true,
    this.failureMessage = "",
  });

  final StateStatus status;
  final Map<String, String> filters;
  final Map<String, List<String>> filterData;
  final List<TransactionItem> items;
  final bool showFloatingButton;
  final String failureMessage;

  TransactionState copyWith({
    StateStatus? status,
    Map<String, String>? filters,
    Map<String, List<String>>? filterData,
    List<TransactionItem>? items,
    bool? showFloatingButton,
    String? failureMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      filters: filters ?? this.filters,
      filterData: filterData ?? this.filterData,
      items: items ?? this.items,
      showFloatingButton: showFloatingButton ?? this.showFloatingButton,
      failureMessage: failureMessage ?? "",
    );
  }

  @override
  List<Object?> get props =>
      [status, filters, filterData, items, showFloatingButton];
}
