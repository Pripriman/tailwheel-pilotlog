import 'package:flutter/material.dart';
import 'log_palette.dart';

class LogType {
  static const String family = 'Nunito';
  static const String monoFamily = 'monospace';

  static TextStyle _n(
    double wght,
    double size, {
    double? height,
    double? spacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: family,
      fontVariations: [FontVariation('wght', wght)],
      fontWeight: wght >= 700
          ? FontWeight.w700
          : (wght >= 600 ? FontWeight.w600 : FontWeight.w400),
      fontSize: size,
      height: height,
      letterSpacing: spacing,
      color: color ?? LogPalette.ink,
    );
  }

  static TextStyle masthead({Color? color}) =>
      _n(800, 26, height: 1.12, spacing: 0.4, color: color);
  static TextStyle title({Color? color}) =>
      _n(800, 21, height: 1.16, spacing: 0.2, color: color);
  static TextStyle heading({Color? color}) =>
      _n(700, 16, height: 1.2, spacing: 0.2, color: color);
  static TextStyle body({Color? color}) =>
      _n(400, 15, height: 1.42, color: color ?? LogPalette.inkSoft);
  static TextStyle bodyStrong({Color? color}) =>
      _n(600, 15, height: 1.4, color: color);
  static TextStyle label({Color? color}) =>
      _n(700, 12, spacing: 0.9, color: color);
  static TextStyle caption({Color? color}) =>
      _n(600, 11.5, spacing: 0.5, color: color ?? LogPalette.inkFaint);

  static TextStyle hours(double size, {Color? color}) => TextStyle(
        fontFamily: monoFamily,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w700,
        fontSize: size,
        height: 1.0,
        letterSpacing: -0.5,
        color: color ?? LogPalette.ink,
      );

  static TextStyle monoLabel({Color? color}) => TextStyle(
        fontFamily: monoFamily,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
        letterSpacing: 0.2,
        color: color ?? LogPalette.inkSoft,
      );
}
