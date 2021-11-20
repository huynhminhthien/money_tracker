import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/core/themes/my_flutter_app_icons.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/logic/cubit/account_cubit.dart';
import 'package:money_tracker/logic/cubit/item_cubit.dart';
import 'package:money_tracker/logic/cubit/transaction_cubit.dart';
import 'package:money_tracker/presentation/account/account.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:money_tracker/presentation/transactions/transaction.dart';
import 'package:money_tracker/presentation/widget/choice_chip.dart';
import 'package:money_tracker/presentation/widget/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _account = "";
  String _month = "";
  String _catalog = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => dismissKeyboard(context),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140.0),
          child: SizedBox(
            height: 140.0,
            child: Stack(
              children: [
                Container(
                  height: 120.0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFAA76FF),
                        Color(0xFF4400D5),
                      ],
                      tileMode: TileMode.repeated,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(10, 0, 0, 0),
                        blurRadius: 4.0,
                        spreadRadius: 0.0,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            MyFlutterApp.userOutline,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              BlocBuilder<AccountCubit, AccountState>(
                                buildWhen: (previous, current) =>
                                    previous.visibleTotal !=
                                        current.visibleTotal ||
                                    previous.totals != current.totals,
                                builder: (context, state) {
                                  return Text(
                                    state.visibleTotal
                                        ? state.totals
                                            .asMoneyDisplay(showSign: true)
                                        : "*********",
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(color: Colors.white),
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Available Balance",
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          BlocProvider.of<AccountCubit>(context)
                                              .togleVisibleTotal();
                                        },
                                        child: BlocBuilder<AccountCubit,
                                            AccountState>(
                                          builder: (context, state) {
                                            return Icon(
                                              state.visibleTotal
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  filterButton(context),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BlocBuilder<TransactionCubit, TransactionState>(
                    buildWhen: (previous, current) =>
                        previous.filters[FilterKey.search] !=
                        current.filters[FilterKey.search],
                    builder: (context, state) {
                      return SearchBox(
                        textInit: state.filters[FilterKey.search]!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: const [
            AccountView(),
            TransactionView(),
          ],
        ),
        floatingActionButton:
            context.select((TransactionCubit transactionCubit) {
          if (transactionCubit.state.showFloatingButton ||
              transactionCubit.state.items.length < 3) {
            return FloatingActionButton(
              onPressed: () {
                BlocProvider.of<ItemCubit>(context).initalItem();
                Navigator.pushNamed(context, AppRouter.addItem);
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFAA76FF),
                      Color(0xFF4400D5),
                    ],
                    tileMode: TileMode.repeated,
                  ),
                ),
                child: const Icon(
                  FontAwesome5.plus,
                  color: Colors.white,
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget filterButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<TransactionCubit>(context).collectData4Filter();
        _showSideSheet(context: context);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
              Text(
                "Filter",
                style: GoogleFonts.roboto(
                  textStyle: Theme.of(context).textTheme.subtitle1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          BlocBuilder<TransactionCubit, TransactionState>(
            buildWhen: (previous, current) =>
                previous.filters.values != current.filters.values,
            builder: (context, state) {
              int count = 0;
              state.filters.forEach((key, value) {
                if (key != FilterKey.transaction &&
                    value.isNotEmpty &&
                    value.toLowerCase() != "all") {
                  count++;
                }
              });
              return Visibility(
                visible: count > 0,
                child: Positioned(
                  left: -5,
                  top: -5,
                  child: Container(
                    height: 15,
                    width: 15,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: GoogleFonts.roboto(
                        textStyle: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(color: Colors.white),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSideSheet({
    required BuildContext context,
    bool rightSide = true,
  }) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: (rightSide ? Alignment.centerRight : Alignment.centerLeft),
          child: Container(
            height: double.infinity,
            width: MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: _filterWidget(context),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(
            begin: Offset((rightSide ? 1 : -1), 0),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget _filterWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 60),
          alignment: Alignment.center,
          child: Text(
            "Filters",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Expanded(
          child: BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              _month = state.filters[FilterKey.month]!;
              _catalog = state.filters[FilterKey.catalog]!;
              _account = state.filters[FilterKey.account]!;
              return ListView(
                padding: const EdgeInsets.only(left: 10),
                children: _getChildFilter(context, state),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () {
              Map<String, String> filters = {};
              if (_account.isNotEmpty) {
                filters.addAll({FilterKey.account: _account});
              }
              if (_catalog.isNotEmpty) {
                filters.addAll({FilterKey.catalog: _catalog});
              }
              if (_month.isNotEmpty) {
                filters.addAll({FilterKey.month: _month});
              }
              BlocProvider.of<TransactionCubit>(context)
                  .filteringTransactions(filters);
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              width: 100,
              child: Text(
                "Apply",
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.white),
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  List<Widget> _getChildFilter(BuildContext context, TransactionState state) {
    return [
      Text(
        "Month",
        style: Theme.of(context).textTheme.headline6,
      ),
      MultiChoiceChip(
        filterList: state.filterData[FilterKey.month]!,
        initSelect: state.filters[FilterKey.month]!,
        isHorizontalScroll: false,
        onSelectionChanged: (selected) {
          _month = selected;
        },
      ),
      Text(
        "Account",
        style: Theme.of(context).textTheme.headline6,
      ),
      MultiChoiceChip(
        filterList: state.filterData[FilterKey.account]!,
        initSelect: state.filters[FilterKey.account]!,
        isHorizontalScroll: false,
        onSelectionChanged: (selected) {
          _account = selected;
        },
      ),
      Text(
        "Category",
        style: Theme.of(context).textTheme.headline6,
      ),
      MultiChoiceChip(
        filterList: state.filterData[FilterKey.catalog]!,
        initSelect: state.filters[FilterKey.catalog]!,
        isHorizontalScroll: false,
        onSelectionChanged: (selected) {
          _catalog = selected;
        },
      ),
    ];
  }
}

class SearchBox extends StatefulWidget {
  const SearchBox({Key? key, required this.textInit}) : super(key: key);
  final String? textInit;

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _controller = TextEditingController();

  void _clearTextField() {
    _controller.clear();
    BlocProvider.of<TransactionCubit>(context)
        .filteringTransactions({FilterKey.search: _controller.text});
    // Call setState to update the UI
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.textInit != null) _controller.text = widget.textInit!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: _controller,
        onEditingComplete: () {
          BlocProvider.of<TransactionCubit>(context)
              .filteringTransactions({FilterKey.search: _controller.text});
          dismissKeyboard(context);
        },
        onChanged: (valueChange) {
          // Call setState to update the UI
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: "Search",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () => _clearTextField(),
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
