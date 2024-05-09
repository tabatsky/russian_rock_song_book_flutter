import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/data/settings/version.dart';
import 'package:rxdart/rxdart.dart';

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
          return _makePage(context, appState.settings);
        }
    );
  }

  Widget _makePage(BuildContext context, AppSettings settings) {
    return Material(
      color: settings.theme.colorBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: wasUpdated ? [
          Text(AppStrings.strStartPleaseWait,
              style: settings.textStyler.textStyleSmallTitle),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: LinearProgressIndicator(
              value: indicatorValue,
              minHeight: 30,
              backgroundColor: AppTheme.colorDarkYellow,
              color: settings.theme.colorMain,
            ),
          ),
          Text(indicatorText, style: settings.textStyler.textStyleSmallTitle),
          const SizedBox(
            height: 30,
          ),
          Text(AppStrings.strStartDbBuilding,
              style: settings.textStyler.textStyleSmall),
        ] : [
          Text(AppStrings.strStartPleaseWait,
              style: settings.textStyler.textStyleSmallTitle),
        ],
      ),
    );
  }

  Future<void> _initDB() async {
    await GetIt.I<SongRepository>().initDB();
    final appWasUpdated = await Version.appWasUpdated();
    setState(() {
      wasUpdated = appWasUpdated;
    });
    if (appWasUpdated) {
      await GetIt.I<SongRepository>().fillDB((done, total) {
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