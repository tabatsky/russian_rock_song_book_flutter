import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/features/common/widgets/bottom_button.dart';
import 'package:russian_rock_song_book/features/common/widgets/music_button.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/cloud_state.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/features/warning_dialog/view/warning_dialog.dart';

class CloudSongTextPage extends StatelessWidget {

  final AppBloc appBloc;
  final void Function(AppUIEvent action) onPerformAction;

  const CloudSongTextPage(
      this.appBloc,
      this.onPerformAction,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _CloudSongTextPageContent(state.settings, state.cloudState, onPerformAction);
        }
    );
  }
}

class _CloudSongTextPageContent extends StatelessWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final void Function(AppUIEvent action) onPerformAction;

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

class _CloudSongTextBody extends StatefulWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final void Function(AppUIEvent action) onPerformAction;

  const _CloudSongTextBody(this.settings, this.cloudState, this.onPerformAction);

  @override
  State<StatefulWidget> createState() => _CloudSongTextBodyState();
}

class _CloudSongTextBodyState extends State<_CloudSongTextBody> {

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  CloudSong? _currentCloudSong;
  
  @override
  Widget build(BuildContext context) {
    _updateCloudSong(widget.cloudState.currentCloudSong);
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

          double buttonSize = isPortrait ? width / 7.0 : height / 7.0;

          final extraLikes = widget.cloudState.extraLikesForCurrent;
          final extraDislikes =widget.cloudState.extraDislikesForCurrent;

          final bodyContent = [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                child: Container(
                  constraints: BoxConstraints(minHeight: height, minWidth: width),
                  color: widget.settings.theme.colorBg,
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    children: [
                      Text(widget.cloudState.currentCloudSong
                          ?.visibleTitleWithArtistAndRating(extraLikes, extraDislikes) ?? '',
                        style: widget.settings.textStyler.textStyleTitle,
                      ),
                      Container(
                        height: 20,
                      ),
                      Text(
                        widget.cloudState.currentCloudSong?.text ?? '',
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
              width: isPortrait ? width : buttonSize,
              height: isPortrait ? buttonSize : height,
              color: widget.settings.theme.colorBg,
              child: _ButtonPanel(
                  isPortrait,
                  widget.settings.listenToMusicPreference,
                  widget.cloudState.currentCloudSong,
                  buttonSize,
                  widget.onPerformAction),
            ),
          ];

          return isPortrait ? Column(
              children: bodyContent
          ) : Row(
              children: bodyContent
          );
        },
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  void _updateCloudSong(CloudSong? newCloudSong) {
    if (_currentCloudSong != newCloudSong) {
      _currentCloudSong = newCloudSong;
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToTop());
    }
  }
}

class _ButtonPanel extends StatelessWidget {
  final bool isPortrait;
  final ListenToMusicVariant listenToMusicVariant;
  final CloudSong? currentCloudSong;
  final double buttonSize;
  final void Function(AppUIEvent action) onPerformAction;

  const _ButtonPanel(
      this.isPortrait,
      this.listenToMusicVariant,
      this.currentCloudSong,
      this.buttonSize,
      this.onPerformAction);

  @override
  Widget build(BuildContext context) {
    final buttons = [
      MusicButton(listenToMusicVariant.supportedVariants[0], currentCloudSong?.searchFor ?? 'null', buttonSize, onPerformAction),
      MusicButton(listenToMusicVariant.supportedVariants[1], currentCloudSong?.searchFor ?? 'null', buttonSize, onPerformAction),
      BottomButton(AppIcons.icDownload, buttonSize, () {
        onPerformAction(DownloadCurrent());
      }),
      BottomButton(AppIcons.icWarning, buttonSize, () {
        WarningDialog.showWarningDialog(context, (comment) {
          final warning = Warning.fromCloudSongWithComment(currentCloudSong!, comment);
          onPerformAction(SendWarning(warning));
        });
      }),
      BottomButton(AppIcons.icLike, buttonSize, () {
        onPerformAction(LikeCurrent());
      }),
      BottomButton(AppIcons.icDislike, buttonSize, () {
        onPerformAction(DislikeCurrent());
      }),
    ];

    return isPortrait ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons,
    ) : Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons,
    );
  }
}