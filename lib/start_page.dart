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
  bool wasUpdated = false;

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
        children: wasUpdated ? [
          const Text(AppStrings.strStartPleaseWait,
              style: TextStyle(color: AppTheme.colorLightYellow, fontSize: 22)),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: LinearProgressIndicator(
              value: indicatorValue,
              minHeight: 30,
              backgroundColor: AppTheme.colorDarkYellow,
              color: AppTheme.colorLightYellow,
            ),
          ),
          Text(indicatorText, style: const TextStyle(color: AppTheme.colorLightYellow, fontSize: 22)),
          const SizedBox(
            height: 30,
          ),
          const Text(AppStrings.strStartDbBuilding,
              style: TextStyle(color: AppTheme.colorLightYellow, fontSize: 14)),
        ] : [
          const Text(AppStrings.strStartPleaseWait,
              style: TextStyle(color: AppTheme.colorLightYellow, fontSize: 22)),
        ],
      ),
    );
  }

  Future<void> _initDB() async {
    await SongRepository().initDB();
    final appWasUpdated = await Version.appWasUpdated();
    setState(() {
      wasUpdated = appWasUpdated;
    });
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