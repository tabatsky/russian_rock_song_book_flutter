import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/version.dart';

import 'app_strings.dart';

class StartPage extends StatefulWidget {


  final void Function() onInitSuccess;

  const StartPage(this.onInitSuccess, {super.key});

  @override
  State<StatefulWidget> createState() => StartPageState();

}

class StartPageState extends State<StartPage> {

  double indicatorValue = 0.0;
  String indicatorText = AppStrings.strFrom(0, SongRepository.artistMap.length);

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.materialBlack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: LinearProgressIndicator(
              value: indicatorValue,
              minHeight: 30,
              backgroundColor: AppTheme.colorDarkYellow,
              color: AppTheme.colorLightYellow,
            ),
          ),
          Container(
            height: 30,
          ),
          Text(indicatorText, style: const TextStyle(color: AppTheme.colorLightYellow, fontSize: 24)),
        ],
      ),
    );
  }

  Future<void> _initDB() async {
    await SongRepository().initDB();
    final appWasUpdated = await Version.appWasUpdated();
    if (appWasUpdated) {
      await SongRepository().fillDB((done, total) {
        log("done: $done of $total");
        setState(() {
          indicatorValue = 1.0 * done / total;
          indicatorText = AppStrings.strFrom(done, total);
        });
      });
      await Version.confirmAppUpdate();
    }
    widget.onInitSuccess();
  }
}