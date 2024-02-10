import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:russian_rock_song_book/app_divider.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/app_strings.dart';

import 'app_actions.dart';
import 'app_state.dart';

class SongListPage extends StatefulWidget{

  final AppTheme theme;

  final LocalState localState;
  final void Function(UIAction action) onPerformAction;

  const SongListPage(
      this.theme,
      this.localState,
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

  void _scrollToActual() {
    _titleScrollController.animateTo(widget.localState.scrollPosition * _itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(widget.localState.currentArtist),
      ),
      drawer: Drawer(
        child: _makeMenuListView(),
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
            _makeContent(),
          ],
        ),
      ),
    );
  }

  ListView _makeMenuListView() => ListView.builder(
      controller: _menuScrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.localState.allArtists.length + 1,
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
          final artist = widget.localState.allArtists[index - 1];
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
                  color: widget.theme.colorMain,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          artist,
                          style: TextStyle(
                            color: widget.theme.colorBg,
                            fontWeight: fontWeight,
                          )
                      ),
                    ),
                  ),
                ),
              ),
              AppDivider(
                height: _dividerHeight,
                color: widget.theme.colorBg,
              ),
            ],
          );
        }
      }
  );

  Widget _makeContent() {
    if (widget.localState.currentSongs.isEmpty) {
      return _makeEmptyListIndicator();
    } else {
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual());
      return Flexible(child: _makeTitleListView());
    }
  }

  Widget _makeEmptyListIndicator() => Expanded(
      child: Center(
          child: Text(
            AppStrings.strListIsEmpty,
            style: TextStyle(
              color: widget.theme.colorMain,
              fontSize: 24,
            ),
          )
      )
  );

  ListView _makeTitleListView() => ListView.builder(
      controller: _titleScrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.localState.currentSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final song = widget.localState.currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.onPerformAction(SongClick(index));
              },
              child: Container(
                  height: 50,
                  color: widget.theme.colorBg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(song.title, style: TextStyle(color: widget.theme.colorMain)),
                    ),
                  )
              ),
            ),
            AppDivider(
              height: _dividerHeight,
              color: widget.theme.colorMain,
            )
          ],
        );
      }
  );
}