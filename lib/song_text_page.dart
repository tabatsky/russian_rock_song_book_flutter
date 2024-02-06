import 'package:flutter/material.dart';

import 'package:russian_rock_song_book/app_icons.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/app_theme.dart';

import 'app_actions.dart';

class SongTextPage extends StatefulWidget {

  final AppTheme theme;
  final Song? currentSong;
  final void Function(UIAction action) onPerformAction;

  const SongTextPage(
      this.theme,
      this.currentSong,
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

  void _scrollToTop() {
    scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  @override
  void didUpdateWidget(SongTextPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorBg,
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
            icon: Image.asset(widget.currentSong?.favorite == true ? AppIcons.icDelete : AppIcons.icStar),
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
          _makeSongTextView(context),
        ],
      ),
    );
  }

  Widget _makeSongTextView(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          double buttonSize = width / 7.0;
          final textStyle = TextStyle(
              color: widget.theme.colorMain,
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
                    color: widget.theme.colorBg,
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      children: [
                        Text(widget.currentSong?.title ?? 'null', style: TextStyle(color: widget.theme.colorMain, fontSize: 24)),
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
                            widget.currentSong?.text ?? 'null',
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
                color: widget.theme.colorBg,
                child: _bottomButtonRow(buttonSize),
              ),
              Container(
                width: width,
                height: buttonSize / 2,
                color: widget.theme.colorBg,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomButtonRow(double buttonSize) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icVk),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            widget.onPerformAction(OpenVkMusic(
                widget.currentSong?.searchFor ?? 'null'
            ));
          },
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icYoutube),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            widget.onPerformAction(OpenYoutubeMusic(
                widget.currentSong?.searchFor ?? 'null'
            ));
          },
        ),
      ),
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
              _editText();
            }
          },
        ),
      ),
    ],
  );

  Future<void> _editText() async {
    _textEditorController.text = widget.currentSong?.text ?? 'null';
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