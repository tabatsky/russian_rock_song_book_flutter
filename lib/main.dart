import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_list_page.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/song_text_page.dart';
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AppTheme theme = AppTheme.themeDark;

  PageVariant currentPageVariant = PageVariant.songList;
  String currentArtist = 'Кино';
  List<Song> currentSongs = <Song>[];
  List<String> allArtists = [];
  Song? currentSong;

  @override
  void initState() {
    super.initState();
    _initSongs();
  }

  @override
  Widget build(BuildContext context) {
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
    await SongRepository().initDB();
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

  void _back() {
    if (currentPageVariant == PageVariant.songText) {
      setState(() {
        currentPageVariant = PageVariant.songList;
        currentSong = null;
      });
    }
  }
}

enum PageVariant { songList, songText }
