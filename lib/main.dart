import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/cloud_search_page.dart';
import 'package:russian_rock_song_book/cloud_song_text_page.dart';
import 'dart:developer';

import 'package:russian_rock_song_book/song_list_page.dart';
import 'package:russian_rock_song_book/song_text_page.dart';
import 'package:russian_rock_song_book/start_page.dart';
import 'package:rxdart/subjects.dart';

import 'app_actions.dart';
import 'app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final appStateSubject = BehaviorSubject<AppState>.seeded(AppState());

  AppStateMachine appStateMachine = AppStateMachine();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: appStateSubject.stream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return const Center(
              child: Text("Not ready yet"),
            );
          }
          switch (appState.currentPageVariant) {
            case PageVariant.start:
              return StartPage(() {
                _performAction(ShowSongList());
              });
            case PageVariant.songList:
              return SongListPage(
                  appState.theme,
                  appState.localState,
                      (action) { _performAction(action); }
              );
            case PageVariant.songText:
              return SongTextPage(
                  appState.theme,
                  appState.localState.currentSong,
                      (action) { _performAction(action); }
              );
            case PageVariant.cloudSearch:
              return CloudSearchPage(
                  appState.theme,
                  appState.cloudState,
                      (action) { _performAction(action); }
              );
            case PageVariant.cloudSongText:
              return CloudSongTextPage(
                  appState.theme,
                  appState.cloudState,
                      (action) { _performAction(action); }
              );
          }
        });
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

