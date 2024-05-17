import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/mvi/actions/app_events.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';

class MusicButton extends StatelessWidget {
  final ListenToMusicOption option;
  final String searchFor;
  final double buttonSize;
  final void Function(AppUIEvent action) onPerformAction;

  const MusicButton(this.option, this.searchFor, this.buttonSize, this.onPerformAction, {super.key});

  @override
  Widget build(BuildContext context) {
    final String icon;
    final AppUIEvent action;

    switch (option) {
      case ListenToMusicOption.vk:
        icon = AppIcons.icVk;
        action = OpenVkMusic(searchFor);
      case ListenToMusicOption.yandex:
        icon = AppIcons.icYandex;
        action = OpenYandexMusic(searchFor);
      case ListenToMusicOption.youtube:
        icon = AppIcons.icYoutube;
        action = OpenYoutubeMusic(searchFor);
    }

    return Container(
      width: buttonSize,
      height: buttonSize,
      color: AppTheme.colorDarkYellow,
      child:
      IconButton(
        icon: Image.asset(icon),
        padding: const EdgeInsets.all(8),
        onPressed: () {
          onPerformAction(action);
        },
      ),
    );
  }
}