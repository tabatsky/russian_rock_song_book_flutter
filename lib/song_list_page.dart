import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/app_strings.dart';

class SongListPage extends StatefulWidget{

  final AppTheme theme;

  final List<String> allArtists;
  final String currentArtist;
  final List<Song> currentSongs;
  final int scrollPosition;
  final void Function(int position) onSongClick;
  final void Function(String artist) onArtistClick;

  const SongListPage(this.theme, this.allArtists, this.currentArtist, this.currentSongs, this.scrollPosition, this.onSongClick, this.onArtistClick, {super.key});

  @override
  State<SongListPage> createState() => SongListPageState();
}

class SongListPageState extends State<SongListPage> {

  static const _titleHeight = 50.0;
  static const _dividerHeight = 3.0;
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
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToActual());
  }

  @override
  void didUpdateWidget(SongListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToActual();
  }

  void _scrollToActual() {
    _titleScrollController.animateTo(widget.scrollPosition * _itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(widget.currentArtist),
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
            Flexible(child: _makeTitleListView()),
          ],
        ),
      ),
    );
  }

  ListView _makeMenuListView() => ListView.builder(
      controller: _menuScrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.allArtists.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.colorDarkYellow,
              ),
              margin: EdgeInsets.zero,
              child: Text(AppStrings.strMenu, style: TextStyle(color: AppTheme.colorBlack)),
            ),
          );
        } else {
          final artist = widget.allArtists[index - 1];
          final fontWeight =
            artist == SongRepository.artistFavorite
                ? FontWeight.bold
                : FontWeight.normal;
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  widget.onArtistClick(artist);
                },
                child: Container(
                    height: _titleHeight,
                    color: widget.theme.colorMain,
                    child: Center(
                      child: Text(
                          artist,
                          style: TextStyle(
                              color: widget.theme.colorBg,
                              fontWeight: fontWeight,
                          )
                      ),
                    )
                ),
              ),
              Divider(
                height: _dividerHeight,
                color: widget.theme.colorBg,
              )
            ],
          );
        }
      }
  );

  ListView _makeTitleListView() => ListView.builder(
      controller: _titleScrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.currentSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final song = widget.currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.onSongClick(index);
              },
              child: Container(
                  height: 50,
                  color: widget.theme.colorBg,
                  child: Center(
                    child: Text(song.title, style: TextStyle(color: widget.theme.colorMain)),
                  )
              ),
            ),
            Divider(
              height: 3.0,
              color: widget.theme.colorMain,
            )
          ],
        );
      }
  );
}