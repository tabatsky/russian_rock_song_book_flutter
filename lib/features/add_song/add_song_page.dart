import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';

class AddSongPage extends StatelessWidget {
  final AppBloc appBloc;
  final void Function(AppUIEvent action) onPerformAction;

  const AddSongPage(
      {super.key, required this.appBloc, required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _AddSongPageContent(
              settings: state.settings,
              appState: state,
              onPerformAction: onPerformAction);
        });
  }
}

class _AddSongPageContent extends StatelessWidget {
  final AppSettings settings;
  final AppState appState;
  final void Function(AppUIEvent action) onPerformAction;

  final _artistEditingController = TextEditingController();
  final _titleEditingController = TextEditingController();
  final _textEditingController = TextEditingController();

  _AddSongPageContent(
      {super.key,
        required this.settings,
        required this.appState,
        required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(SongRepository.artistAddSong,
            style: settings.textStyler.textStyleFixedBlackBold),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            onPerformAction(Back());
          },
        ),
      ),
      body: Column(
        children: [
          TextField(
            controller: _artistEditingController,
            keyboardType: TextInputType.text,
            maxLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.zero,
              hintText: AppStrings.strSongArtist,
            ),
            style: settings.textStyler.textStyleSongText,
          ),
          TextField(
            controller: _titleEditingController,
            keyboardType: TextInputType.text,
            maxLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.zero,
              hintText: AppStrings.strSongTitle,
            ),
            style: settings.textStyler.textStyleSongText,
          ),
          Expanded(
              child: TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                  hintText: AppStrings.strSongText,
                ),
                style: settings.textStyler.textStyleSongText,
              ),
          ),
          TextButton(
            onPressed: () {
              _saveSong();
            },
            child: Container(
              color: settings.theme.colorCommon,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(AppStrings.strSave,
                      style: settings.textStyler.textStyleTitleBlack),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSong() {
    final artist = _artistEditingController.text.trim();
    final title = _titleEditingController.text.trim();
    final text = _textEditingController.text;
    if (artist.isEmpty || title.isEmpty || text.trim().isEmpty) {
      onPerformAction(ShowToast(AppStrings.strToastFillAllFields));
    } else {
      final song = Song(artist: artist, title: title, text: text);
      onPerformAction(AddNewSong(song));
    }
  }
}