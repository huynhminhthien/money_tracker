part of 'analysis_cubit.dart';

class AnalysisState extends Equatable {
  const AnalysisState({
    this.status = StateStatus.initial,
    this.transactionType = TransactionType.expense,
    this.dateType = DateType.month,
    this.dateSelected = "",
    this.dateList = const <String>[],
    this.catalogPercentages = const <CatalogPercentage>[],
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  final StateStatus status;
  final TransactionType transactionType;
  final DateType dateType;
  final String dateSelected;
  final List<String> dateList;
  final List<CatalogPercentage> catalogPercentages;
  final int totalIncome;
  final int totalExpense;

  AnalysisState copyWith({
    StateStatus? status,
    TransactionType? transactionType,
    DateType? dateType,
    String? dateSelected,
    List<String>? dateList,
    List<CatalogPercentage>? catalogPercentages,
    int? totalIncome,
    int? totalExpense,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      transactionType: transactionType ?? this.transactionType,
      dateType: dateType ?? this.dateType,
      dateSelected: dateSelected ?? this.dateSelected,
      dateList: dateList ?? this.dateList,
      catalogPercentages: catalogPercentages ?? this.catalogPercentages,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
    );
  }

  @override
  List<Object> get props => [
        status,
        transactionType,
        dateType,
        dateSelected,
        dateList,
        catalogPercentages,
      ];
}
