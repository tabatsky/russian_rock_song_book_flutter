import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:russian_rock_song_book/cloud_search_page.dart';
import 'dart:developer';

import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_list_page.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/song_text_page.dart';
import 'package:russian_rock_song_book/start_page.dart';
import 'package:russian_rock_song_book/app_theme.dart';
import 'package:russian_rock_song_book/app_strings.dart';

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
  int currentCount = 0;
  List<String> allArtists = [];
  Song? currentSong;
  int currentSongPosition = -1;
  int scrollPosition = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (currentPageVariant) {
      case PageVariant.start:
        return StartPage(() {
          _showSongList();
        });
      case PageVariant.songList:
        return SongListPage(theme, allArtists, currentArtist, currentSongs, scrollPosition, (position) {
          _selectSong(position);
        }, (artist) {
          Navigator.pop(context);
          _selectArtist(artist);
        });
      case PageVariant.songText:
        return SongTextPage(
            theme,
            currentSong, () {
          _back();
        }, () {
          _prevSong();
        }, () {
          _nextSong();
        }, () {
          _toggleFavorite();
        }, (updatedText) {
          _saveSongText(updatedText);
        });
      case PageVariant.cloudSearch:
        return CloudSearchPage(theme, () {
          _back();
        });
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
    if (artist == SongRepository.artistCloudSearch) {
      setState(() {
        currentPageVariant = PageVariant.cloudSearch;
      });
    } else {
      final songs = await SongRepository().getSongsByArtist(artist);
      setState(() {
        currentArtist = artist;
        currentSongs = songs;
        currentCount = songs.length;
        scrollPosition = 0;
      });
    }
  }

  void _selectSong(int position) {
    setState(() {
      currentSongPosition = position;
      scrollPosition = position;
      currentSong = currentSongs[position];
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
    log('back');
    if (currentPageVariant == PageVariant.songText) {
      setState(() {
        currentPageVariant = PageVariant.songList;
        currentSong = null;
        currentSongPosition = -1;
      });
    } else if (currentPageVariant == PageVariant.cloudSearch) {
      setState(() {
        currentPageVariant = PageVariant.songList;
      });
    }
  }

  void _prevSong() {
    if (currentSongPosition > 0) {
      setState(() {
        currentSongPosition -= 1;
        scrollPosition = currentSongPosition;
        currentSong = currentSongs[currentSongPosition];
      });
    }
  }

  void _nextSong() {
    if (currentSongPosition < currentSongs.length - 1) {
      setState(() {
        currentSongPosition += 1;
        scrollPosition = currentSongPosition;
        currentSong = currentSongs[currentSongPosition];
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (currentSong != null) {
      final song = currentSong!;
      final becomeFavorite = !song.favorite;
      song.favorite = becomeFavorite;
      await SongRepository().updateSong(song);

      if (!becomeFavorite && currentArtist == SongRepository.artistFavorite) {
        final count = await SongRepository().getCountByArtist(SongRepository.artistFavorite);
        if (count > 0) {
          final int newSongPosition;
          if (currentSongPosition >= count) {
            newSongPosition = currentSongPosition - 1;
          } else {
            newSongPosition = currentSongPosition;
          }
          setState(() {
            currentCount = count;
            currentSongPosition = newSongPosition;
            log('set state 1 done');
          });
        } else {
          setState(() {
            currentCount = count;
            log('set state 2 done');
          });
          _back();
        }
      }

      await _refreshCurrentSong();

      if (becomeFavorite) {
        _showToast(AppStrings.strToastAddedToFavorite);
      } else {
        _showToast(AppStrings.strToastDeletedFromFavorite);
      }
    }
  }

  Future<void> _saveSongText(String updatedText) async {
    if (currentSong != null) {
      final song = currentSong!;
      song.text = updatedText;
      await SongRepository().updateSong(song);
      await _refreshCurrentSong();
    }
  }

  Future<void> _refreshCurrentSong() async {
    log('refresh current song');
    final songs = await SongRepository().getSongsByArtist(currentArtist);
    setState(() {
      currentSong = currentSongPosition >= 0 ? songs.elementAtOrNull(currentSongPosition) : null;
      log(currentSong.toString());
      currentSongs = songs;
    });
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: theme.colorMain,
        textColor: theme.colorBg,
        fontSize: 16.0
    );
  }
}

enum PageVariant { start, songList, songText, cloudSearch }
