import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/features/chord_dialog/chord_dialog.dart';
import 'package:russian_rock_song_book/features/common/widgets/bottom_button.dart';
import 'package:russian_rock_song_book/features/common/widgets/music_button.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/test/test_keys.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/features/warning_dialog/view/warning_dialog.dart';
import 'package:russian_rock_song_book/features/chord_dialog/all_chords.dart';
import 'package:russian_rock_song_book/ui/widgets/clickable_word_text/clickable_word_text.dart';

class SongTextPage extends StatelessWidget {
  final AppBloc appBloc;
  final void Function(AppUIEvent action) onPerformAction;

  const SongTextPage(
      {super.key, required this.appBloc, required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _SongTextPageContent(
              settings: state.settings,
              isEditorMode: state.localState.isEditorMode,
              isAutoPlayMode: state.localState.isAutoPlayMode,
              currentSong: state.localState.currentSong,
              onPerformAction: onPerformAction);
        });
  }
}

class _SongTextPageContent extends StatelessWidget {
  final AppSettings settings;
  final bool isEditorMode;
  final bool isAutoPlayMode;
  final Song? currentSong;
  final void Function(AppUIEvent action) onPerformAction;

  const _SongTextPageContent(
      {required this.settings,
      required this.isEditorMode,
      required this.isAutoPlayMode,
      required this.currentSong,
      required this.onPerformAction});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: settings.theme.colorBg,
        appBar: AppBar(
          backgroundColor: AppTheme.colorDarkYellow,
          leading: IconButton(
            icon: Image.asset(AppIcons.icBack),
            iconSize: 50,
            onPressed: () {
              onPerformAction(Back());
            },
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                  isAutoPlayMode ? AppIcons.icPause : AppIcons.icPlay),
              iconSize: 50,
              onPressed: () {
                onPerformAction(UpdateAutoPlayMode(!isAutoPlayMode));
              },
            ),
            IconButton(
              key: const Key(TestKeys.leftButton),
              icon: Image.asset(AppIcons.icLeft),
              iconSize: 50,
              onPressed: () {
                onPerformAction(PrevSong());
              },
            ),
            currentSong?.favorite == true
                ? IconButton(
                    key: const Key(TestKeys.deleteFromFavoriteButton),
                    icon: Image.asset(AppIcons.icDelete),
                    iconSize: 50,
                    onPressed: () {
                      onPerformAction(ToggleFavorite());
                    },
                  )
                : IconButton(
                    key: const Key(TestKeys.addToFavoriteButton),
                    icon: Image.asset(AppIcons.icStar),
                    iconSize: 50,
                    onPressed: () {
                      onPerformAction(ToggleFavorite());
                    },
                  ),
            IconButton(
              key: const Key(TestKeys.rightButton),
              icon: Image.asset(AppIcons.icRight),
              iconSize: 50,
              onPressed: () {
                onPerformAction(NextSong());
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _SongTextBody(
                settings: settings,
                isEditorMode: isEditorMode,
                isAutoPlayMode: isAutoPlayMode,
                currentSong: currentSong,
                onPerformAction: onPerformAction),
          ],
        ),
      );
}

class _SongTextBody extends StatefulWidget {
  final AppSettings settings;
  final bool isEditorMode;
  final bool isAutoPlayMode;
  final Song? currentSong;
  final void Function(AppUIEvent action) onPerformAction;

  const _SongTextBody(
      {required this.settings,
      required this.isEditorMode,
      required this.isAutoPlayMode,
      required this.currentSong,
      required this.onPerformAction});

  @override
  State<StatefulWidget> createState() => _SongTextBodyState();
}

class _SongTextBodyState extends State<_SongTextBody> {
  static const deltaY = 10.0;

  final _textEditorController = TextEditingController();

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  Song? _lastSong;
  bool _isAutoPlayMode = false;
  bool _justScrolledToTop = false;
  double _scrollY = 0.0;
  bool _isTappedNow = false;

