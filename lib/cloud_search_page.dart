import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/app_strings.dart';
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
  final String searchForBackup;
  final void Function(String searchFor) onPerformCloudSearch;
  final void Function(String searchFor) onBackupSearchFor;
  final void Function(int position) onCloudSongClick;
  final void Function() onBackPressed;

  const CloudSearchPage(
      this.theme,
      this.currentCloudSongs,
      this.currentSearchState,
      this.cloudScrollPosition,
      this.searchForBackup,
      this.onPerformCloudSearch,
      this.onBackupSearchFor,
      this.onCloudSongClick,
      this.onBackPressed,
      {super.key});

  @override
  State<StatefulWidget> createState() => CloudSearchPageState();
}

class CloudSearchPageState extends State<CloudSearchPage> {

  static const _titleHeight = 75.0;
  static const _itemHeight = _titleHeight;

  final _cloudSearchTextFieldController = TextEditingController();

  final _cloudTitleScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  @override
  void initState() {
    super.initState();
    _restoreSearchFor();
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
            _makeCloudSearchPanel(),
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
    } else if (widget.currentSearchState == SearchState.empty) {
      return _makeEmptyListIndicator();
    } else {
      throw UnimplementedError('not implemented yet');
    }
  }

  Widget _makeProgressIndicator() => Expanded(
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            color: widget.theme.colorMain,
          ),
        ),
      )
  );

  Widget _makeEmptyListIndicator() => Expanded(
      child: Center(
        child: Text(
          AppStrings.strListIsEmpty,
          style: TextStyle(
            color: widget.theme.colorMain,
            fontSize: 24,
          ),
        )
      )
  );

  Widget _makeCloudSearchPanel() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                controller: _cloudSearchTextFieldController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 24),
                  fillColor: widget.theme.colorMain,
                  filled: true,
                ),
                style: TextStyle(
                  color: widget.theme.colorBg,
                  fontSize: 16,
                ),
              ),
          ),
          const SizedBox(
            width: 4,
          ),
          Container(
            width: 72,
            height: 72,
            color: AppTheme.colorDarkYellow,
            child:
            IconButton(
              icon: Image.asset(AppIcons.icCloudSearch),
              padding: const EdgeInsets.all(8),
              onPressed: () {
                _performCloudSearch();
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView _makeCloudTitleListView() => ListView.builder(
      controller: _cloudTitleScrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.currentCloudSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final cloudSong = widget.currentCloudSongs[index];
        return GestureDetector(
          onTap: () {
            _backupSearchFor();
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

  void _performCloudSearch() {
    final searchFor = _cloudSearchTextFieldController.text;
    widget.onPerformCloudSearch(searchFor);
  }

  void _backupSearchFor() {
    widget.onBackupSearchFor(_cloudSearchTextFieldController.text);
  }

  void _restoreSearchFor() {
    _cloudSearchTextFieldController.text = widget.searchForBackup;
  }
}
