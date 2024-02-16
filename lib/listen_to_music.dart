import 'package:shared_preferences/shared_preferences.dart';

enum ListenToMusicVariant {
  vk, yandex, youtube
}

class ListenToMusicPreference {
  static final yandexAndYoutube = ListenToMusicPreference([
    ListenToMusicVariant.yandex,
    ListenToMusicVariant.youtube
  ]);
  static final vkAndYandex = ListenToMusicPreference([
    ListenToMusicVariant.vk,
    ListenToMusicVariant.yandex
  ]);
  static final vkAndYoutube = ListenToMusicPreference([
    ListenToMusicVariant.vk,
    ListenToMusicVariant.youtube
  ]);
  static final allVariants = [yandexAndYoutube, vkAndYandex, vkAndYoutube];

  static const musicKey = 'musicIndex';

  final List<ListenToMusicVariant> supportedVariants;

  ListenToMusicPreference(this.supportedVariants);

  static Future<ListenToMusicPreference> getCurrentPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(musicKey) ?? 0;
    return allVariants[index];
  }
}