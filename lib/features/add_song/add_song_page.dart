import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/test/test_keys.dart';
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
      {  required this.settings,
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
          Container(
            color: settings.theme.colorBg,
            height: 4,
          ),
          TextField(
            key: const Key(TestKeys.addSongArtistTextField),
            controller: _artistEditingController,
            keyboardType: TextInputType.text,
            maxLines: 1,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: settings.theme.colorMain, width: 1),
              ),
              contentPadding: EdgeInsets.zero,
              fillColor: settings.theme.colorMain,
              filled: true,
              labelText: AppStrings.strSongArtist,
              labelStyle: settings.textStyler.textStyleSmallInverted,
            ),
            style: settings.textStyler.textStyleSongTextInverted,
          ),
          Container(
            color: settings.theme.colorBg,
            height: 4,
          ),
          TextField(
            key: const Key(TestKeys.addSongTitleTextField),
            controller: _titleEditingController,
            keyboardType: TextInputType.text,
            maxLines: 1,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: settings.theme.colorMain, width: 1),
              ),
              contentPadding: EdgeInsets.zero,
              fillColor: settings.theme.colorMain,
              filled: true,
              labelText: AppStrings.strSongTitle,
              labelStyle: settings.textStyler.textStyleSmallInverted,
            ),
            style: settings.textStyler.textStyleSongTextInverted,
          ),
          Container(
            color: settings.theme.colorBg,
            height: 4,
          ),
          Expanded(
              child: TextField(
                key: const Key(TestKeys.addSongTextTextField),
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: settings.theme.colorMain, width: 1),
                  ),
                  contentPadding: EdgeInsets.zero,
                  fillColor: settings.theme.colorMain,
                  filled: true,
                  labelText: AppStrings.strSongText,
                  labelStyle: settings.textStyler.textStyleSmallInverted,
                  alignLabelWithHint: true,
                ),
                style: settings.textStyler.textStyleSongTextInverted,
              ),
          ),
          Container(
            color: settings.theme.colorBg,
            height: 4,
          ),
          TextButton(
            key: const Key(TestKeys.addSongSaveButton),
            onPressed: () {
              _saveSong();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
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