import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:russian_rock_song_book/listen_to_music.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:russian_rock_song_book/warning.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_actions.dart';
import 'app_strings.dart';
import 'app_theme.dart';
import 'cloud_repository.dart';
import 'cloud_search_pager.dart';
import 'cloud_song.dart';
import 'order_by.dart';

class AppState {
  PageVariant currentPageVariant = PageVariant.start;

  AppSettings settings = AppSettings();
  LocalState localState = LocalState();
  CloudState cloudState = CloudState();
}

class AppSettings {
  AppTheme theme = AppTheme.themeDark;
  ListenToMusicPreference listenToMusicPreference = ListenToMusicPreference.yandexAndYoutube;
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
  CloudSearchPager? currentSearchPager;
  SearchState currentSearchState = SearchState.loading;
  int currentCloudSongCount = 0;
  int? lastPage;
  CloudSong? currentCloudSong;
  int currentCloudSongPosition = -1;
  int cloudScrollPosition = 0;
  bool needScroll = false;
  String searchForBackup = '';
  OrderBy orderByBackup = OrderBy.byIdDesc;
  Map<CloudSong?, int> allLikes = HashMap();
  Map<CloudSong?, int> allDislikes = HashMap();

  int get extraLikesForCurrent => allLikes[currentCloudSong] ?? 0;
  int get extraDislikesForCurrent => allDislikes[currentCloudSong] ?? 0;
}

enum PageVariant {
  start, songList, songText, cloudSearch, cloudSongText, settings;

  String get route {
    switch (this) {
      case start:
        return '/start';
      case songList:
        return '/songList';
      case songText:
        return '/songText';
      case cloudSearch:
        return '/cloudSearch';
      case cloudSongText:
        return '/cloudSongText';
      case settings:
        return '/settings';
    }
  }
}

typedef AppStateChanger = void Function(AppState newState);
typedef NavigatorStateGetter = NavigatorState? Function();

class AppStateMachine {
  final NavigatorStateGetter getNavigatorState;

  AppStateMachine(this.getNavigatorState);

