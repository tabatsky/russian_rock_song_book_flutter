import 'dart:ui';

class AppTheme {
  static const colorLightYellow = Color(0xFFFFFFBB);
  static const colorBlack = Color(0xFF000000);
  static const colorDarkYellow = Color(0xFF777755);

  static final themeDark = AppTheme(colorLightYellow, colorBlack, colorDarkYellow);
  static final themeLight = AppTheme(colorBlack, colorLightYellow, colorDarkYellow);

  Color colorMain;
  Color colorBg;
  Color colorCommon;

  AppTheme(this.colorMain, this.colorBg, this.colorCommon);
}