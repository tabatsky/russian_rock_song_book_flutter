import 'package:flutter/material.dart';

import 'package:russian_rock_song_book/app_icons.dart';
import 'package:russian_rock_song_book/app_strings.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/listen_to_music.dart';
import 'package:russian_rock_song_book/warning.dart';
import 'package:russian_rock_song_book/warning_dialog.dart';
import 'package:rxdart/rxdart.dart';

import 'app_actions.dart';
import 'app_state.dart';
import 'song.dart';

class SongTextPage extends StatefulWidget {

  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  const SongTextPage(
      this.appStateStream,
      this.onPerformAction,
      {super.key});

  @override
  State<StatefulWidget> createState() => _SongTextPageState();

}

class _SongTextPageState extends State<SongTextPage> {

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  bool _isEditorMode = false;
  final _textEditorController = TextEditingController();

  Song? _currentSong;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: widget.appStateStream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return Container();
          }
          _updateSong(appState.localState.currentSong);
          return _makePage(context, appState.theme, appState.listenToMusicPreference, appState.localState.currentSong);
        }
    );
  }

  void _scrollToTop() {
    scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  void _updateSong(Song? newSong) {
    if (_currentSong != newSong) {
      _currentSong = newSong;
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToTop());
    }
  }

  Widget _makePage(BuildContext context, AppTheme theme, ListenToMusicPreference listenToMusicPreference, Song? currentSong) {
    return Scaffold(
      backgroundColor: theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            widget.onPerformAction(Back());
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(AppIcons.icLeft),
            iconSize: 50,
            onPressed: () {
              widget.onPerformAction(PrevSong());
            },
          ),
          IconButton(
            icon: Image.asset(currentSong?.favorite == true ? AppIcons.icDelete : AppIcons.icStar),
            iconSize: 50,
            onPressed: () {
              widget.onPerformAction(ToggleFavorite());
            },
          ),
          IconButton(
            icon: Image.asset(AppIcons.icRight),
            iconSize: 50,
            onPressed: () {
              widget.onPerformAction(NextSong());
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _makeSongTextView(context, theme, listenToMusicPreference, currentSong),
        ],
      ),
    );
  }

  Widget _makeSongTextView(BuildContext context, AppTheme theme, ListenToMusicPreference listenToMusicPreference, Song? currentSong) {
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          double buttonSize = width / 7.0;
          final textStyle = TextStyle(
              color: theme.colorMain,
              fontFamily: 'monospace',
              fontFamilyFallback: const <String>["Courier"],
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  child: Container(
                    constraints: BoxConstraints(minHeight: height, minWidth: width),
                    color: theme.colorBg,
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      children: [
                        Text(currentSong?.title ?? 'null', style: TextStyle(color: theme.colorMain, fontSize: 24)),
                        Container(
                          height: 20,
                        ),
                        _isEditorMode
                        ? TextField(
                          controller: _textEditorController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: textStyle,
                        )
                        : Text(
                            currentSong?.text ?? 'null',
                            style: textStyle,
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
                width: width,
                height: buttonSize,
                color: theme.colorBg,
                child: _bottomButtonRow(buttonSize, listenToMusicPreference, currentSong),
              ),
              Container(
                width: width,
                height: buttonSize / 2,
                color: theme.colorBg,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomButtonRow(double buttonSize, ListenToMusicPreference listenToMusicPreference, Song? currentSong) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _makeMusicButton(listenToMusicPreference.supportedVariants[0], currentSong, buttonSize),
      _makeMusicButton(listenToMusicPreference.supportedVariants[1], currentSong, buttonSize),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icUpload),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            widget.onPerformAction(UploadCurrentToCloud());
          },
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icWarning),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            WarningDialog.showWarningDialog(context, (comment) {
              final warning = Warning.fromSongWithComment(currentSong!, comment);
              widget.onPerformAction(SendWarning(warning));
            });
          },
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icTrash),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            _showDeleteToTrashConfirmDialog(context);
          },
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(_isEditorMode ? AppIcons.icSave : AppIcons.icEdit),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            if (_isEditorMode) {
              _saveText();
            } else {
              _editText(currentSong);
            }
          },
        ),
      ),
    ],
  );

  Widget _makeMusicButton(ListenToMusicVariant variant, Song? currentSong, double buttonSize) {
    final String icon;
    final AppUIAction action;

    switch (variant) {
      case ListenToMusicVariant.vk:
        icon = AppIcons.icVk;
        action = OpenVkMusic(
            currentSong?.searchFor ?? 'null'
        );
      case ListenToMusicVariant.yandex:
        icon = AppIcons.icYandex;
        action = OpenYandexMusic(
            currentSong?.searchFor ?? 'null'
        );
      case ListenToMusicVariant.youtube:
        icon = AppIcons.icYoutube;
        action = OpenYoutubeMusic(
            currentSong?.searchFor ?? 'null'
        );
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
          widget.onPerformAction(action);
        },
      ),
    );
  }

  Future<void> _editText(Song? currentSong) async {
    _textEditorController.text = currentSong?.text ?? 'null';
    setState(() {
      _isEditorMode = true;
    });
  }

  Future<void> _saveText() async {
    final updatedText = _textEditorController.text;
    widget.onPerformAction(SaveSongText(updatedText));
    setState(() {
      _isEditorMode = false;
    });
  }

  Future<void> _showDeleteToTrashConfirmDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.strAreYouSure),
          content: const Text(AppStrings.strWillBeRemoved),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(AppStrings.strYes),
              onPressed: () {
                widget.onPerformAction(DeleteCurrentToTrash());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(AppStrings.strNo),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}