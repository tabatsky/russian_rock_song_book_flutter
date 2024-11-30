import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';

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
  TextStyle get textStyleCommonBlack => TextStyle(
      color: AppTheme.materialBlack, fontSize: fontSizeCommon);
  TextStyle get textStyleCommonInverted => TextStyle(
      color: theme.colorBg, fontSize: fontSizeCommon);
  TextStyle get textStyleCommonInvertedBold => TextStyle(
      color: theme.colorBg, fontSize: fontSizeCommon, fontWeight: FontWeight.bold);
  TextStyle get textStyleCommonInvertedW500 => TextStyle(
      color: theme.colorBg, fontSize: fontSizeCommon, fontWeight: FontWeight.w500);
  TextStyle get textStyleFixedBlackBold => const TextStyle(
      color: AppTheme.materialBlack, fontSize: fontSizeFixed, fontWeight: FontWeight.bold);
  TextStyle get textStyleTitle => TextStyle(
      color: theme.colorMain, fontSize: fontSizeTitle);
  TextStyle get textStyleTitleBlack => TextStyle(
      color: AppTheme.materialBlack, fontSize: fontSizeTitle);
  TextStyle get textStyleSmallTitle => TextStyle(
      color: theme.colorMain, fontSize: fontSizeSmallTitle);
  TextStyle get textStyleSmallTitleBlack => TextStyle(
      color: AppTheme.materialBlack, fontSize: fontSizeSmallTitle);
  TextStyle get textStyleSmall => TextStyle(
      color: theme.colorMain, fontSize: fontSizeSmall);
  TextStyle get textStyleSmallBlack => TextStyle(
      color: AppTheme.materialBlack, fontSize: fontSizeSmall);
  TextStyle get textStyleSongText => TextStyle(
    color: theme.colorMain,
    fontFamily: 'monospace',
    fontFamilyFallback: const <String>["Courier"],
    fontSize: fontSizeCommon,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  TextStyle get textStyleChord => TextStyle(
    color: theme.colorBg,
    backgroundColor: theme.colorMain,
    fontFamily: 'monospace',
    fontFamilyFallback: const <String>["Courier"],
    fontSize: fontSizeCommon,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
