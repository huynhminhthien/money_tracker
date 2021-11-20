part of 'item_cubit.dart';

class ItemState extends Equatable {
  const ItemState({
    this.status = StateStatus.initial,
    this.type = TransactionType.expense,
    this.types = const <TransactionTypePackage>[],
    this.catalogs = const <Catalog>[],
    this.fromAccounts = const <Account>[],
    this.toAccounts = const <Account>[],
  });

  final StateStatus status;
  final TransactionType type;
  final List<TransactionTypePackage> types;
  final List<Catalog> catalogs;
  final List<Account> fromAccounts;
  final List<Account> toAccounts;

  ItemState copyWith({
    StateStatus? status,
    TransactionType? type,
    List<TransactionTypePackage>? types,
    List<Catalog>? catalogs,
    List<Account>? fromAccounts,
    List<Account>? toAccounts,
  }) {
    return ItemState(
      status: status ?? this.status,
      type: type ?? this.type,
      types: types ?? this.types,
      catalogs: catalogs ?? this.catalogs,
      fromAccounts: fromAccounts ?? this.fromAccounts,
      toAccounts: toAccounts ?? this.toAccounts,
    );
  }

  @override
  List<Object> get props => [status, type, catalogs, fromAccounts, toAccounts];
}
