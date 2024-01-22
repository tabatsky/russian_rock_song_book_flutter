import 'package:flutter/material.dart';

import 'package:russian_rock_song_book/icons.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/theme.dart';

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
          double width = constraints.maxHeight;
          double height = constraints.maxHeight;
          return SingleChildScrollView(
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
          );
        },
      ),
    );
  }
}