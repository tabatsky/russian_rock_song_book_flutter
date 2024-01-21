import 'dart:ui';

class Theme {
  static const colorLightYellow = Color(0xFFFFFFBB);
  static const colorBlack = Color(0xFF000000);
  static const colorDarkYellow = Color(0xFF777755);

  static final themeDark = Theme(colorLightYellow, colorBlack, colorDarkYellow);
  static final themeLight = Theme(colorBlack, colorLightYellow, colorDarkYellow);

  Color colorMain;
  Color colorBg;
  Color colorCommon;

  Theme(this.colorMain, this.colorBg, this.colorCommon);
}