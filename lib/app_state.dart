import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_actions.dart';
import 'app_strings.dart';
import 'app_theme.dart';
import 'cloud_repository.dart';
import 'cloud_song.dart';
import 'order_by.dart';

class AppState {
  AppTheme theme = AppTheme.themeDark;

  PageVariant currentPageVariant = PageVariant.start;

  LocalState localState = LocalState();
  CloudState cloudState = CloudState();
}

class LocalState {
  String currentArtist = 'Кино';
  List<Song> currentSongs = <Song>[];
  int currentCount = 0;
  List<String> allArtists = [];
  Song? currentSong;
  int currentSongPosition = -1;
  int scrollPosition = 0;
}

class CloudState {
  List<CloudSong> currentCloudSongs = [];
  SearchState currentSearchState = SearchState.loading;
  int currentCloudSongCount = 0;
  CloudSong? currentCloudSong;
  int currentCloudSongPosition = -1;
  int cloudScrollPosition = 0;
  String searchForBackup = '';
  OrderBy orderByBackup = OrderBy.byIdDesc;
}

enum PageVariant { start, songList, songText, cloudSearch, cloudSongText }

enum SearchState { empty, error, loading, loaded }

typedef AppStateChanger = void Function(AppState newState);

class AppStateMachine {

  bool performAction(AppStateChanger changeState, AppState appState, UIAction action) {
    if (action is ShowSongList) {
      _showSongList(changeState, appState);
    } else if (action is ArtistClick) {
      _selectArtist(changeState, appState, action.artist);
    } else if (action is SongClick) {
      _selectSong(changeState, appState, action.position);
    } else if (action is PrevSong) {
      _prevSong(changeState, appState);
    } else if (action is NextSong) {
      _nextSong(changeState, appState);
    } else if (action is Back) {
      _back(changeState, appState);
    } else if (action is ToggleFavorite) {
      _toggleFavorite(changeState, appState);
    } else if (action is SaveSongText) {
      _saveSongText(changeState, appState, action.updatedText);
    } else if (action is UploadCurrentToCloud) {
      _uploadCurrentToCloud(appState);
    } else if (action is DeleteCurrentToTrash) {
      _deleteCurrentToTrash(changeState, appState);
    } else if (action is OpenVkMusic) {
      _openVkMusic(appState, action.searchFor);
    } else if (action is OpenYandexMusic) {
      _openYandexMusic(appState, action.searchFor);
    } else if (action is OpenYoutubeMusic) {
      _openYoutubeMusic(appState, action.searchFor);
    } else if (action is SendWarning) {
      _sendWarning(appState, action.comment);
    } else if (action is CloudSearch) {
      _performCloudSearch(changeState, appState, action.searchFor, action.orderBy);
    } else if (action is BackupSearchState) {
      _backupSearchState(changeState, appState, action.searchFor, action.orderBy);
    } else if (action is CloudSongClick) {
      _selectCloudSong(changeState, appState, action.position);
    } else if (action is PrevCloudSong) {
      _prevCloudSong(changeState, appState);
    } else if (action is NextCLoudSong) {
      _nextCloudSong(changeState, appState);
    } else if (action is DownloadCurrent) {
      _downloadCurrent(changeState, appState);
    } else if (action is LikeCurrent) {
      _likeCurrent(changeState, appState);
    } else if (action is DislikeCurrent) {
      _dislikeCurrent(changeState, appState);
    } else {
      return false;
    }
    return true;
  }

  void _showSongList(AppStateChanger changeState, AppState appState) {
    _initSongs(changeState, appState);
    final newAppState = appState;
    newAppState.currentPageVariant = PageVariant.songList;
    changeState(newAppState);
  }

  Future<void> _initSongs(AppStateChanger changeState, AppState appState) async {
    await _initAllArtists(changeState, appState);
    await _selectArtist(changeState, appState, 'Кино');
  }

  Future<void> _initAllArtists(AppStateChanger changeState, AppState appState) async {
    final artists = await SongRepository().getArtists();
    log(artists.toString());
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.allArtists = artists;
    newAppState.localState = newLocalState;
    changeState(newAppState);
  }

