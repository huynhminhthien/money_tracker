import 'package:bloc/bloc.dart';
import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:equatable/equatable.dart';

part 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({required this.repository}) : super(const CatalogState());
  final Repository repository;

  String _catalogCollectInfo() {
    String info = "";
    List<TransactionType> types = [
      TransactionType.expense,
      TransactionType.income,
      TransactionType.transfer
    ];
    for (TransactionType type in types) {
      info +=
          "${repository.getAllCatalog(type).length} ${type.toShortString()}, ";
    }
    return info.substring(0, info.length - 2);
  }

  void getAllCatalogOfType(TransactionType type) {
    List<Catalog> items = repository.getAllCatalog(type);
    emit(
      state.copyWith(
        items: items,
        status: StateStatus.success,
        type: type,
        catalogInfo: _catalogCollectInfo(),
        failureMessage: "",
      ),
    );
  }

  void addCatalog(Catalog item, TransactionType type) {
    if (repository.isExistedCatalog(item)) {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage: "Catalog '${item.name}' is existed",
        ),
      );
    } else {
      repository.addCatalog(item, type);
      if (state.type == type) {
        emit(
          state.copyWith(
            status: StateStatus.success,
            items: List.of(state.items)..add(item),
            catalogInfo: _catalogCollectInfo(),
            failureMessage: "",
          ),
        );
      }
    }
  }

  void updateCatalog(
      Catalog oldCatalog, Catalog newCatalog, TransactionType type) {
    // if (repository.isUsedCatalog(oldCatalog)) {
    //   emit(
    //     state.copyWith(
    //       status: StateStatus.failure,
    //       failureMessage:
    //           "Catalog '${oldCatalog.name}' is using, imposible to update",
    //     ),
    //   );
    // } else
    if (repository.updateCatalog(oldCatalog, newCatalog, type)) {
      List<Catalog> items = repository.getAllCatalog(type);
      if (state.type == type) {
        emit(
          state.copyWith(
            items: items,
            status: StateStatus.success,
            failureMessage: "",
          ),
        );
      }
    }
    //  else {
    //   emit(
    //     state.copyWith(
    //       status: StateStatus.failure,
    //       failureMessage: "Catalog '${newCatalog.name}' is existed",
    //     ),
    //   );
    // }
  }

  void deleteCatalog(Catalog item) {
    if (repository.isUsedCatalog(item)) {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage:
              "Catalog '${item.name}' is using, imposible to delete",
        ),
      );
    } else {
      repository.deleteCatalog(item, state.type);
      List<Catalog> items = repository.getAllCatalog(state.type);
      emit(
        state.copyWith(
          items: items,
          status: StateStatus.success,
          catalogInfo: _catalogCollectInfo(),
        ),
      );
    }
  }

  void clearFailureMessage() {
    emit(state.copyWith(status: StateStatus.success, failureMessage: ""));
  }
}
