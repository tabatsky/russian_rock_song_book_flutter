import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/features/common/widgets/music_button.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';

import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/features/warning_dialog/view/warning_dialog.dart';
import 'package:rxdart/rxdart.dart';

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

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

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
          return _SongTextPageContent(
              appState.settings,
              appState.localState.currentSong,
              _scrollController,
              widget.onPerformAction);
        }
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  void _updateSong(Song? newSong) {
    if (_currentSong != newSong) {
      _currentSong = newSong;
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToTop());
    }
  }

}

class _SongTextPageContent extends StatelessWidget {
  final AppSettings settings;
  final Song? currentSong;
  final ScrollController scrollController;
  final void Function(AppUIAction action) onPerformAction;

  const _SongTextPageContent(this.settings, this.currentSong, this.scrollController, this.onPerformAction);

  @override
  Widget build(BuildContext context) =>  Scaffold(
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
          icon: Image.asset(AppIcons.icLeft),
          iconSize: 50,
          onPressed: () {
            onPerformAction(PrevSong());
          },
        ),
        IconButton(
          icon: Image.asset(currentSong?.favorite == true ? AppIcons.icDelete : AppIcons.icStar),
          iconSize: 50,
          onPressed: () {
            onPerformAction(ToggleFavorite());
          },
        ),
        IconButton(
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
        _SongTextBody(settings, currentSong, scrollController, onPerformAction),
      ],
    ),
  );

}

class _SongTextBody extends StatefulWidget {
  final AppSettings settings;
  final Song? currentSong;
  final ScrollController scrollController;
  final void Function(AppUIAction action) onPerformAction;

  const _SongTextBody(this.settings, this.currentSong, this.scrollController, this.onPerformAction);


  @override
  State<StatefulWidget> createState() => _SongTextBodyState();

}

class _SongTextBodyState extends State<_SongTextBody> {
  bool _isEditorMode = false;
  final _textEditorController = TextEditingController();

  @override
  Widget build(BuildContext context) => Expanded(
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        double buttonSize = width / 7.0;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: EdgeInsets.zero,
                child: Container(
                  constraints: BoxConstraints(minHeight: height, minWidth: width),
                  color: widget.settings.theme.colorBg,
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    children: [
                      Text(widget.currentSong?.title ?? 'null', style: widget.settings.textStyler.textStyleTitle),
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
                        style: widget.settings.textStyler.textStyleSongText,
                      )
                          : Text(
                        widget.currentSong?.text ?? 'null',
                        style: widget.settings.textStyler.textStyleSongText,
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
              color: widget.settings.theme.colorBg,
              child: _ButtonRow(
                  widget.settings.listenToMusicPreference,
                  widget.currentSong,
                  _isEditorMode,
                  buttonSize,
                  _editText,
                  _saveText,
                  widget.onPerformAction),
            ),
            Container(
              width: width,
              height: buttonSize / 2,
              color: widget.settings.theme.colorBg,
            ),
          ],
        );
      },
    ),
  );

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
}

class _ButtonRow extends StatelessWidget {
  final ListenToMusicVariant listenToMusicVariant;
  final Song? currentSong;
  final bool isEditorMode;
  final double buttonSize;
  final void Function(Song? currentSong) onEditText;
  final void Function() onSaveText;
  final void Function(AppUIAction action) onPerformAction;

  const _ButtonRow(
      this.listenToMusicVariant,
      this.currentSong,
      this.isEditorMode,
      this.buttonSize,
      this.onEditText,
      this.onSaveText,
      this.onPerformAction);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      MusicButton(listenToMusicVariant.supportedVariants[0], currentSong?.searchFor ?? 'null', buttonSize, onPerformAction),
      MusicButton(listenToMusicVariant.supportedVariants[1], currentSong?.searchFor ?? 'null', buttonSize, onPerformAction),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icUpload),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            onPerformAction(UploadCurrentToCloud());
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
              onPerformAction(SendWarning(warning));
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
          icon: Image.asset(isEditorMode ? AppIcons.icSave : AppIcons.icEdit),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            if (isEditorMode) {
              onSaveText();
            } else {
              onEditText(currentSong);
            }
          },
        ),
      ),
    ],
  );

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
                onPerformAction(DeleteCurrentToTrash());
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
