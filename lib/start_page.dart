import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/version.dart';
import 'package:rxdart/rxdart.dart';

import 'app_state.dart';
import 'app_strings.dart';

class StartPage extends StatefulWidget {

  final ValueStream<AppState> appStateStream;
  final void Function() onInitSuccess;

  const StartPage(this.appStateStream, this.onInitSuccess, {super.key});

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
    return StreamBuilder<AppState>(
        stream: widget.appStateStream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return Container();
          }
          return _makePage(context, appState.theme);
        }
    );
  }

  @override
  Widget _makePage(BuildContext context, AppTheme theme) {
    return Material(
      color: theme.colorBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: wasUpdated ? [
          Text(AppStrings.strStartPleaseWait,
              style: TextStyle(color: theme.colorMain, fontSize: 22)),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: LinearProgressIndicator(
              value: indicatorValue,
              minHeight: 30,
              backgroundColor: AppTheme.colorDarkYellow,
              color: theme.colorMain,
            ),
          ),
          Text(indicatorText, style: TextStyle(color: theme.colorMain, fontSize: 22)),
          const SizedBox(
            height: 30,
          ),
          Text(AppStrings.strStartDbBuilding,
              style: TextStyle(color: theme.colorMain, fontSize: 14)),
        ] : [
          Text(AppStrings.strStartPleaseWait,
              style: TextStyle(color: theme.colorMain, fontSize: 22)),
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