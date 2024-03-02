import 'package:shared_preferences/shared_preferences.dart';

enum ListenToMusicVariant {
  vk, yandex, youtube
}

class ListenToMusicPreference {
  static final yandexAndYoutube = ListenToMusicPreference('Яндекс и Youtube', [
    ListenToMusicVariant.yandex,
    ListenToMusicVariant.youtube
  ]);
  static final vkAndYandex = ListenToMusicPreference('VK и Яндекс', [
    ListenToMusicVariant.vk,
    ListenToMusicVariant.yandex
  ]);
  static final vkAndYoutube = ListenToMusicPreference('VK и Youtube', [
    ListenToMusicVariant.vk,
    ListenToMusicVariant.youtube
  ]);
  static final allVariants = [yandexAndYoutube, vkAndYandex, vkAndYoutube];

  static const musicKey = 'musicIndex';

  final String description;
  final List<ListenToMusicVariant> supportedVariants;

  ListenToMusicPreference(this.description, this.supportedVariants);

  static Future<ListenToMusicPreference> getCurrentPreference() async {
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