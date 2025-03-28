import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/features/add_artist/add_artist_page.dart';
import 'package:russian_rock_song_book/features/add_song/add_song_page.dart';
import 'package:russian_rock_song_book/features/start_page/view/start_page.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/features/cloud/cloud_search_page/view/cloud_search_page.dart';
import 'package:russian_rock_song_book/features/cloud/cloud_song_text_page/view/cloud_song_text_page.dart';
import 'package:russian_rock_song_book/features/local/song_list_page/view/song_list_page.dart';
import 'package:russian_rock_song_book/features/local/song_text_page/view/song_text_page.dart';
import 'package:russian_rock_song_book/features/settings_page/view/settings_page.dart';
import 'package:russian_rock_song_book/mvi/state/app_state_machine.dart';
import 'package:russian_rock_song_book/mvi/state/page_variant.dart';

typedef ActionPerformer = void Function(AppUIEvent action);

class RussianRockSongBookApp extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppStateMachine _appStateMachine =
      AppStateMachine(() => _navigatorKey.currentState, (event) {
    _appBloc.add(event);
  });
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
              appBloc: _appBloc,
              onInitSuccess: () {
                _performAction(ShowSongList());
              }),
          PageVariant.songList.route: (context) =>
              SongListPage(appBloc: _appBloc, onPerformAction: _performAction),
          PageVariant.songText.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              _performAction(Back(systemBack: true));
            },
            child: SongTextPage(
                appBloc: _appBloc, onPerformAction: _performAction),
          ),
          PageVariant.cloudSearch.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              _performAction(Back(systemBack: true));
            },
            child: CloudSearchPage(
                appBloc: _appBloc, onPerformAction: _performAction),
          ),
          PageVariant.cloudSongText.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              _performAction(Back(systemBack: true));
            },
            child: CloudSongTextPage(
                appBloc: _appBloc, onPerformAction: _performAction),
          ),
          PageVariant.settings.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              _performAction(Back(systemBack: true));
            },
            child: SettingsPage(
                appBloc: _appBloc, onPerformAction: _performAction),
          ),
          PageVariant.addArtist.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              _performAction(Back(systemBack: true));
            },
            child: AddArtistPage(
                appBloc: _appBloc, onPerformAction: _performAction),
          ),
          PageVariant.addSong.route: (context) => PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              _performAction(Back(systemBack: true));
            },
            child: AddSongPage(
                appBloc: _appBloc, onPerformAction: _performAction),
          ),
        });
  }

  Future<void> _performAction(AppUIEvent action) async {
    _appBloc.add(action);
  }
}
