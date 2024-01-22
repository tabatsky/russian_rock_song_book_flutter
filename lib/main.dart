import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_list_page.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/song_text_page.dart';
import 'package:russian_rock_song_book/start_page.dart';
import 'package:russian_rock_song_book/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Flutter Demo Home Page'),
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
  AppTheme theme = AppTheme.themeDark;

  PageVariant currentPageVariant = PageVariant.start;
  String currentArtist = 'Кино';
  List<Song> currentSongs = <Song>[];
  List<String> allArtists = [];
  Song? currentSong;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentPageVariant == PageVariant.start) {
      return StartPage(() {
        _showSongList();
      });
    }
    if (currentPageVariant == PageVariant.songList) {
      return SongListPage(theme, allArtists, currentArtist, currentSongs, (s) {
        _selectSong(s);
      });
    } else if (currentPageVariant == PageVariant.songText) {
      return SongTextPage(theme, currentSong, () {
        _back();
      });
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> _initSongs() async {
    await _initAllArtists();
    await _selectArtist('Кино');
  }

  Future<void> _initAllArtists() async {
    final artists = await SongRepository().getArtists();
    log(artists.toString());
    setState(() {
      allArtists = artists;
    });
  }

  Future<void> _selectArtist(String artist) async {
    final songs = await SongRepository().getSongsByArtist(artist);
    setState(() {
      currentArtist = artist;
      currentSongs = songs;
    });
  }

  void _selectSong(Song song) {
    setState(() {
      currentSong = song;
      currentPageVariant = PageVariant.songText;
    });
  }

  void _showSongList() {
    _initSongs();
    setState(() {
      currentPageVariant = PageVariant.songList;
    });
  }

  void _back() {
    if (currentPageVariant == PageVariant.songText) {
      setState(() {
        currentPageVariant = PageVariant.songList;
        currentSong = null;
      });
    }
  }
}

enum PageVariant { start, songList, songText }
