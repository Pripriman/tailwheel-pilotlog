import 'package:flutter/material.dart';
import 'log_palette.dart';
import 'log_type.dart';

class LogbookTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: LogPalette.navy,
      primary: LogPalette.navy,
      secondary: LogPalette.gold,
      surface: LogPalette.sheet,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: LogPalette.paper,
      fontFamily: LogType.family,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: LogPalette.ink,
      ),
      cardTheme: CardThemeData(
        color: LogPalette.sheet,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: LogPalette.rule),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: LogPalette.rule,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LogPalette.sheet,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: LogType.body(color: LogPalette.inkFaint),
        border: _inputBorder(LogPalette.rule),
        enabledBorder: _inputBorder(LogPalette.rule),
        focusedBorder: _inputBorder(LogPalette.navy),
        errorBorder: _inputBorder(LogPalette.expired),
        focusedErrorBorder: _inputBorder(LogPalette.expired),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: LogPalette.navyDeep,
        contentTextStyle: LogType.bodyStrong(color: Colors.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c, width: 1.3),
      );
}
