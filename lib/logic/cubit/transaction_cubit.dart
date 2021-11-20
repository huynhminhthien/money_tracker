import 'package:bloc/bloc.dart';
import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:money_tracker/logic/debug/logger.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({required this.repository})
      : super(const TransactionState());

  final Repository repository;

  ScrollController scrollController = ScrollController();

  void handleScroll() async {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        emit(state.copyWith(showFloatingButton: false));
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        emit(state.copyWith(showFloatingButton: true));
      }
    });
  }

  void addItem2Transaction(TransactionItem item) {
    if (repository.addTransactionItem(item)) {
      emit(
        state.copyWith(
          status: StateStatus.success,
          items: repository.getAllTransactionItem(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage: "Add transaction is failure",
        ),
      );
    }
  }

  void updateItemOfTransaction(
      TransactionItem oldItem, TransactionItem newItem) {
    List<TransactionItem> items = List.of(state.items);
    if (!items.contains(oldItem)) {
      logger.e("old item does not found");
      return;
    }

    if (repository.updateTransactionItem(oldItem, newItem)) {
      emit(state.copyWith(
        status: StateStatus.success,
        items: repository.getAllTransactionItem(),
      ));
    } else {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage: "Modify transaction is failure",
        ),
      );
    }
  }

  void removeItemOfTransaction(TransactionItem item) {
    if (repository.removeTransactionItem(item)) {
      emit(
        state.copyWith(
          status: StateStatus.success,
          items: repository.getAllTransactionItem(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage: "Remove transaction is failure",
        ),
      );
    }
  }

  void collectData4Filter() {
    List<String> accountName = [
      for (Account item in repository.getAcounts()) item.name
    ];

    List<String> catalogName = [
      for (Catalog item in repository.getAllCatalog(TransactionType.all))
        item.name
    ];

    Map<String, List<String>> filterData = {
      FilterKey.account: accountName..insert(0, "all"),
      FilterKey.catalog: catalogName..insert(0, "all"),
      FilterKey.month: repository.monthCollection()..insert(0, "all"),
    };
    emit(
      state.copyWith(
        filterData: filterData,
        status: StateStatus.success,
      ),
    );
  }

  String _removeSign4VietnameseString(String str) {
    String lowerCaseString = str.toLowerCase();
    final List<String> vietnameseSigns = [
      "aeouidy",
      "áàạảãâấầậẩẫăắằặẳẵ",
      "éèẹẻẽêếềệểễ",
      "óòọỏõôốồộổỗơớờợởỡ",
      "úùụủũưứừựửữ",
      "íìịỉĩ",
      "đ",
      "ýỳỵỷỹ",
    ];
    for (int i = 1; i < vietnameseSigns.length; i++) {
      for (int j = 0; j < vietnameseSigns[i].length; j++) {
        lowerCaseString = lowerCaseString.replaceAll(
            vietnameseSigns[i][j], vietnameseSigns[0][i - 1]);
      }
    }
    return lowerCaseString;
  }

  void filteringTransactions([Map<String, String>? filters]) {
    List<TransactionItem> items = repository.getAllTransactionItem();

    Map<String, String> filterMap = Map.of(state.filters);
    if (filters != null) filterMap.addAll(filters);

    List<TransactionItem> filtered = [];
    TransactionType filterType = filterMap[FilterKey.transaction]!.toEnumType();
    bool isFilterAll = filterType == TransactionType.all &&
        filterMap[FilterKey.month] == "all" &&
        filterMap[FilterKey.account] == "all" &&
        filterMap[FilterKey.catalog] == "all";
    bool isEmptySearch = filterMap[FilterKey.search]!.isEmpty;
    String searchValue = "";
    if (!isEmptySearch) {
      searchValue = _removeSign4VietnameseString(filterMap[FilterKey.search]!);
    }

    if (!isFilterAll) {
      bool _account = false;
      bool _catalog = false;
      bool _month = false;
      bool _search = false;
      bool _type = false;
      DateTime? dateTime;

      if (filterMap[FilterKey.month] != "all") {
        dateTime = filterMap[FilterKey.month]!.parseToDateTimeWithoutDay();
      }

      filtered = items.where((element) {
        _month = filterMap[FilterKey.month] == "all" ||
            _compareMonth(element.date.parseToDateTime(), dateTime!);
        _catalog = filterMap[FilterKey.catalog] == "all" ||
            element.catalog.name == filterMap[FilterKey.catalog];
        _search = isEmptySearch ||
            _removeSign4VietnameseString(element.note).contains(searchValue);
        _type = filterType == TransactionType.all || element.type == filterType;

        switch (element.type) {
          case TransactionType.income:
            _account = filterMap[FilterKey.account] == "all" ||
                element.toAccount!.name == filterMap[FilterKey.account];
            break;
          case TransactionType.expense:
            _account = filterMap[FilterKey.account] == "all" ||
                element.fromAccount!.name == filterMap[FilterKey.account];
            break;
          case TransactionType.transfer:
            _account = filterMap[FilterKey.account] == "all" ||
                element.toAccount!.name == filterMap[FilterKey.account] ||
                element.fromAccount!.name == filterMap[FilterKey.account];
            break;
          default:
        }
        return _month && _catalog && _account && _search && _type;
      }).toList();
    } else if (!isEmptySearch) {
      filtered = items
          .where((element) =>
              _removeSign4VietnameseString(element.note).contains(searchValue))
          .toList();
    }

    emit(
      state.copyWith(
        items: (isFilterAll && isEmptySearch) ? items : filtered,
        filters: filterMap,
        showFloatingButton: true,
        status: StateStatus.success,
      ),
    );
  }

  bool _compareMonth(DateTime date1, DateTime date2) =>
      date1.month == date2.month && date1.year == date2.year;
}
