import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppTextStyler {
  final AppTheme theme;
  final double fontScale;

  AppTextStyler(this.theme, this.fontScale);

  double get fontSizeCommon => fontScale * 20;
  double get fontSizeTitle => fontScale * 32;

  TextStyle get textStyleCommon => TextStyle(
      color: theme.colorMain, fontSize: fontSizeCommon);
  TextStyle get textStyleTitle => TextStyle(
      color: theme.colorMain, fontSize: fontSizeTitle);
  TextStyle get textStyleSongText => TextStyle(
    color: theme.colorMain,
    fontFamily: 'monospace',
    fontFamilyFallback: const <String>["Courier"],
    fontSize: fontSizeCommon,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}