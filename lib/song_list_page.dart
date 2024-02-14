import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:russian_rock_song_book/app_divider.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/app_strings.dart';
import 'package:rxdart/rxdart.dart';

import 'app_actions.dart';
import 'app_state.dart';

class SongListPage extends StatefulWidget{
  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  const SongListPage(
      this.appStateStream,
      this.onPerformAction,
      {super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {

  static const _titleHeight = 50.0;
  static const _dividerHeight = 1.0;
  static const _itemHeight = _titleHeight + _dividerHeight;

  final _titleScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  final _menuScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  double _menuScrollOffset = 0.0;

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
          return _makePage(context, appState.theme, appState.localState);
        }
    );
  }

  void _scrollToActual(LocalState localState) {
    _titleScrollController.animateTo(localState.scrollPosition * _itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  Widget _makePage(BuildContext context, AppTheme theme, LocalState localState) {
    return Scaffold(
      backgroundColor: theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(localState.currentArtist),
      ),
      drawer: Drawer(
        child: _makeMenuListView(theme, localState),
      ),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _menuScrollController.animateTo(_menuScrollOffset,
                duration: const Duration(milliseconds: 1), curve: Curves.ease);
          });
        } else {
          _menuScrollOffset = _menuScrollController.position.pixels;
        }
      },
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _makeContent(theme, localState),
          ],
        ),
      ),
    );
  }

  ListView _makeMenuListView(AppTheme theme, LocalState localState) => ListView.builder(
      controller: _menuScrollController,
      padding: EdgeInsets.zero,
      itemCount: localState.allArtists.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.colorDarkYellow,
              ),
              margin: EdgeInsets.zero,
              child: Text(AppStrings.strMenu, style: TextStyle(color: AppTheme.materialBlack)),
            ),
          );
        } else {
          final artist = localState.allArtists[index - 1];
          final fontWeight =
            SongRepository.predefinedArtists.contains(artist)
                ? FontWeight.bold
                : FontWeight.normal;
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onPerformAction(ArtistClick(artist));
                },
                child: Container(
                  height: _titleHeight,
                  color: theme.colorMain,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          artist,
                          style: TextStyle(
                            color: theme.colorBg,
                            fontWeight: fontWeight,
                          )
                      ),
                    ),
                  ),
                ),
              ),
              AppDivider(
                height: _dividerHeight,
                color: theme.colorBg,
              ),
            ],
          );
        }
      }
  );

  Widget _makeContent(AppTheme theme, LocalState localState) {
    if (localState.currentSongs.isEmpty) {
      return _makeEmptyListIndicator(theme);
    } else {
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual(localState));
      return Flexible(child: _makeTitleListView(theme, localState));
    }
  }

  Widget _makeEmptyListIndicator(AppTheme theme) => Expanded(
      child: Center(
          child: Text(
            AppStrings.strListIsEmpty,
            style: TextStyle(
              color: theme.colorMain,
              fontSize: 24,
            ),
          )
      )
  );

  ListView _makeTitleListView(AppTheme theme, LocalState localState) => ListView.builder(
      controller: _titleScrollController,
      padding: EdgeInsets.zero,
      itemCount: localState.currentSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final song = localState.currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.onPerformAction(SongClick(index));
              },
              child: Container(
                  height: 50,
                  color: theme.colorBg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(song.title, style: TextStyle(color: theme.colorMain)),
                    ),
                  )
              ),
            ),
            AppDivider(
              height: _dividerHeight,
              color: theme.colorMain,
            )
          ],
        );
      }
  );
}