import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/cloud_search_page.dart';
import 'package:russian_rock_song_book/cloud_song_text_page.dart';
import 'package:russian_rock_song_book/settings_page.dart';
import 'dart:developer';

import 'package:russian_rock_song_book/song_list_page.dart';
import 'package:russian_rock_song_book/song_text_page.dart';
import 'package:russian_rock_song_book/start_page.dart';
import 'package:rxdart/rxdart.dart';

import 'app_actions.dart';
import 'app_state.dart';

void main() {
  runApp(MyApp());
}

typedef ActionPerformer = void Function(AppUIAction action);

class MyApp extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _appStateSubject = BehaviorSubject<AppState>.seeded(AppState());
  late final AppStateMachine _appStateMachine = AppStateMachine(() => _navigatorKey.currentState);

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _performAction(ReloadSettings());
    return MaterialApp(
      title: 'RussianRockSongBook',
      navigatorKey: _navigatorKey,
      initialRoute: '/start',
      routes: {
        PageVariant.start.route: (context) => StartPage(
           _appStateSubject.stream, () {
          _performAction(ShowSongList());
        }),
        PageVariant.songList.route: (context) => SongListPage(
            _appStateSubject.stream, _performAction
        ),
        PageVariant.songText.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) { _performAction(Back(systemBack: true)); },
            child: SongTextPage(
                _appStateSubject.stream, _performAction
            ),
        ),
        PageVariant.cloudSearch.route: (context) =>
            PopScope(
                canPop: true,
                onPopInvoked: (didPop) { _performAction(Back(systemBack: true)); },
                child: CloudSearchPage(
                    _appStateSubject.stream, _performAction
                ),
            ),
        PageVariant.cloudSongText.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) { _performAction(Back(systemBack: true)); },
            child: CloudSongTextPage(
                _appStateSubject.stream, _performAction
            ),
        ),
        PageVariant.settings.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) { _performAction(Back(systemBack: true)); },
            child: SettingsPage(
                _appStateSubject.stream, _performAction
            ),
        ),
      }
    );
  }

  void _performAction(AppUIAction action) {
    final machineAcceptedAction = _appStateMachine.performAction((newState) {
      _appStateSubject.add(newState);
    }, _appStateSubject.value, action);

    if (machineAcceptedAction) {
      log('app state machine accepted action');
    }
  }
}


