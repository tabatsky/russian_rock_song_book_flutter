import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/main.dart';
import 'package:russian_rock_song_book/song_repository.dart';

import 'app_icons.dart';
import 'app_theme.dart';
import 'cloud_song.dart';

class CloudSearchPage extends StatefulWidget {

  final AppTheme theme;
  final List<CloudSong> currentCloudSongs;
  final SearchState currentSearchState;
  final int cloudScrollPosition;
  final void Function() onPerformCloudSearch;
  final void Function(int position) onCloudSongClick;
  final void Function() onBackPressed;

  const CloudSearchPage(
      this.theme,
      this.currentCloudSongs,
      this.currentSearchState,
      this.cloudScrollPosition,
      this.onPerformCloudSearch,
      this.onCloudSongClick,
      this.onBackPressed,
      {super.key});

  @override
  State<StatefulWidget> createState() => CloudSearchPageState();
}

class CloudSearchPageState extends State<CloudSearchPage> {

  static const _titleHeight = 75.0;
  static const _itemHeight = _titleHeight;

  final _cloudTitleScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  @override
  void initState() {
    super.initState();
    widget.onPerformCloudSearch();
  }

  void _scrollToActual() {
    _cloudTitleScrollController.animateTo(widget.cloudScrollPosition * _itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentSearchState == SearchState.loaded) {
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual());
    }
    return Scaffold(
      backgroundColor: widget.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: const Text(SongRepository.artistCloudSearch),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            widget.onBackPressed();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _content(),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    if (widget.currentSearchState == SearchState.loading) {
      return _makeProgressIndicator();
    } else if (widget.currentSearchState == SearchState.loaded) {
      return Flexible(child: _makeCloudTitleListView());
    } else {
      throw UnimplementedError('not implemented yet');
    }
  }

  Widget _makeProgressIndicator() => SizedBox(
    width: 100,
    height: 100,
    child: CircularProgressIndicator(
      color: widget.theme.colorMain,
    ),
  );

  ListView _makeCloudTitleListView() => ListView.builder(
      controller: _cloudTitleScrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.currentCloudSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final cloudSong = widget.currentCloudSongs[index];
        return GestureDetector(
          onTap: () {
            widget.onCloudSongClick(index);
          },
          child: Container(
              height: 75,
              color: widget.theme.colorBg,
              child: Column(
                children: [
                  const Spacer(),
                  Text(cloudSong.artist, style: TextStyle(color: widget.theme.colorMain)),
                  const Spacer(),
                  Text(cloudSong.title, style: TextStyle(color: widget.theme.colorMain)),
                  const Spacer(),
                  Divider(
                    height: 3.0,
                    color: widget.theme.colorMain,
                  )
                ]
              )
          ),
        );
      }
  );
}
