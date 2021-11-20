import 'package:bloc/bloc.dart';
import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:equatable/equatable.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({required this.repository}) : super(const AccountState());
  final Repository repository;

  void getAccounts() {
    List<Account> items = repository.getAcounts();

    emit(
      state.copyWith(
        items: items,
        status: StateStatus.success,
        failureMessage: "",
      ),
    );
  }

  void addAccount(Account item) {
    if (repository.addAccount(item)) {
      emit(
        state.copyWith(
          items: repository.getAcounts(),
          status: StateStatus.success,
          failureMessage: "",
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage: "Account '${item.name}' is existed",
        ),
      );
    }
  }

  void updateAccount(Account oldAcc, Account newAcc) {
    if (repository.isUsedAccount(oldAcc)) {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage:
              "Account '${oldAcc.name}' is using, imposible to update",
        ),
      );
    } else if (repository.updateAccount(oldAcc, newAcc)) {
      List<Account> items = repository.getAcounts();
      emit(
        state.copyWith(
          items: items,
          status: StateStatus.success,
          failureMessage: "",
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage: "Account '${newAcc.name}' is existed",
        ),
      );
    }
  }

  void deleteAccount(Account item) {
    if (repository.isUsedAccount(item)) {
      emit(
        state.copyWith(
          status: StateStatus.failure,
          failureMessage:
              "Account '${item.name}' is using, imposible to delete",
        ),
      );
    } else {
      repository.deleteAccount(item);
      List<Account> items = repository.getAcounts();
      emit(
        state.copyWith(
          items: items,
          status: StateStatus.success,
          failureMessage: "",
        ),
      );
    }
  }

  void reFilterAccount() {
    List<Account> items = repository.reFilterAccount();
    emit(
      state.copyWith(
        items: items,
        status: StateStatus.success,
        failureMessage: "",
      ),
    );
  }

  void cleanFailureMessage() {
    emit(
      state.copyWith(
        status: StateStatus.success,
        failureMessage: "",
      ),
    );
  }

  void togleVisibleTotal() {
    emit(
      state.copyWith(
        visibleTotal: !state.visibleTotal,
        status: StateStatus.success,
      ),
    );
  }
}
