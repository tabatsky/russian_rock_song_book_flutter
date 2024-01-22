import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:russian_rock_song_book/icons.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/theme.dart';

class SongTextPage extends StatelessWidget {

  final AppTheme theme;
  final Song? currentSong;
  final void Function() onBackPressed;

  const SongTextPage(this.theme,this.currentSong, this.onBackPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(currentSong?.title ?? 'null'),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            onBackPressed();
          },
        ),
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