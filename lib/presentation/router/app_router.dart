import 'package:money_tracker/core/exceptions/route_exception.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/logic/cubit/account_cubit.dart';
import 'package:money_tracker/logic/cubit/catalog_cubit.dart';
import 'package:money_tracker/logic/cubit/transaction_cubit.dart';
import 'package:money_tracker/presentation/account/add_edit_account.dart';
import 'package:money_tracker/presentation/analytic/transaction_of_catalog.dart';
import 'package:money_tracker/presentation/bottom_nav_screen/bottom_nav_screen.dart';
import 'package:money_tracker/presentation/catalog/add_edit_catalog.dart';
import 'package:money_tracker/presentation/catalog/catalog.dart';
import 'package:money_tracker/presentation/login_screen/login_screen.dart';
import 'package:money_tracker/presentation/transactions/add_edit_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static const String login = 'login';
  static const String bottomNav = 'bottomNav';
  static const String addItem = 'addItem';
  static const String editItem = 'editItem';
  static const String catalogView = 'CatalogView';
  static const String addCatalog = 'addCatalog';
  static const String editCatalog = 'editCatalog';
  static const String addAccount = 'addAccount';
  static const String editAccount = 'editAccount';
  static const String transactionOfCatalog = 'transactionOfCatalog';

  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case bottomNav:
        return MaterialPageRoute(
          builder: (context) => const BottomNavScreen(),
        );
      case addItem:
        return MaterialPageRoute(
          builder: (context) => AddEditItem(
            onSave: (item) {
              BlocProvider.of<TransactionCubit>(context)
                  .addItem2Transaction(item);
            },
            isEditing: false,
          ),
        );
      case editItem:
        final item = settings.arguments as TransactionItem;
        return MaterialPageRoute(
          builder: (context) => AddEditItem(
            onSave: (onChangeItem) {
              BlocProvider.of<TransactionCubit>(context)
                  .updateItemOfTransaction(item, onChangeItem);
            },
            isEditing: true,
            item: item,
          ),
        );
      case catalogView:
        return MaterialPageRoute(
          builder: (context) => const CatalogView(),
        );
      case addCatalog:
        return MaterialPageRoute(
          builder: (context) => AddEditCatalog(
            onSave: (item, type) {
              BlocProvider.of<CatalogCubit>(context).addCatalog(item, type);
            },
            isEditing: false,
          ),
        );
      case editCatalog:
        final mapCatalog = settings.arguments as Map<String, String>;
        final oldCatalog = Catalog(mapCatalog['name']!, mapCatalog['icon']!);
        return MaterialPageRoute(
          builder: (context) => AddEditCatalog(
            onSave: (newCatalog, type) {
              BlocProvider.of<CatalogCubit>(context)
                  .updateCatalog(oldCatalog, newCatalog, type);
            },
            isEditing: true,
            item: oldCatalog,
            type: mapCatalog['type']!.toEnumType(),
          ),
        );
      case addAccount:
        return MaterialPageRoute(
          builder: (context) => AddEditAccount(
            onSave: (item) {
              BlocProvider.of<AccountCubit>(context).addAccount(item);
            },
            isEditing: false,
          ),
        );
      case editAccount:
        final oldAcc = settings.arguments as Account;
        return MaterialPageRoute(
          builder: (context) => AddEditAccount(
            onSave: (newAcc) {
              BlocProvider.of<AccountCubit>(context)
                  .updateAccount(oldAcc, newAcc);
            },
            isEditing: true,
            item: oldAcc,
          ),
        );
      case transactionOfCatalog:
        final items = settings.arguments as List<TransactionItem>;
        return MaterialPageRoute(
          builder: (context) => TransactionOfCatalog(
            items: items,
          ),
        );
      default:
        throw const RouteException('Route not found!');
    }
  }
}
