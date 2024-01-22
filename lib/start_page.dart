import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/theme.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: indicatorValue,
          minHeight: 30,
          backgroundColor: AppTheme.colorDarkYellow,
          color: AppTheme.colorLightYellow,
        ),
        Text(indicatorText, style: const TextStyle(color: AppTheme.colorLightYellow),)
      ],
    );
  }

  Future<void> _initDB() async {
    await SongRepository().initDB();
    await SongRepository().fillDB((done, total) {
      log("done: $done of $total");
      setState(() {
        indicatorValue = 1.0 * done / total;
        indicatorText = "$done of $total";
      });
    });
    widget.onInitSuccess();
  }
}