import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/features/warning_dialog/view/warning_dialog.dart';
import 'package:rxdart/rxdart.dart';

class CloudSongTextPage extends StatelessWidget {

  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  const CloudSongTextPage(
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
          return _CloudSongTextPageContent(appState.settings, appState.cloudState, onPerformAction);
        }
    );
  }
}

class _CloudSongTextPageContent extends StatelessWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final void Function(AppUIAction action) onPerformAction;

  const _CloudSongTextPageContent(this.settings, this.cloudState, this.onPerformAction);

  @override
  Widget build(BuildContext context) {
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
          _CloudSongTextBody(settings, cloudState, onPerformAction),
        ],
      ),
    );
  }
}

class _CloudSongTextBody extends StatelessWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final void Function(AppUIAction action) onPerformAction;

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  _CloudSongTextBody(this.settings, this.cloudState, this.onPerformAction);

  @override
  Widget build(BuildContext context) {
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
                child: _ButtonRow(
                    settings.listenToMusicPreference,
                    cloudState.currentCloudSong,
                    buttonSize,
                    onPerformAction),
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

}

class _ButtonRow extends StatelessWidget {
  final ListenToMusicVariant listenToMusicVariant;
  final CloudSong? currentCloudSong;
  final double buttonSize;
  final void Function(AppUIAction action) onPerformAction;

  const _ButtonRow(this.listenToMusicVariant,
      this.currentCloudSong,
      this.buttonSize,
      this.onPerformAction);

  @override
  Widget build(BuildContext context) => Row(
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
                currentCloudSong?.searchFor ?? 'null'
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
                currentCloudSong?.searchFor ?? 'null'
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
              final warning = Warning.fromCloudSongWithComment(currentCloudSong!, comment);
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