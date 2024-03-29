import 'package:flutter/material.dart';

class AppTheme {
  static const materialBlack = MaterialColor(
    0xFF000000,
    <int, Color>{
      50: Color(0xFF000000),
      100: Color(0xFF000000),
      200: Color(0xFF000000),
      300: Color(0xFF000000),
      400: Color(0xFF000000),
      500: Color(0xFF000000),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    },
  );

  static const colorLightYellow = Color(0xFFFFFFBB);
  static const colorDarkYellow = Color(0xFF777755);

  static final themeDark = AppTheme('Темная', colorLightYellow, materialBlack, colorDarkYellow);
  static final themeLight = AppTheme('Светлая', materialBlack, colorLightYellow, colorDarkYellow);

  static final allThemes = [themeDark, themeLight];

  final String description;
  final Color colorMain;
  final Color colorBg;
  final Color colorCommon;

  AppTheme(this.description, this.colorMain, this.colorBg, this.colorCommon);

  static AppTheme getByIndex(int index) => allThemes[index];

  static int indexFromDescription(String description) =>
      allThemes.indexWhere((element) => element.description == description);
}
