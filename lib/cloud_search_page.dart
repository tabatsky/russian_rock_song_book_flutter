import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song_repository.dart';

import 'app_icons.dart';
import 'app_theme.dart';
import 'cloud_repository.dart';

class CloudSearchPage extends StatefulWidget {

  final AppTheme theme;
  final void Function() onBackPressed;

  const CloudSearchPage(this.theme, this.onBackPressed, {super.key});

  @override
  State<StatefulWidget> createState() => CloudSearchPageState();
}

class CloudSearchPageState extends State<CloudSearchPage> {

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
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                color: widget.theme.colorMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cloudSearch() async {
    final dio = Dio(); // Provide a dio instance
    //dio.options.headers['Demo-Header'] = 'demo header'; // config your dio headers globally
    final client = RestClient(dio);
    final result = await client.searchSongs('empty_search_query', 'byIdDesc');
    log(result.status);
    log(result.data?.length.toString() ?? 'error');
    log(result.data?.elementAtOrNull(0)?.description() ?? 'error');
    log(result.data?.elementAtOrNull(33)?.description() ?? 'error');
    log(result.data?.elementAtOrNull(17)?.description() ?? 'error');
  }
}