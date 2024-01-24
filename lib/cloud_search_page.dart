import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song_repository.dart';

import 'app_icons.dart';
import 'app_theme.dart';

class CloudSearchPage extends StatefulWidget {

  final AppTheme theme;
  final void Function() onBackPressed;

  const CloudSearchPage(this.theme, this.onBackPressed, {super.key});

  @override
  State<StatefulWidget> createState() => CloudSearchPageState();
}

class CloudSearchPageState extends State<CloudSearchPage> {

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
}