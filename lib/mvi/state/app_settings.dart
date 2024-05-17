import 'package:russian_rock_song_book/data/settings/font_scale_variant.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/ui/font/app_font.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';

class AppSettings {
  AppTheme theme = AppTheme.themeDark;
  AppTextStyler textStyler = AppTextStyler(AppTheme.themeDark, 1.0);
  FontScaleVariant fontScaleVariant = FontScaleVariant.m;
  ListenToMusicVariant listenToMusicPreference = ListenToMusicVariant.yandexAndYoutube;

  AppSettings();

  AppSettings._newInstance(
      this.theme,
      this.textStyler,
      this.fontScaleVariant,
      this.listenToMusicPreference
      );

  AppSettings copy() => AppSettings._newInstance(
      theme,
      textStyler,
      fontScaleVariant,
      listenToMusicPreference
  );
}