  Future<void> _selectArtist(AppStateChanger changeState, AppState appState, String artist) async {
    log("select artist: $artist");
    if (artist == SongRepository.artistCloudSearch) {
      _backupSearchState(changeState, appState, '', OrderBy.byIdDesc);
      final newAppState = appState;
      newAppState.currentPageVariant = PageVariant.cloudSearch;
      changeState(newAppState);
      _performCloudSearch(changeState, appState, '', OrderBy.byIdDesc);
    } else {
      final songs = await SongRepository().getSongsByArtist(artist);
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentArtist = artist;
      newLocalState.currentSongs = songs;
      newLocalState.currentCount = songs.length;
      newLocalState.scrollPosition = 0;
      newAppState.localState = newLocalState;
      changeState(newAppState);
    }
  }

  void _selectSong(AppStateChanger changeState, AppState appState, int position) {
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.currentSongPosition = position;
    newLocalState.scrollPosition = position;
    newLocalState.currentSong = newLocalState.currentSongs[position];
    newAppState.localState = newLocalState;
    newAppState.currentPageVariant = PageVariant.songText;
    changeState(newAppState);
  }

  void _prevSong(AppStateChanger changeState, AppState appState) {
    if (appState.localState.currentSongPosition > 0) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSongPosition -= 1;
      newLocalState.scrollPosition = newLocalState.currentSongPosition;
      newLocalState.currentSong = newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      changeState(newAppState);
    }
  }

  void _nextSong(AppStateChanger changeState, AppState appState) {
    if (appState.localState.currentSongPosition < appState.localState.currentSongs.length - 1) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSongPosition += 1;
      newLocalState.scrollPosition = newLocalState.currentSongPosition;
      newLocalState.currentSong = newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      changeState(newAppState);
    }
  }

  void _back(AppStateChanger changeState, AppState appState) {
    log('back');
    if (appState.currentPageVariant == PageVariant.songText) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSong = null;
      newLocalState.currentSongPosition = -1;
      newAppState.localState = newLocalState;
      newAppState.currentPageVariant = PageVariant.songList;
      changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSearch) {
      final newAppState = appState;
      newAppState.currentPageVariant = PageVariant.songList;
      changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSongText) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSong = null;
      newCloudState.currentCloudSongPosition = -1;
      newAppState.cloudState = newCloudState;
      newAppState.currentPageVariant = PageVariant.cloudSearch;
      changeState(newAppState);
    }
  }

  Future<void> _toggleFavorite(AppStateChanger changeState, AppState appState) async {
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
          changeState(newAppState);
        } else {
          newLocalState.currentCount = count;
          newAppState.localState = newLocalState;
          changeState(newAppState);
          _back(changeState, newAppState);
        }
      }

      await _refreshCurrentSong(changeState, appState);

      if (becomeFavorite) {
        _showToast(appState, AppStrings.strToastAddedToFavorite);
      } else {
        _showToast(appState, AppStrings.strToastDeletedFromFavorite);
      }
    }
  }

  Future<void> _saveSongText(AppStateChanger changeState, AppState appState, String updatedText) async {
    if (appState.localState.currentSong != null) {
      final song = appState.localState.currentSong!;
      song.text = updatedText;
      await SongRepository().updateSong(song);
      await _refreshCurrentSong(changeState, appState);
    }
  }

  Future<void> _refreshCurrentSong(AppStateChanger changeState, AppState appState) async {
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
    changeState(newAppState);
  }

  void _uploadCurrentToCloud(AppState appState) {
    _showToast(appState, 'upload will be here');
  }

  Future<void> _deleteCurrentToTrash(AppStateChanger changeState, AppState appState) async {
    final newState = appState;
    final song = newState.localState.currentSong!;
    song.deleted = true;
    await SongRepository().updateSong(song);
    final count = await SongRepository().getCountByArtist(newState.localState.currentArtist);
    newState.localState.currentCount = count;
    newState.localState.allArtists = await SongRepository().getArtists();
    if (newState.localState.currentCount > 0) {
      if (newState.localState.currentSongPosition >= newState.localState.currentCount) {
        newState.localState.currentSongPosition -= 1;
      }
      _refreshCurrentSong(changeState, newState);
    } else {
      _back(changeState, newState);
    }
    newState.localState.currentSongs = await SongRepository()
        .getSongsByArtist(appState.localState.currentArtist);
    changeState(newState);
    _showToast(newState, 'Удалено');
  }

  void _showToast(AppState appState, String msg) {
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

  void _openVkMusic(AppState appState, String searchFor) {
    final searchForEncoded = Uri.encodeComponent(searchFor);
    final url = "https://m.vk.com/audio?q=$searchForEncoded";
    _openMusicAtExternalBrowser(appState, url);
  }

  void _openYandexMusic(AppState appState, String searchFor) {
    final searchForEncoded = Uri.encodeComponent(searchFor);
    final url = "https://music.yandex.ru/search?text=$searchForEncoded";
    _openMusicAtExternalBrowser(appState, url);
  }

  void _openYoutubeMusic(AppState appState, String searchFor) {
    final searchForEncoded = Uri.encodeComponent(searchFor);
    final url = "https://music.youtube.com/search?q=$searchForEncoded";
    _openMusicAtExternalBrowser(appState, url);
  }

  void _openMusicAtExternalBrowser(AppState appState, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      log('Cannot open url');
      _showToast(appState, AppStrings.strToastCannotOpenUrl);
    }
  }

  void _sendWarning(AppState appState, String comment) {
    _showToast(appState, 'send warning will be here:\n$comment');
  }

  Future<void> _performCloudSearch(AppStateChanger changeState, AppState appState, String searchFor, OrderBy orderBy) async {
    _resetCloudSearch(changeState, appState);
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
      changeState(newAppState);
    } catch (e) {
      log("Exception: $e");
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentSearchState = SearchState.error;
      newAppState.cloudState = newCloudState;
      changeState(newAppState);
    }
  }

  void _resetCloudSearch(AppStateChanger changeState, AppState appState) {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentSearchState = SearchState.loading;
    newCloudState.currentCloudSongs = [];
    newCloudState.currentCloudSongCount = 0;
    newCloudState.cloudScrollPosition = 0;
    newAppState.cloudState = newCloudState;
    changeState(newAppState);
  }

  void _backupSearchState(AppStateChanger changeState, AppState appState, String searchFor, OrderBy orderBy) {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.searchForBackup = searchFor;
    newCloudState.orderByBackup = orderBy;
    newAppState.cloudState = newCloudState;
    changeState(newAppState);
  }

  void _selectCloudSong(AppStateChanger changeState, AppState appState, int position) {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentCloudSongPosition = position;
    newCloudState.cloudScrollPosition = position;
    newCloudState.currentCloudSong = newCloudState.currentCloudSongs[position];
    newAppState.currentPageVariant = PageVariant.cloudSongText;
    changeState(newAppState);
  }

  void _prevCloudSong(AppStateChanger changeState, AppState appState) {
    if (appState.cloudState.currentCloudSongPosition > 0) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition -= 1;
      newCloudState.cloudScrollPosition = newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = newCloudState
          .currentCloudSongs[newCloudState.currentCloudSongPosition];
      changeState(newAppState);
    }
  }

  void _nextCloudSong(AppStateChanger changeState, AppState appState) {
    if (appState.cloudState.currentCloudSongPosition < appState.cloudState.currentCloudSongs.length - 1) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition += 1;
      newCloudState.cloudScrollPosition = newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = newCloudState
          .currentCloudSongs[newCloudState.currentCloudSongPosition];
      changeState(newAppState);
    }
  }

  void _downloadCurrent(AppStateChanger changeState, AppState appState) {
    _showToast(appState, 'download will be here');
  }

  void _likeCurrent(AppStateChanger changeState, AppState appState) {
    _showToast(appState, 'like will be here');
  }

  void _dislikeCurrent(AppStateChanger changeState, AppState appState) {
    _showToast(appState, 'dislike will be here');
  }
}