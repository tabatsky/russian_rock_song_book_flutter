import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/features/start_page/view/start_page.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/features/cloud/cloud_search_page/view/cloud_search_page.dart';
import 'package:russian_rock_song_book/features/cloud/cloud_song_text_page/view/cloud_song_text_page.dart';
import 'package:russian_rock_song_book/features/local/song_list_page/view/song_list_page.dart';
import 'package:russian_rock_song_book/features/local/song_text_page/view/song_text_page.dart';
import 'package:russian_rock_song_book/features/settings_page/view/settings_page.dart';

import 'package:rxdart/rxdart.dart';

typedef ActionPerformer = void Function(AppUIAction action);

class RussianRockSongBookApp extends StatelessWidget {
  final _appStateSubject = BehaviorSubject<AppState>.seeded(AppState());
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppStateMachine _appStateMachine = AppStateMachine(() => _navigatorKey.currentState);
  late final AppBloc _appBloc = AppBloc(_appStateMachine);

  RussianRockSongBookApp({super.key});

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
              _appBloc, _performAction
          ),
          PageVariant.songText.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) { _performAction(Back(systemBack: true)); },
            child: SongTextPage(
                _appBloc, _performAction
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

  Future<void> _performAction(AppUIAction action) async {
    // final machineAcceptedAction = await _appStateMachine.performAction((newState) async {
    //   _appStateSubject.add(newState);
    // }, _appStateSubject.value, action);
    //
    // if (machineAcceptedAction) {
    //   log('app state machine accepted action');
    // }

    _appBloc.add(action);
  }
}


