import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class AppTextStyler {
  final AppTheme theme;
  final double fontScale;

  AppTextStyler(this.theme, this.fontScale);

  double get fontSizeCommon => fontScale * 20;
  double get fontSizeTitle => fontScale * 32;
  double get fontSizeSmallTitle => fontScale * 24;
  double get fontSizeSmall => fontScale * 16;
  static const double fontSizeFixed = 24;

  TextStyle get textStyleCommon => TextStyle(
      color: theme.colorMain, fontSize: fontSizeCommon);
  TextStyle get textStyleCommonInverted => TextStyle(
      color: theme.colorBg, fontSize: fontSizeCommon);
  TextStyle get textStyleCommonInvertedBold => TextStyle(
      color: theme.colorBg, fontSize: fontSizeCommon, fontWeight: FontWeight.bold);
  TextStyle get textStyleFixedBlackBold => const TextStyle(
      color: AppTheme.materialBlack, fontSize: fontSizeFixed, fontWeight: FontWeight.bold);
  TextStyle get textStyleTitle => TextStyle(
      color: theme.colorMain, fontSize: fontSizeTitle);
  TextStyle get textStyleSmallTitle => TextStyle(
      color: theme.colorMain, fontSize: fontSizeSmallTitle);
  TextStyle get textStyleSmall => TextStyle(
      color: theme.colorMain, fontSize: fontSizeSmall);
  TextStyle get textStyleSongText => TextStyle(
    color: theme.colorMain,
    fontFamily: 'monospace',
    fontFamilyFallback: const <String>["Courier"],
    fontSize: fontSizeCommon,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}

class FontScaleVariant {
  static final xs = FontScaleVariant('Очень мелкий', 0.6);
  static final s = FontScaleVariant('Мелкий', 0.8);
  static final m = FontScaleVariant('Средний', 1.0);
  static final l = FontScaleVariant('Крупный', 1.25);
  static final xl = FontScaleVariant('Очень крупный', 1.5);

  static final allVariants = [xs, s, m, l, xl];

  static const fontScaleKey = 'fontScaleIndex';

  final String description;
  final double fontScale;

  FontScaleVariant(this.description, this.fontScale);

  static Future<FontScaleVariant> getCurrentPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(fontScaleKey) ?? 2;
    return allVariants[index];
  }

  static Future<void> savePreferenceIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(fontScaleKey, index);
  }

  static int indexFromDescription(String description) =>
      allVariants.indexWhere((element) => element.description == description);
}