import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color secondary = const Color(0xFFAA76FF);
  static Color primaryColor = const Color(0xff572cd8);

  static Color lightBackgroundColor = Colors.white;
  static Color lightGreenColor = const Color(0xFF0AFFA7);
  static Color lightRedColor = const Color(0xFFFF3267);

  static Color darkBackgroundColor = const Color(0xFF15202A);
  static Color darkGreenColor = const Color(0xFF4BB33E);
  static Color darkRedColor = const Color(0xFFB32208);
  static Color dartCard = const Color(0xFF1A2935);

  const AppTheme._();

  static final lightTheme = ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondary,
    ),
    primaryColor: primaryColor,
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    selectedRowColor: primaryColor,
  );

  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark().copyWith(
      primary: primaryColor,
      secondary: secondary,
    ),
    primaryColor: primaryColor,
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardColor: dartCard,
    scaffoldBackgroundColor: darkBackgroundColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkBackgroundColor,
    ),
    dialogBackgroundColor: darkBackgroundColor,
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: darkBackgroundColor),
    selectedRowColor: primaryColor,
    canvasColor: darkBackgroundColor,
    timePickerTheme: TimePickerThemeData(
      backgroundColor: darkBackgroundColor,
      dialBackgroundColor: dartCard,
      hourMinuteColor: dartCard,
    ),
  );

  static Brightness get currentSystemBrightness =>
      SchedulerBinding.instance!.window.platformBrightness;

  static setStatusBarAndNavigationBarColors(ThemeMode themeMode) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: themeMode == ThemeMode.light
            ? lightBackgroundColor
            : darkBackgroundColor,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}

extension ThemeExtras on ThemeData {
  Color get redColor => brightness == Brightness.light
      ? AppTheme.lightRedColor
      : AppTheme.darkRedColor;

  Color get greenColor => brightness == Brightness.light
      ? AppTheme.lightGreenColor
      : AppTheme.darkGreenColor;
}
