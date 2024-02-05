import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:russian_rock_song_book/app_callbacks.dart';
import 'package:russian_rock_song_book/cloud_search_page.dart';
import 'package:russian_rock_song_book/cloud_song_text_page.dart';
import 'package:russian_rock_song_book/order_by.dart';
import 'dart:developer';

import 'package:russian_rock_song_book/song_list_page.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/song_text_page.dart';
import 'package:russian_rock_song_book/start_page.dart';
import 'package:russian_rock_song_book/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_state.dart';
import 'cloud_repository.dart';

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
  AppState appState = AppState();

  LocalCallbacks? localCallbacks;
  CloudCallbacks? cloudCallbacks;

  @override
  void initState() {
    super.initState();
    setState(() {
      localCallbacks = LocalCallbacks((position) {
        _selectSong(position);
      }, (artist) {
        _selectArtist(artist);
      }, () {
        _back();
      }, () {
        _prevSong();
      }, () {
        _nextSong();
      }, () {
        _toggleFavorite();
      }, (updatedText) {
        _saveSongText(updatedText);
      }, () {
        log('upload to cloud will be here');
      }, (searchFor) {
        _openVkMusic(searchFor);
      }, (searchFor) {
        _openYandexMusic(searchFor);
      }, (searchFor) {
        _openYoutubeMusic(searchFor);
      });

      cloudCallbacks = CloudCallbacks((searchFor, orderBy) {
        _performCloudSearch(searchFor, orderBy);
      }, (searchFor, orderBy) {
        _backupSearchFor(searchFor, orderBy);
      }, (position) {
        _selectCloudSong(position);
      }, () {
        _back();
      }, () {
        _prevCloudSong();
      }, () {
        _nextCloudSong();
      }, () {
        log('download from cloud will be here');
      }, (searchFor) {
        _openVkMusic(searchFor);
      }, (searchFor) {
        _openYandexMusic(searchFor);
      }, (searchFor) {
        _openYoutubeMusic(searchFor);
      }, () {
        log('like will be here');
      }, () {
        log('dislike will be here');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (appState.currentPageVariant) {
      case PageVariant.start:
        return StartPage(() {
          _showSongList();
        });
      case PageVariant.songList:
        return SongListPage(appState.theme, appState.localState, localCallbacks);
      case PageVariant.songText:
        return SongTextPage(
            appState.theme,
            appState.localState.currentSong,
            localCallbacks);
      case PageVariant.cloudSearch:
        return CloudSearchPage(appState.theme, appState.cloudState, cloudCallbacks);
      case PageVariant.cloudSongText:
        return CloudSongTextPage(appState.theme, appState.cloudState, cloudCallbacks);
    }
  }

  Future<void> _initSongs() async {
    await _initAllArtists();
    await _selectArtist('Кино');
  }

  Future<void> _initAllArtists() async {
    final artists = await SongRepository().getArtists();
    log(artists.toString());
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.allArtists = artists;
    newAppState.localState = newLocalState;
    setState(() {
      appState = newAppState;
    });
  }

  Future<void> _selectArtist(String artist) async {
    log("select artist: $artist");
    if (artist == SongRepository.artistCloudSearch) {
      _backupSearchFor('', OrderBy.byIdDesc);
      final newAppState = appState;
      newAppState.currentPageVariant = PageVariant.cloudSearch;
      setState(() {
        appState = newAppState;
      });
      _performCloudSearch('', OrderBy.byIdDesc);
    } else {
      final songs = await SongRepository().getSongsByArtist(artist);
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentArtist = artist;
      newLocalState.currentSongs = songs;
      newLocalState.currentCount = songs.length;
      newLocalState.scrollPosition = 0;
      newAppState.localState = newLocalState;
      setState(() {
        appState = newAppState;
      });
    }
  }

  void _selectSong(int position) {
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.currentSongPosition = position;
    newLocalState.scrollPosition = position;
    newLocalState.currentSong = newLocalState.currentSongs[position];
    newAppState.localState = newLocalState;
    newAppState.currentPageVariant = PageVariant.songText;
    setState(() {
      appState = newAppState;
    });
  }

  void _showSongList() {
    _initSongs();
    final newAppState = appState;
    newAppState.currentPageVariant = PageVariant.songList;
    setState(() {
      appState = newAppState;
    });
  }

  void _back() {
    log('back');
    if (appState.currentPageVariant == PageVariant.songText) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSong = null;
      newLocalState.currentSongPosition = -1;
      newAppState.localState = newLocalState;
      newAppState.currentPageVariant = PageVariant.songList;
      setState(() {
        appState = newAppState;
      });
    } else if (appState.currentPageVariant == PageVariant.cloudSearch) {
      final newAppState = appState;
      newAppState.currentPageVariant = PageVariant.songList;
      setState(() {
        appState = newAppState;
      });
    } else if (appState.currentPageVariant == PageVariant.cloudSongText) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSong = null;
      newCloudState.currentCloudSongPosition = -1;
      newAppState.cloudState = newCloudState;
      newAppState.currentPageVariant = PageVariant.cloudSearch;
      setState(() {
        appState = newAppState;
      });
    }
  }

  void _prevSong() {
    if (appState.localState.currentSongPosition > 0) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSongPosition -= 1;
      newLocalState.scrollPosition = newLocalState.currentSongPosition;
      newLocalState.currentSong = newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      setState(() {
        appState = newAppState;
      });
    }
  }

  void _nextSong() {
    if (appState.localState.currentSongPosition < appState.localState.currentSongs.length - 1) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSongPosition += 1;
      newLocalState.scrollPosition = newLocalState.currentSongPosition;
      newLocalState.currentSong = newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      setState(() {
        appState = newAppState;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final newAppState = appState;
    final newLocalState = appState.localState;

    if (newLocalState.currentSong != null) {
      final song = newLocalState.currentSong!;
      final becomeFavorite = !song.favorite;
      song.favorite = becomeFavorite;
      await SongRepository().updateSong(song);

      if (!becomeFavorite && newLocalState.currentArtist == SongRepository.artistFavorite) {
        final count = await SongRepository().getCountByArtist(SongRepository.artistFavorite);
        if (count > 0) {
          final int newSongPosition;
          if (newLocalState.currentSongPosition >= count) {
            newSongPosition = newLocalState.currentSongPosition - 1;
          } else {
            newSongPosition = newLocalState.currentSongPosition;
          }
          newLocalState.currentCount = count;
          newLocalState.currentSongPosition = newSongPosition;
          newAppState.localState = newLocalState;
          setState(() {
            appState = newAppState;
          });
        } else {
          newLocalState.currentCount = count;
          newAppState.localState = newLocalState;
          setState(() {
            appState = newAppState;
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
    if (appState.localState.currentSong != null) {
      final song = appState.localState.currentSong!;
      song.text = updatedText;
      await SongRepository().updateSong(song);
      await _refreshCurrentSong();
    }
  }

  Future<void> _refreshCurrentSong() async {
    log('refresh current song');
    final songs = await SongRepository().getSongsByArtist(appState.localState.currentArtist);
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.currentSong = newLocalState.currentSongPosition >= 0
        ? songs.elementAtOrNull(newLocalState.currentSongPosition)
        : null;
    log(newLocalState.currentSong.toString());
    newLocalState.currentSongs = songs;
    newAppState.localState = newLocalState;
    setState(() {
      appState = newAppState;
    });
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: appState.theme.colorMain,
        textColor: appState.theme.colorBg,
        fontSize: 16.0
    );
  }

  void _resetCloudSearch() {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentSearchState = SearchState.loading;
    newCloudState.currentCloudSongs = [];
    newCloudState.currentCloudSongCount = 0;
    newCloudState.cloudScrollPosition = 0;
    newAppState.cloudState = newCloudState;
    setState(() {
      appState = newAppState;
    });
  }

  Future<void> _performCloudSearch(String searchFor, OrderBy orderBy) async {
    _resetCloudSearch();
    try {
      final cloudSongs = await CloudRepository().cloudSearch(searchFor, orderBy.orderByStr);
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      if (cloudSongs.isNotEmpty) {
        newCloudState.currentSearchState = SearchState.loaded;
      } else {
        newCloudState.currentSearchState = SearchState.empty;
      }
      newCloudState.currentCloudSongs = cloudSongs;
      newCloudState.currentCloudSongCount = cloudSongs.length;
      newAppState.cloudState = newCloudState;
      setState(() {
        appState = newAppState;
      });
    } catch (e) {
      log("Exception: $e");
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentSearchState = SearchState.error;
      newAppState.cloudState = newCloudState;
      setState(() {
        appState = newAppState;
      });
    }
  }

  void _backupSearchFor(String searchFor, OrderBy orderBy) {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.searchForBackup = searchFor;
    newCloudState.orderByBackup = orderBy;
    newAppState.cloudState = newCloudState;
    setState(() {
      appState = newAppState;
    });
  }

  void _selectCloudSong(int position) {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentCloudSongPosition = position;
    newCloudState.cloudScrollPosition = position;
    newCloudState.currentCloudSong = newCloudState.currentCloudSongs[position];
    newAppState.currentPageVariant = PageVariant.cloudSongText;
    setState(() {
      appState = newAppState;
    });
  }

  void _prevCloudSong() {
    if (appState.cloudState.currentCloudSongPosition > 0) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition -= 1;
      newCloudState.cloudScrollPosition = newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = newCloudState
          .currentCloudSongs[newCloudState.currentCloudSongPosition];
      setState(() {
        appState = newAppState;
      });
    }
  }

  void _nextCloudSong() {
    if (appState.cloudState.currentCloudSongPosition < appState.cloudState.currentCloudSongs.length - 1) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition += 1;
      newCloudState.cloudScrollPosition = newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = newCloudState
          .currentCloudSongs[newCloudState.currentCloudSongPosition];
      setState(() {
        appState = newAppState;
      });
    }
  }

  void _openVkMusic(String searchFor) {
    final searchForEncoded = Uri.encodeComponent(searchFor);
    final url = "https://m.vk.com/audio?q=$searchForEncoded";
    _openMusicAtExternalBrowser(url);
  }

  void _openYandexMusic(String searchFor) {
    final searchForEncoded = Uri.encodeComponent(searchFor);
    final url = "https://music.yandex.ru/search?text=$searchForEncoded";
    _openMusicAtExternalBrowser(url);
  }

  void _openYoutubeMusic(String searchFor) {
    final searchForEncoded = Uri.encodeComponent(searchFor);
    final url = "https://music.youtube.com/search?q=$searchForEncoded";
    _openMusicAtExternalBrowser(url);
  }

  void _openMusicAtExternalBrowser(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      log('Cannot open url');
      _showToast(AppStrings.strToastCannotOpenUrl);
    }
  }
}

