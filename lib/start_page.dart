import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/theme.dart';
import 'package:russian_rock_song_book/version.dart';

class StartPage extends StatefulWidget {


  final void Function() onInitSuccess;

  const StartPage(this.onInitSuccess, {super.key});

  @override
  State<StatefulWidget> createState() => StartPageState();

}

class StartPageState extends State<StartPage> {

  double indicatorValue = 0.0;
  String indicatorText = "0 of 0";

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.colorBlack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: indicatorValue,
            minHeight: 30,
            backgroundColor: AppTheme.colorDarkYellow,
            color: AppTheme.colorLightYellow,
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
          indicatorText = "$done of $total";
        });
      });
      await Version.confirmAppUpdate();
    }
    widget.onInitSuccess();
  }
}