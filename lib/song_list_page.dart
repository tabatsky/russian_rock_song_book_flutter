import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/theme.dart';

class SongListPage extends StatefulWidget{

  final AppTheme theme;

  final List<String> allArtists;
  final String currentArtist;
  final List<Song> currentSongs;
  final void Function(int position) onSongClick;
  final void Function(String artist) onArtistClick;

  const SongListPage(this.theme, this.allArtists, this.currentArtist, this.currentSongs, this.onSongClick, this.onArtistClick, {super.key});

  @override
  State<SongListPage> createState() => SongListPageState();
}

class SongListPageState extends State<SongListPage> {

  @override
  void initState() {
    super.initState();
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
              child: Text('Меню', style: TextStyle(color: AppTheme.colorBlack)),
            ),
          );
        } else {
          final artist = widget.allArtists[index - 1];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  widget.onArtistClick(artist);
                },
                child: Container(
                    height: 50,
                    color: widget.theme.colorMain,
                    child: Center(
                      child: Text(artist, style: TextStyle(color: widget.theme.colorBg)),
                    )
                ),
              ),
              Divider(
                height: 3.0,
                color: widget.theme.colorBg,
              )
            ],
          );
        }
      }
  );

  ListView _makeTitleListView() => ListView.builder(
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