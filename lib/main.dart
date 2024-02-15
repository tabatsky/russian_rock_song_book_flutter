import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/cloud_search_page.dart';
import 'package:russian_rock_song_book/cloud_song_text_page.dart';
import 'dart:developer';

import 'package:russian_rock_song_book/song_list_page.dart';
import 'package:russian_rock_song_book/song_text_page.dart';
import 'package:russian_rock_song_book/start_page.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import 'app_actions.dart';
import 'app_state.dart';
import 'app_theme.dart';

void main() {
  runApp(MyApp());
}

typedef ActionPerformer = void Function(AppUIAction action);

class MyApp extends StatelessWidget {
  final appStateSubject = BehaviorSubject<AppState>.seeded(AppState());
  final AppStateMachine appStateMachine = AppStateMachine();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(
        appStateStream: appStateSubject.stream,
          performAction: _performAction
      ),
    );
  }

  void _performAction(AppUIAction action) {
    final machineAcceptedAction = appStateMachine.performAction((newState) {
      appStateSubject.add(newState);
    }, appStateSubject.value, action);

    if (machineAcceptedAction) {
      log('app state machine accepted action');
    }
  }
}

class MainPage extends StatefulWidget {
  final ValueStream<AppState> appStateStream;
  final ActionPerformer performAction;

  const MainPage({super.key, required this.appStateStream, required this.performAction});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: widget.appStateStream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return const Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  color: AppTheme.colorLightYellow,
                ),
              ),
            );
          }
          switch (appState.currentPageVariant) {
            case PageVariant.start:
              return StartPage(() {
                widget.performAction(ShowSongList());
              });
            case PageVariant.songList:
              return SongListPage(
                  widget.appStateStream, widget.performAction
              );
            case PageVariant.songText:
              return SongTextPage(
                  widget.appStateStream, widget.performAction
              );
            case PageVariant.cloudSearch:
              return CloudSearchPage(
                  widget.appStateStream, widget.performAction
              );
            case PageVariant.cloudSongText:
              return CloudSongTextPage(
                  widget.appStateStream, widget.performAction
              );
          }
        });
  }
}

