import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/app_state.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/warning.dart';
import 'package:russian_rock_song_book/warning_dialog.dart';
import 'package:rxdart/rxdart.dart';

import 'app_actions.dart';
import 'app_icons.dart';

class CloudSongTextPage extends StatelessWidget {

  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  CloudSongTextPage(
      this.appStateStream,
      this.onPerformAction,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: appStateStream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return Container();
          }
          return _makePage(context, appState.settings, appState.cloudState);
        }
    );
  }

  Widget _makePage(BuildContext context, AppSettings settings, CloudState cloudState) {
    return Scaffold(
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
              onPerformAction(PrevCloudSong());
            },
          ),
          Text(
            "${cloudState.currentCloudSongPosition + 1} / ${cloudState.currentCloudSongCount}",
            style: settings.textStyler.textStyleFixedBlackBold,
          ),
          IconButton(
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
          _makeCloudSongTextView(context, settings, cloudState),
        ],
      ),
    );
  }

  Widget _makeCloudSongTextView(BuildContext context, AppSettings settings, CloudState cloudState) {
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          double buttonSize = width / 7.0;

          final extraLikes = cloudState.extraLikesForCurrent;
          final extraDislikes = cloudState.extraDislikesForCurrent;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  child: Container(
                    constraints: BoxConstraints(minHeight: height, minWidth: width),
                    color: settings.theme.colorBg,
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      children: [
                        Text(cloudState.currentCloudSong
                            ?.visibleTitleWithArtistAndRating(extraLikes, extraDislikes) ?? 'null',
                            style: settings.textStyler.textStyleTitle,
                        ),
                        Container(
                          height: 20,
                        ),
                        Text(
                          cloudState.currentCloudSong?.text ?? 'null',
                          style: settings.textStyler.textStyleSongText,
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
                color: settings.theme.colorBg,
                child: _bottomButtonRow(context, buttonSize, cloudState),
              ),
              Container(
                width: width,
                height: buttonSize / 2,
                color: settings.theme.colorBg,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomButtonRow(BuildContext context, double buttonSize, CloudState cloudState) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: buttonSize,
        height: buttonSize,
        color: AppTheme.colorDarkYellow,
        child:
        IconButton(
          icon: Image.asset(AppIcons.icYandex),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            onPerformAction(OpenYandexMusic(
                cloudState.currentCloudSong?.searchFor ?? 'null'
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
            onPerformAction(OpenYoutubeMusic(
                cloudState.currentCloudSong?.searchFor ?? 'null'
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
          icon: Image.asset(AppIcons.icDownload),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            onPerformAction(DownloadCurrent());
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
              final warning = Warning.fromCloudSongWithComment(cloudState.currentCloudSong!, comment);
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
          icon: Image.asset(AppIcons.icLike),
          padding: const EdgeInsets.all(8),
          onPressed: () {
            onPerformAction(LikeCurrent());
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
            onPerformAction(DislikeCurrent());
          },
        ),
      ),
    ],
  );
}