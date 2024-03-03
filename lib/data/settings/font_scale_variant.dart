import 'package:shared_preferences/shared_preferences.dart';

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