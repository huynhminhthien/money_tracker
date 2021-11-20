import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';

part 'analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit({required this.repository}) : super(const AnalysisState());

  final Repository repository;

  void processing({
    DateType? dateType,
    String? dateSelected,
    TransactionType? transactionType,
  }) {
    final _dateType = dateType ?? state.dateType;
    final _transactionType = transactionType ?? state.transactionType;
    String _dateSelected = dateSelected ?? state.dateSelected;
    List<String> _dateList = [];

    _dateList = repository.monthCollection();
    if (_dateType == DateType.year) {
      Set<String> years = {};
      for (var item in _dateList) {
        years.add(item.split('/')[1]);
      }
      _dateList = years.toList();
    }
    if (_dateSelected.isEmpty || !_dateList.contains(_dateSelected)) {
      if (_dateList.isEmpty) return;
      _dateSelected = _dateList[0];
    }

    final expectedDate = _parseDateTime(_dateType, _dateSelected);
    final items = repository.getAllTransactionItem();
    Map<Catalog, List<TransactionItem>> groupCatalog = {};

    int _totalAmountMain = 0;
    int _totalAmountOther = 0;
    for (var item in items) {
      if (item.type != TransactionType.transfer &&
          _compareDateTime(
              expectedDate, item.date.parseToDateTime(), _dateType)) {
        if (_transactionType == item.type) {
          final key = item.catalog;
          if (groupCatalog.containsKey(key)) {
            groupCatalog[key] = groupCatalog[key]!..add(item);
          } else {
            groupCatalog[key] = [item];
          }
          _totalAmountMain += item.amount;
        } else {
          _totalAmountOther += item.amount;
        }
      }
    }

    List<CatalogPercentage> _catalogPercentages = [];
    groupCatalog.forEach((key, value) {
      int catalogAmount = 0;
      for (var element in value) {
        catalogAmount += element.amount;
      }
      _catalogPercentages.add(CatalogPercentage(
        catalog: key,
        percentage: catalogAmount != 0 ? catalogAmount / _totalAmountMain : 0,
        amount: catalogAmount,
        transactions: value,
      ));
    });

    _catalogPercentages.sort((a, b) => b.amount.compareTo(a.amount));

    emit(
      state.copyWith(
        status: StateStatus.success,
        dateType: _dateType,
        dateList: _dateList,
        dateSelected: _dateSelected,
        transactionType: _transactionType,
        catalogPercentages: _catalogPercentages,
        totalExpense: _transactionType == TransactionType.expense
            ? _totalAmountMain
            : _totalAmountOther,
        totalIncome: _transactionType == TransactionType.income
            ? _totalAmountMain
            : _totalAmountOther,
      ),
    );
  }

  DateTime _parseDateTime(DateType dateType, String date) {
    if (dateType == DateType.year) {
      return date.parseToDateOnlyYear();
    } else if (dateType == DateType.month) {
      return date.parseToDateTimeWithoutDay();
    }
    throw "unsupport dateType $dateType";
  }

  bool _compareDateTime(DateTime date1, DateTime date2, DateType dateType) {
    if (dateType == DateType.month) {
      return date1.month == date2.month && date1.year == date2.year;
    } else if (dateType == DateType.year) {
      return date1.year == date2.year;
    }
    throw "unsupport dateType $dateType";
  }
}