  @override
  Widget build(BuildContext context) {
    _updateSong(widget.currentSong);
    _updateAutoPlayMode(widget.isAutoPlayMode);
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;

          double buttonSize = isPortrait ? width / 7.0 : height / 7.0;

          final bodyContent = [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: GestureDetector(
                  onTapDown: (details) {
                    _isTappedNow = true;
                  },
                  onTapUp: (details) {
                    _isTappedNow = false;
                  },
                  onVerticalDragStart: (details) {
                    _isTappedNow = true;
                  },
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
                            widget.currentSong?.title ?? '',
                            style: widget.settings.textStyler.textStyleTitle,
                            key: const Key(TestKeys.songTextTitle),
                          ),
                          Container(
                            height: 20,
                          ),
                          widget.isEditorMode
                              ? TextField(
                                  key: const Key(TestKeys.songTextEditor),
                                  controller: _textEditorController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: widget
                                      .settings.textStyler.textStyleSongText,
                                )
                              : ClickableWordText(
                                  text: widget.currentSong?.text ?? '',
                                  actualWords: AllChords.chordsNames,
                                  actualMappings: AllChords.chordMappings,
                                  onWordTap: (word) {
                                    ChordDialog.showChordDialog(
                                        context, widget.settings, word);
                                  },
                                  style1: widget
                                      .settings.textStyler.textStyleSongText,
                                  style2:
                                      widget.settings.textStyler.textStyleChord,
                                  textKey: const Key(TestKeys.songTextText),
                                ),
                          Container(
                            height: 80,
                          ),
                        ],
                      ),
                    ),
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
                  currentSong: widget.currentSong,
                  isEditorMode: widget.isEditorMode,
                  buttonSize: buttonSize,
                  onEditText: _editText,
                  onSaveText: _saveText,
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

  Future<void> _editText(Song? currentSong) async {
    _textEditorController.text = currentSong?.text ?? '';
    widget.onPerformAction(UpdateEditorMode(true));
  }

  Future<void> _saveText() async {
    final updatedText = _textEditorController.text;
    widget.onPerformAction(UpdateEditorMode(false));
    widget.onPerformAction(SaveSongText(updatedText));
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final newY = notification.metrics.extentBefore;
    if ((newY - _scrollY).abs() > 5 * deltaY) {
      _scrollY = newY;
      _isTappedNow = false;
    }
    return false;
  }

  void _scrollToTop() {
    _justScrolledToTop = true;
    _scrollY = 0.0;
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  void _updateSong(Song? newSong) {
    if (_lastSong?.title != newSong?.title ||
        _lastSong?.artist != newSong?.artist) {
      _lastSong = newSong;
      widget.onPerformAction(UpdateEditorMode(false));
      widget.onPerformAction(UpdateAutoPlayMode(false));
      _textEditorController.text = newSong?.text ?? '';
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToTop());
    }
  }

  void _updateAutoPlayMode(bool isAutoPlayMode) {
    if (!_isAutoPlayMode && isAutoPlayMode) {
      _startAutoPlay();
    }
    _isAutoPlayMode = isAutoPlayMode;
  }

  Future<void> _startAutoPlay() async {
    _justScrolledToTop = false;
    _isTappedNow = false;
    do {
      await Future.delayed(const Duration(milliseconds: 250));
      if (_justScrolledToTop) break;
      if (!_isTappedNow) {
        _scrollY += deltaY;
        if (_scrollY > _scrollController.position.maxScrollExtent) {
          _scrollY = _scrollController.position.maxScrollExtent;
        }
        _scrollController.animateTo(_scrollY,
            duration: const Duration(milliseconds: 1), curve: Curves.linear);
      }
    } while (_isAutoPlayMode);
  }
}

class _ButtonPanel extends StatelessWidget {
  final AppSettings settings;
  final bool isPortrait;
  final ListenToMusicVariant listenToMusicVariant;
  final Song? currentSong;
  final bool isEditorMode;
  final double buttonSize;
  final void Function(Song? currentSong) onEditText;
  final void Function() onSaveText;
  final void Function(AppUIEvent action) onPerformAction;

  const _ButtonPanel(
      {required this.settings,
      required this.isPortrait,
      required this.listenToMusicVariant,
      required this.currentSong,
      required this.isEditorMode,
      required this.buttonSize,
      required this.onEditText,
      required this.onSaveText,
      required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      MusicButton(
          option: listenToMusicVariant.supportedVariants[0],
          searchFor: currentSong?.searchFor ?? 'null',
          buttonSize: buttonSize,
          onPerformAction: onPerformAction),
      MusicButton(
          option: listenToMusicVariant.supportedVariants[1],
          searchFor: currentSong?.searchFor ?? 'null',
          buttonSize: buttonSize,
          onPerformAction: onPerformAction),
      BottomButton(
          icon: AppIcons.icUpload,
          buttonSize: buttonSize,
          onPressed: () {
            onPerformAction(UploadCurrentToCloud());
          }),
      BottomButton(
          buttonKey: const Key(TestKeys.warningButton),
          icon: AppIcons.icWarning,
          buttonSize: buttonSize,
          onPressed: () {
            WarningDialog.showWarningDialog(context, settings, (comment) {
              final warning =
                  Warning.fromSongWithComment(currentSong!, comment);
              onPerformAction(SendWarning(warning));
            });
          }),
      BottomButton(
          icon: AppIcons.icTrash,
          buttonSize: buttonSize,
          onPressed: () {
            _showDeleteToTrashConfirmDialog(context, settings);
          }),
      isEditorMode
          ? BottomButton(
              icon: AppIcons.icSave,
              buttonSize: buttonSize,
              onPressed: () {
                onSaveText();
              },
              buttonKey: const Key(TestKeys.saveButton))
          : BottomButton(
              icon: AppIcons.icEdit,
              buttonSize: buttonSize,
              onPressed: () {
                onEditText(currentSong);
              },
              buttonKey: const Key(TestKeys.editButton)),
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

  Future<void> _showDeleteToTrashConfirmDialog(
      BuildContext context, AppSettings settings) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.strAreYouSure,
              style: settings.textStyler.textStyleSmallTitleBlack),
          backgroundColor: settings.theme.colorCommon,
          surfaceTintColor: Colors.black,
          content: Text(AppStrings.strWillBeRemoved,
              style: settings.textStyler.textStyleSmallBlack),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings.strYes,
                  style: settings.textStyler.textStyleSmallBlack),
              onPressed: () {
                onPerformAction(DeleteCurrentToTrash());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppStrings.strNo,
                  style: settings.textStyler.textStyleSmallBlack),
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
