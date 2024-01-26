import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song_repository.dart';

import 'app_icons.dart';
import 'app_theme.dart';
import 'cloud_repository.dart';
import 'cloud_song.dart';

class CloudSearchPage extends StatefulWidget {

  final AppTheme theme;
  final void Function() onBackPressed;

  const CloudSearchPage(this.theme, this.onBackPressed, {super.key});

  @override
  State<StatefulWidget> createState() => CloudSearchPageState();
}

class CloudSearchPageState extends State<CloudSearchPage> {

  SearchState currentSearchState = SearchState.loading;
  List<CloudSong> currentCloudSongs = [];

  @override
  @override
  void initState() {
    super.initState();
    _cloudSearch();
  }

  @override
  Widget build(BuildContext context) {
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
    if (currentSearchState == SearchState.loading) {
      return _makeProgressIndicator();
    } else if (currentSearchState == SearchState.loaded) {
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
      //controller: _titleScrollController,
      padding: EdgeInsets.zero,
      itemCount: currentCloudSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final cloudSong = currentCloudSongs[index];
        return GestureDetector(
          onTap: () {
            log(cloudSong.description());
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

  Future<void> _cloudSearch() async {
    try {
      final cloudSongs = await CloudRepository().cloudSearch('', 'byIdDesc');
      setState(() {
        currentSearchState = SearchState.loaded;
        currentCloudSongs = cloudSongs;
      });
    } catch (e) {
      log("Exception: $e");
      setState(() {
        currentSearchState = SearchState.error;
      });
    }
  }
}

enum SearchState { empty, error, loading, loaded }