import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/features/chord_dialog/all_chords.dart';
import 'package:russian_rock_song_book/features/chord_dialog/chord_dialog.dart';
import 'package:russian_rock_song_book/features/common/widgets/bottom_button.dart';
import 'package:russian_rock_song_book/features/common/widgets/music_button.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/cloud_state.dart';
import 'package:russian_rock_song_book/test/test_keys.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/features/warning_dialog/view/warning_dialog.dart';
import 'package:russian_rock_song_book/ui/widgets/clickable_word_text/clickable_word_text.dart';

class CloudSongTextPage extends StatelessWidget {
  final AppBloc appBloc;
  final void Function(AppUIEvent action) onPerformAction;

  const CloudSongTextPage(
      {super.key, required this.appBloc, required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _CloudSongTextPageContent(
              settings: state.settings,
              cloudState: state.cloudState,
              onPerformAction: onPerformAction);
        });
  }
}

class _CloudSongTextPageContent extends StatelessWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final void Function(AppUIEvent action) onPerformAction;

  const _CloudSongTextPageContent(
      {super.key,
      required this.settings,
      required this.cloudState,
      required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        leading: IconButton(
          key: const Key(TestKeys.backButton),
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            onPerformAction(Back());
          },
        ),
        actions: [
          IconButton(
            key: const Key(TestKeys.leftButton),
            icon: Image.asset(AppIcons.icLeft),
            iconSize: 50,
            onPressed: () {
              onPerformAction(PrevCloudSong());
            },
          ),
          Text(
            "${cloudState.currentCloudSongPosition + 1} / ${cloudState.currentCloudSongCount}",
            style: settings.textStyler.textStyleFixedBlackBold,
          ),
          IconButton(
            key: const Key(TestKeys.rightButton),
            icon: Image.asset(AppIcons.icRight),
            iconSize: 50,
            onPressed: () {
              onPerformAction(NextCLoudSong());
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _CloudSongTextBody(
              settings: settings,
              cloudState: cloudState,
              onPerformAction: onPerformAction),
        ],
      ),
    );
  }
}

class _CloudSongTextBody extends StatefulWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final void Function(AppUIEvent action) onPerformAction;

  const _CloudSongTextBody(
      {super.key,
      required this.settings,
      required this.cloudState,
      required this.onPerformAction});

  @override
  State<StatefulWidget> createState() => _CloudSongTextBodyState();
}

class _CloudSongTextBodyState extends State<_CloudSongTextBody> {
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  CloudSong? _currentCloudSong;

  @override
  Widget build(BuildContext context) {
    _updateCloudSong(widget.cloudState.currentCloudSong);
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;

          double buttonSize = isPortrait ? width / 7.0 : height / 7.0;

          final extraLikes = widget.cloudState.extraLikesForCurrent;
          final extraDislikes = widget.cloudState.extraDislikesForCurrent;

          final bodyContent = [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                child: Container(
                  constraints:
                      BoxConstraints(minHeight: height, minWidth: width),
                  color: widget.settings.theme.colorBg,
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    children: [
                      Text(
                        widget.cloudState.currentCloudSong
                                ?.visibleTitleWithArtistAndRating(
                                    extraLikes, extraDislikes) ??
                            '',
                        style: widget.settings.textStyler.textStyleTitle,
                        key: const Key(TestKeys.cloudSongTextTitle),
                      ),
                      Container(
                        height: 20,
                      ),
                      ClickableWordText(
                        text: widget.cloudState.currentCloudSong?.text ?? '',
                        actualWords: AllChords.chordsNames,
                        actualMappings: AllChords.chordMappings,
                        onWordTap: (word) {
                          ChordDialog.showChordDialog(
                              context, widget.settings, word);
                        },
                        style1: widget.settings.textStyler.textStyleSongText,
                        style2: widget.settings.textStyler.textStyleChord,
                        textKey: const Key(TestKeys.cloudSongTextText),
                      ),
                      Container(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: isPortrait ? width : buttonSize,
              height: isPortrait ? buttonSize : height,
              color: widget.settings.theme.colorBg,
              child: _ButtonPanel(
                  settings: widget.settings,
                  isPortrait: isPortrait,
                  listenToMusicVariant: widget.settings.listenToMusicPreference,
                  currentCloudSong: widget.cloudState.currentCloudSong,
                  buttonSize: buttonSize,
                  onPerformAction: widget.onPerformAction),
            ),
          ];

          return isPortrait
              ? Column(children: bodyContent)
              : Row(children: bodyContent);
        },
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  void _updateCloudSong(CloudSong? newCloudSong) {
    if (_currentCloudSong != newCloudSong) {
      _currentCloudSong = newCloudSong;
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToTop());
    }
  }
}

class _ButtonPanel extends StatelessWidget {
  final AppSettings settings;
  final bool isPortrait;
  final ListenToMusicVariant listenToMusicVariant;
  final CloudSong? currentCloudSong;
  final double buttonSize;
  final void Function(AppUIEvent action) onPerformAction;

  const _ButtonPanel(
      {super.key,
      required this.settings,
      required this.isPortrait,
      required this.listenToMusicVariant,
      required this.currentCloudSong,
      required this.buttonSize,
      required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      MusicButton(
          option: listenToMusicVariant.supportedVariants[0],
          searchFor: currentCloudSong?.searchFor ?? 'null',
          buttonSize: buttonSize,
          onPerformAction: onPerformAction),
      MusicButton(
          option: listenToMusicVariant.supportedVariants[1],
          searchFor: currentCloudSong?.searchFor ?? 'null',
          buttonSize: buttonSize,
          onPerformAction: onPerformAction),
      BottomButton(
          icon: AppIcons.icDownload,
          buttonSize: buttonSize,
          onPressed: () {
            onPerformAction(DownloadCurrent());
          }),
      BottomButton(
          buttonKey: const Key(TestKeys.warningButton),
          icon: AppIcons.icWarning,
          buttonSize: buttonSize,
          onPressed: () {
            WarningDialog.showWarningDialog(context, settings, (comment) {
              final warning =
                  Warning.fromCloudSongWithComment(currentCloudSong!, comment);
              onPerformAction(SendWarning(warning));
            });
          }),
      BottomButton(
          buttonKey: const Key(TestKeys.likeButton),
          icon: AppIcons.icLike,
          buttonSize: buttonSize,
          onPressed: () {
            onPerformAction(LikeCurrent());
          }),
      BottomButton(
          buttonKey: const Key(TestKeys.dislikeButton),
          icon: AppIcons.icDislike,
          buttonSize: buttonSize,
          onPressed: () {
            onPerformAction(DislikeCurrent());
          }),
    ];

    return isPortrait
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buttons,
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buttons,
          );
  }
}
