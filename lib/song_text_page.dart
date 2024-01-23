import 'package:flutter/material.dart';

import 'package:russian_rock_song_book/app_icons.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/app_theme.dart';

class SongTextPage extends StatefulWidget {

  final AppTheme theme;
  final Song? currentSong;
  final void Function() onBackPressed;
  final void Function() onPrevSong;
  final void Function() onNextSong;
  final void Function() onToggleFavorite;

  const SongTextPage(
      this.theme,
      this.currentSong,
      this.onBackPressed,
      this.onPrevSong,
      this.onNextSong,
      this.onToggleFavorite,
      {super.key});

  @override
  State<StatefulWidget> createState() => SongTextPageState();

}

class SongTextPageState extends State<SongTextPage> {

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  bool isEditorMode = false;

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
            widget.onBackPressed();
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(AppIcons.icLeft),
            iconSize: 50,
            onPressed: () {
              widget.onPrevSong();
            },
          ),
          IconButton(
            icon: Image.asset(widget.currentSong?.favorite == true ? AppIcons.icDelete : AppIcons.icStar),
            iconSize: 50,
            onPressed: () {
              widget.onToggleFavorite();
            },
          ),
          IconButton(
            icon: Image.asset(AppIcons.icRight),
            iconSize: 50,
            onPressed: () {
              widget.onNextSong();
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
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
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
                        Text(widget.currentSong?.text ?? 'null', style: TextStyle(color: widget.theme.colorMain)),
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
                child: Row(
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
                        icon: Image.asset(isEditorMode ? AppIcons.icSave : AppIcons.icEdit),
                        padding: const EdgeInsets.all(8),
                        onPressed: () {
                          setState(() {
                            isEditorMode = !isEditorMode;
                          });
                        },
                      ),
                    ),
                  ],
                ),
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
}