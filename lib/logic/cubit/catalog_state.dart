part of 'catalog_cubit.dart';

class CatalogState extends Equatable {
  const CatalogState({
    this.type = TransactionType.income,
    this.status = StateStatus.initial,
    this.items = const <Catalog>[],
    this.failureMessage = "",
    this.catalogInfo = "",
  });

  final StateStatus status;
  final TransactionType type;
  final List<Catalog> items;
  final String failureMessage;
  final String catalogInfo;

  CatalogState copyWith({
    StateStatus? status,
    List<Catalog>? items,
    TransactionType? type,
    String? failureMessage,
    String? catalogInfo,
  }) {
    return CatalogState(
      items: items ?? this.items,
      status: status ?? this.status,
      type: type ?? this.type,
      failureMessage: failureMessage ?? this.failureMessage,
      catalogInfo: catalogInfo ?? this.catalogInfo,
    );
  }

  @override
  List<Object> get props => [status, items, type, failureMessage, catalogInfo];
}
