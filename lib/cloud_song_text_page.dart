import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/cloud_song.dart';

import 'app_icons.dart';

class CloudSongTextPage extends StatelessWidget {

  final AppTheme theme;
  final CloudSong? currentCloudSong;
  final int currentCloudSongPosition;
  final int currentCloudSongCount;
  final void Function() onBackPressed;
  final void Function() onPrevCloudSong;
  final void Function() onNextCloudSong;
  final void Function() onDownloadCurrent;
  final void Function() onOpenVkMusic;
  final void Function() onOpenYandexMusic;
  final void Function() onOpenYoutubeMusic;
  final void Function() onLikeCurrent;
  final void Function() onDislikeCurrent;

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  CloudSongTextPage(
      this.theme,
      this.currentCloudSong,
      this.currentCloudSongPosition,
      this.currentCloudSongCount,
      this.onBackPressed,
      this.onPrevCloudSong,
      this.onNextCloudSong,
      this.onDownloadCurrent,
      this.onOpenVkMusic,
      this.onOpenYandexMusic,
      this.onOpenYoutubeMusic,
      this.onLikeCurrent,
      this.onDislikeCurrent,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorBg,
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
              onPrevCloudSong();
            },
          ),
          Text("${currentCloudSongPosition + 1} / $currentCloudSongCount"),
          IconButton(
            icon: Image.asset(AppIcons.icRight),
            iconSize: 50,
            onPressed: () {
              onNextCloudSong();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _makeCloudSongTextView(context),
        ],
      ),
    );
  }

  Widget _makeCloudSongTextView(BuildContext context) {
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
                        Text(currentCloudSong?.title ?? 'null', style: TextStyle(color: theme.colorMain, fontSize: 24)),
                        Container(
                          height: 20,
                        ),
                        Text(
                          currentCloudSong?.text ?? 'null',
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
                child: _bottomButtonRow(buttonSize),
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
            onOpenVkMusic();
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
            onOpenYoutubeMusic();
          },
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icDownload),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            onDownloadCurrent();
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
          icon: Image.asset(AppIcons.icLike),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            onLikeCurrent();
          },
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icDislike),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            onDislikeCurrent();
          },
        ),
      ),
    ],
  );
}