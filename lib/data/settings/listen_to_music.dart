import 'package:shared_preferences/shared_preferences.dart';

enum ListenToMusicOption {
  vk, yandex, youtube
}

class ListenToMusicVariant {
  static final yandexAndYoutube = ListenToMusicVariant('Яндекс и Youtube', [
    ListenToMusicOption.yandex,
    ListenToMusicOption.youtube
  ]);
  static final vkAndYandex = ListenToMusicVariant('VK и Яндекс', [
    ListenToMusicOption.vk,
    ListenToMusicOption.yandex
  ]);
  static final vkAndYoutube = ListenToMusicVariant('VK и Youtube', [
    ListenToMusicOption.vk,
    ListenToMusicOption.youtube
  ]);
  static final allVariants = [yandexAndYoutube, vkAndYandex, vkAndYoutube];

  static const musicKey = 'musicIndex';

  final String description;
  final List<ListenToMusicOption> supportedVariants;

  ListenToMusicVariant(this.description, this.supportedVariants);

  static Future<ListenToMusicVariant> getCurrentPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(musicKey) ?? 0;
    return allVariants[index];
  }

  static Future<void> savePreferenceIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(musicKey, index);
  }

  static int indexFromDescription(String description) =>
      allVariants.indexWhere((element) => element.description == description);
}