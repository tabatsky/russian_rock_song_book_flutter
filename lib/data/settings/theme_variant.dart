import 'package:shared_preferences/shared_preferences.dart';

class ThemeVariant {
  static const themeKey = 'themeIndex';

  static Future<int> getCurrentThemeIndex() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(themeKey) ?? 0;
    return index;
  }

  static Future<void> saveThemeIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeKey, index);
  }
}