import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/theme.dart';

class SongListPage extends StatefulWidget{

  AppTheme theme;

  String currentArtist;
  List<Song> currentSongs;
  void Function(Song s) onSongClick;

  SongListPage(this.theme, this.currentArtist, this.currentSongs, this.onSongClick, {super.key});

  @override
  State<SongListPage> createState() => SongListPageState();
}

class SongListPageState extends State<SongListPage> {

  List<String> allArtists = [];

  @override
  void initState() {
    super.initState();
    _initArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      itemCount: allArtists.length + 1,
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
          final artist = allArtists[index - 1];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  log("$artist click");
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
        var song = widget.currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.onSongClick(song);
              },
              child: Container(
                  height: 50,
                  color: widget.theme.colorBg,
                  child: Center(
                    child: Text(song.title, style: TextStyle(color: widget.theme.colorMain)),
                  )
              ),
            ),
            const Divider(
              height: 3.0,
              color: Colors.black,
            )
          ],
        );
      }
  );

  Future<void> _initArtists() async {
    await SongRepository().initDB();
    final artists = await SongRepository().getArtists();
    log(artists.toString());
    setState(() {
      allArtists = artists;
    });
  }
}