  bool performAction(AppStateChanger changeState, AppState appState, AppUIAction action) {
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
      _sendWarning(appState, action.warning);
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
    } else if (action is UpdateCloudSongListNeedScroll) {
      _updateCloudSongListNeedScroll(changeState, appState, action.needScroll);
    } else if (action is OpenSettings) {
      _openSettings(changeState, appState);
    } else if (action is SaveSettings) {
      _saveSettings(changeState, appState, action.settings);
    } else if (action is ReloadSettings) {
      _reloadSettings(changeState, appState);
    } else {
      return false;
    }
    return true;
  }

  void _selectPageVariant(AppState appState, PageVariant newPageVariant) {
    final oldPageVariant = appState.currentPageVariant;

    if (oldPageVariant == PageVariant.start && newPageVariant == PageVariant.songList) {
      getNavigatorState()?.pop();
      getNavigatorState()?.pushNamed(PageVariant.songList.route);
    } else if (oldPageVariant == PageVariant.songList && newPageVariant == PageVariant.songText) {
      getNavigatorState()?.pushNamed(PageVariant.songText.route);
    } else if (oldPageVariant == PageVariant.songText && newPageVariant == PageVariant.songList) {
      getNavigatorState()?.pop();
    } else if (oldPageVariant == PageVariant.songList && newPageVariant == PageVariant.cloudSearch) {
      getNavigatorState()?.pushNamed(PageVariant.cloudSearch.route);
    } else if (oldPageVariant == PageVariant.cloudSearch && newPageVariant == PageVariant.songList) {
      getNavigatorState()?.pop();
    } else if (oldPageVariant == PageVariant.cloudSearch && newPageVariant == PageVariant.cloudSongText) {
      getNavigatorState()?.pushNamed(PageVariant.cloudSongText.route);
    } else if (oldPageVariant == PageVariant.cloudSongText && newPageVariant == PageVariant.cloudSearch) {
      getNavigatorState()?.pop();
    } else if (oldPageVariant == PageVariant.songList && newPageVariant == PageVariant.settings) {
      getNavigatorState()?.pushNamed(PageVariant.settings.route);
    } else if (oldPageVariant == PageVariant.settings && newPageVariant == PageVariant.songList) {
      getNavigatorState()?.pop();
    }

    appState.currentPageVariant = newPageVariant;
  }

  void _showSongList(AppStateChanger changeState, AppState appState) {
    _initSongs(changeState, appState);
    final newAppState = appState;
    _selectPageVariant(newAppState, PageVariant.songList);
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
      _selectPageVariant(newAppState, PageVariant.cloudSearch);
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
    _selectPageVariant(newAppState, PageVariant.songText);
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
      _selectPageVariant(newAppState, PageVariant.songList);
      newLocalState.currentSong = null;
      newLocalState.currentSongPosition = -1;
      newAppState.localState = newLocalState;
      changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSearch) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList);
      changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSongText) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      _selectPageVariant(newAppState, PageVariant.cloudSearch);
      newCloudState.currentCloudSong = null;
      newCloudState.currentCloudSongPosition = -1;
      newCloudState.needScroll = true;
      newAppState.cloudState = newCloudState;
      changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.settings) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList);
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
    final textWasChanged = appState.localState.currentSong!.textWasChanged;
    if (!textWasChanged) {
      _showToast(appState, AppStrings.strToastUploadDuplicate);
    } else {
      final cloudSong = CloudSong.fromSong(appState.localState.currentSong!);
      CloudRepository().addCloudSong(cloudSong, () {
        _showToast(appState, AppStrings.strToastUploadSuccess);
      }, (message) {
        _showToast(appState, message);
      }, () {
        _showToast(appState, AppStrings.strToastInAppError);
      });
    }
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
    _showToast(newState, AppStrings.strToastDeleted);
  }

  void _showToast(AppState appState, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: appState.settings.theme.colorMain,
        textColor: appState.settings.theme.colorBg,
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

  Future<void> _sendWarning(AppState appState, Warning warning) async {
    await CloudRepository().addWarning(warning, () {
      _showToast(appState, AppStrings.strToastWarningSendSuccess);
    }, (message) {
      _showToast(appState, AppStrings.strToastWarningSendError);
    }, () {
      _showToast(appState, AppStrings.strToastInAppError);
    });
  }

  Future<void> _performCloudSearch(AppStateChanger changeState, AppState appState, String searchFor, OrderBy orderBy) async {
    _resetCloudSearch(changeState, appState);
    final newState = appState;
    newState.cloudState.currentSearchPager = CloudSearchPager(searchFor, orderBy, (searchState, count, lastPage) {
      newState.cloudState.currentSearchState = searchState;
      newState.cloudState.currentCloudSongCount = count;
      newState.cloudState.lastPage = lastPage;
      log("$searchState $count $lastPage");
      changeState(newState);
    });
    changeState(newState);
  }

  void _resetCloudSearch(AppStateChanger changeState, AppState appState) {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentSearchState = SearchState.loading;
    newCloudState.currentCloudSongCount = 0;
    newCloudState.lastPage = null;
    newCloudState.cloudScrollPosition = 0;
    newCloudState.allLikes = HashMap();
    newCloudState.allDislikes = HashMap();
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

  Future<void> _selectCloudSong(AppStateChanger changeState, AppState appState, int position) async {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentCloudSongPosition = position;
    newCloudState.cloudScrollPosition = position;
    newCloudState.currentCloudSong = await newCloudState.currentSearchPager?.getCloudSong(position);
    _selectPageVariant(newAppState, PageVariant.cloudSongText);
    changeState(newAppState);
  }

  Future<void> _prevCloudSong(AppStateChanger changeState, AppState appState) async {
    if (appState.cloudState.currentCloudSongPosition > 0) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition -= 1;
      newCloudState.cloudScrollPosition = newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = await newCloudState.currentSearchPager?.getCloudSong(
          newCloudState.currentCloudSongPosition);
      changeState(newAppState);
    }
  }

  Future<void> _nextCloudSong(AppStateChanger changeState, AppState appState) async {
    if (appState.cloudState.currentCloudSongPosition < appState.cloudState.currentCloudSongCount - 1) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition += 1;
      newCloudState.cloudScrollPosition = newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = await newCloudState.currentSearchPager?.getCloudSong(
          newCloudState.currentCloudSongPosition);
      changeState(newAppState);
    }
  }

  Future<void> _downloadCurrent(AppStateChanger changeState, AppState appState) async {
    await SongRepository().addSongFromCloud(appState.cloudState.currentCloudSong!.asSong());
    final newState = appState;
    newState.localState.allArtists = await SongRepository().getArtists();
    final count = await SongRepository().getCountByArtist(newState.localState.currentArtist);
    newState.localState.currentCount = count;
    newState.localState.currentSongs = await SongRepository()
        .getSongsByArtist(appState.localState.currentArtist);
    changeState(newState);
    _showToast(newState, AppStrings.strToastDownloadSuccess);
  }

  void _likeCurrent(AppStateChanger changeState, AppState appState) {
    final cloudSong = appState.cloudState.currentCloudSong!;
    CloudRepository().vote(cloudSong, 1, (voteValue) {
      final newState = appState;
      final oldCount = newState.cloudState.allLikes[cloudSong] ?? 0;
      newState.cloudState.allLikes[cloudSong] = oldCount + 1;
      changeState(newState);
      _showToast(appState, AppStrings.strToastVoteSuccess);
    }, (message) {
      _showToast(appState, message);
    }, () {
      _showToast(appState, AppStrings.strToastInAppError);
    });
  }

  void _dislikeCurrent(AppStateChanger changeState, AppState appState) {
    final cloudSong = appState.cloudState.currentCloudSong!;
    CloudRepository().vote(cloudSong, -1, (voteValue) {
      final newState = appState;
      final oldCount = newState.cloudState.allDislikes[cloudSong] ?? 0;
      newState.cloudState.allDislikes[cloudSong] = oldCount + 1;
      changeState(newState);
      _showToast(appState, AppStrings.strToastVoteSuccess);
    }, (message) {
      _showToast(appState, message);
    }, () {
      _showToast(appState, AppStrings.strToastInAppError);
    });
  }

  void _updateCloudSongListNeedScroll(AppStateChanger changeState, AppState appState, bool needScroll) {
    final newState = appState;
    newState.cloudState.needScroll = needScroll;
    changeState(newState);
  }

  Future<void> _saveSettings(AppStateChanger changeState, AppState appState, AppSettings settings) async {
    final newThemeIndex = AppTheme.indexFromDescription(settings.theme.description);
    await ThemeVariant.saveThemeIndex(newThemeIndex);

    await _reloadSettings(changeState, appState);
  }

  Future<void> _reloadSettings(AppStateChanger changeState, AppState appState) async {
    final theme = await ThemeVariant.getCurrentTheme();
    final listenToMusicPreference = await ListenToMusicPreference.getCurrentPreference();
    final newState = appState;
    newState.settings.theme = theme;
    newState.settings.listenToMusicPreference = listenToMusicPreference;
    changeState(newState);
  }

  Future<void> _openSettings(AppStateChanger changeState, AppState appState) async {
    final newAppState = appState;
    _selectPageVariant(newAppState, PageVariant.settings);
    changeState(newAppState);
  }
}