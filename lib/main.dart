import 'package:device_preview/device_preview.dart';
import 'package:money_tracker/core/constants/strings.dart';
import 'package:money_tracker/core/helpers/hive_helper.dart';
import 'package:money_tracker/core/themes/app_theme.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/logic/cubit/account_cubit.dart';
import 'package:money_tracker/logic/cubit/analysis_cubit.dart';
import 'package:money_tracker/logic/cubit/authentication_cubit.dart';
import 'package:money_tracker/logic/cubit/catalog_cubit.dart';
import 'package:money_tracker/logic/cubit/item_cubit.dart';
import 'package:money_tracker/logic/cubit/setting_cubit.dart';
import 'package:money_tracker/logic/cubit/theme_cubit.dart';
import 'package:money_tracker/logic/cubit/transaction_cubit.dart';
import 'package:money_tracker/logic/debug/app_bloc_observer.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';

late Repository myRepository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  await Hive.initFlutter();
  await registerAndOpenBox();

  Repository myRepository = Repository()..initDefaultApp();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MyApp(
        myRepository: myRepository,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.myRepository}) : super(key: key);
  final Repository myRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationCubit(repository: myRepository),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider(
          create: (context) => TransactionCubit(repository: myRepository)
            ..filteringTransactions()
            ..collectData4Filter()
            ..handleScroll(),
        ),
        BlocProvider(
          create: (context) =>
              ItemCubit(repository: myRepository)..initalItem(),
        ),
        BlocProvider(
          create: (context) =>
              AccountCubit(repository: myRepository)..getAccounts(),
        ),
        BlocProvider(
          create: (context) => CatalogCubit(repository: myRepository)
            ..getAllCatalogOfType(TransactionType.expense),
        ),
        BlocProvider(
          create: (context) =>
              SettingCubit(repository: myRepository)..getSetting(),
        ),
        BlocProvider(
          create: (context) =>
              AnalysisCubit(repository: myRepository)..processing(),
        )
      ],
      child: const DigitalWallet(),
    );
  }
}

class DigitalWallet extends StatefulWidget {
  const DigitalWallet({Key? key}) : super(key: key);

  @override
  _DigitalWalletState createState() => _DigitalWalletState();
}

class _DigitalWalletState extends State<DigitalWallet>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    context.read<ThemeCubit>().updateAppTheme();
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    Hive.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: Strings.appTitle,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: context
              .select((ThemeCubit themeCubit) => themeCubit.state.themeMode),
          debugShowCheckedModeBanner: false,
          initialRoute: AppRouter.login,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
