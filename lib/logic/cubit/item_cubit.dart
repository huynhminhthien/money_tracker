import 'package:bloc/bloc.dart';
import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:money_tracker/logic/debug/logger.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  final Repository repository;
  ItemCubit({required this.repository}) : super(const ItemState());

  void initalItem([TransactionType type = TransactionType.expense]) async {
    try {
      List<TransactionTypePackage> types = repository.getAllTransactionType();
      List<Account> fromAccounts = repository.getAcounts(true);
      List<Account> toAccounts = repository.getAcounts(true);
      List<Catalog> catalogs =
          repository.getAllCatalog(TransactionType.expense);
      if (fromAccounts.isEmpty || catalogs.isEmpty) {
        emit(state.copyWith(status: StateStatus.failure));
        return;
      }
      emit(
        state.copyWith(
          status: StateStatus.success,
          type: type,
          types: types,
          fromAccounts: fromAccounts,
          toAccounts: toAccounts,
          catalogs: catalogs,
        ),
      );
    } catch (e) {
      logger.e("inital item failure $e");
      emit(state.copyWith(status: StateStatus.failure));
    }
  }

  void updateTransactionType(TransactionType type) async {
    try {
      List<Catalog> catalogs = repository.getAllCatalog(type);
      emit(
        state.copyWith(
          type: type,
          status: StateStatus.success,
          catalogs: catalogs,
        ),
      );
    } catch (e) {
      logger.e("updateTransactionType $e");
      emit(state.copyWith(status: StateStatus.failure));
    }
  }
}
