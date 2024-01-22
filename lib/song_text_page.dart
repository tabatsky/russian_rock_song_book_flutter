import 'package:flutter/material.dart';

import 'package:russian_rock_song_book/icons.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/theme.dart';

class SongTextPage extends StatelessWidget {

  final AppTheme theme;
  final Song? currentSong;
  final void Function() onBackPressed;
  final void Function() onPrevSong;
  final void Function() onNextSong;

  const SongTextPage(this.theme,this.currentSong, this.onBackPressed, this.onPrevSong, this.onNextSong, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            onBackPressed();
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(AppIcons.icLeft),
            iconSize: 50,
            onPressed: () {
              onPrevSong();
            },
          ),
          IconButton(
            icon: Image.asset(AppIcons.icStar),
            iconSize: 50,
            onPressed: () {
              //onBackPressed();
            },
          ),
          IconButton(
            icon: Image.asset(AppIcons.icRight),
            iconSize: 50,
            onPressed: () {
              onNextSong();
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
                  Text(currentSong?.text ?? 'null', style: TextStyle(color: theme.colorMain)),
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