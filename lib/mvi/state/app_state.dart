import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:russian_rock_song_book/data/cloud/cloud_search_pager/cloud_search_pager.dart';
import 'package:russian_rock_song_book/data/settings/font_scale_variant.dart';
import 'package:russian_rock_song_book/data/settings/theme_variant.dart';
import 'package:russian_rock_song_book/domain/repository/cloud/cloud_repository.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/ui/font/app_font.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:url_launcher/url_launcher.dart';

class AppState {
  PageVariant currentPageVariant = PageVariant.start;

  AppSettings settings = AppSettings();
  LocalState localState = LocalState();
  CloudState cloudState = CloudState();

  AppState();

  AppState._newInstance(
      this.currentPageVariant,
      this.settings,
      this.localState,
      this.cloudState
      );

  AppState copy() => AppState._newInstance(
      currentPageVariant,
      settings,
      localState.copy(),
      cloudState
  );
}

class AppSettings {
  AppTheme theme = AppTheme.themeDark;
  AppTextStyler textStyler = AppTextStyler(AppTheme.themeDark, 1.0);
  FontScaleVariant fontScaleVariant = FontScaleVariant.m;
  ListenToMusicVariant listenToMusicPreference = ListenToMusicVariant.yandexAndYoutube;
}

class LocalState{
  String currentArtist = 'Кино';
  List<Song> currentSongs = <Song>[];
  int currentCount = 0;
  List<String> allArtists = [];
  Song? currentSong;
  int currentSongPosition = -1;
  int scrollPosition = 0;

  LocalState();

  LocalState._newInstance(
      this.currentArtist,
      this.currentSongs,
      this.currentCount,
      this.allArtists,
      this.currentSong,
      this.currentSongPosition,
      this.scrollPosition
      );

  LocalState copy() => LocalState._newInstance(
      currentArtist,
      currentSongs,
      currentCount,
      allArtists,
      currentSong,
      currentSongPosition,
      scrollPosition
  );
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

typedef AppStateChanger = Future<void> Function(AppState newState);
typedef NavigatorStateGetter = NavigatorState? Function();

class AppStateMachine {
  final NavigatorStateGetter getNavigatorState;

  AppStateMachine(this.getNavigatorState);

  Future<bool> performAction(AppStateChanger changeState, AppState appState, AppUIAction action) async {
    if (action is ShowSongList) {
      await _showSongList(changeState, appState);
    } else if (action is ArtistClick) {
      await _selectArtist(changeState, appState, action.artist);
    } else if (action is SongClick) {
      await _selectSong(changeState, appState, action.position);
    } else if (action is PrevSong) {
      await _prevSong(changeState, appState);
    } else if (action is NextSong) {
      await _nextSong(changeState, appState);
    } else if (action is Back) {
      await _back(changeState, appState, systemBack: action.systemBack);
    } else if (action is ToggleFavorite) {
      await _toggleFavorite(changeState, appState);
    } else if (action is SaveSongText) {
      await _saveSongText(changeState, appState, action.updatedText);
    } else if (action is UploadCurrentToCloud) {
      _uploadCurrentToCloud(appState);
    } else if (action is DeleteCurrentToTrash) {
      await _deleteCurrentToTrash(changeState, appState);
    } else if (action is OpenVkMusic) {
      _openVkMusic(appState, action.searchFor);
    } else if (action is OpenYandexMusic) {
      _openYandexMusic(appState, action.searchFor);
    } else if (action is OpenYoutubeMusic) {
      _openYoutubeMusic(appState, action.searchFor);
    } else if (action is SendWarning) {
      await _sendWarning(appState, action.warning);
    } else if (action is CloudSearch) {
      await _performCloudSearch(changeState, appState, action.searchFor, action.orderBy);
    } else if (action is BackupSearchState) {
      await  _backupSearchState(changeState, appState, action.searchFor, action.orderBy);
    } else if (action is CloudSongClick) {
      await _selectCloudSong(changeState, appState, action.position);
    } else if (action is PrevCloudSong) {
      await _prevCloudSong(changeState, appState);
    } else if (action is NextCLoudSong) {
      await _nextCloudSong(changeState, appState);
    } else if (action is DownloadCurrent) {
      await _downloadCurrent(changeState, appState);
    } else if (action is LikeCurrent) {
      _likeCurrent(changeState, appState);
    } else if (action is DislikeCurrent) {
      _dislikeCurrent(changeState, appState);
    } else if (action is UpdateCloudSongListNeedScroll) {
      await _updateCloudSongListNeedScroll(changeState, appState, action.needScroll);
    } else if (action is OpenSettings) {
      await _openSettings(changeState, appState);
    } else if (action is SaveSettings) {
      await _saveSettings(changeState, appState, action.settings);
    } else if (action is ReloadSettings) {
      await _reloadSettings(changeState, appState);
    } else {
      return false;
    }
    return true;
  }

  void _selectPageVariant(AppState appState, PageVariant newPageVariant, {bool systemBack = false}) {
    final oldPageVariant = appState.currentPageVariant;

    if (oldPageVariant == PageVariant.start && newPageVariant == PageVariant.songList) {
      getNavigatorState()?.pop();
      getNavigatorState()?.pushNamed(PageVariant.songList.route);
    } else if (oldPageVariant == PageVariant.songList && newPageVariant == PageVariant.songText) {
      getNavigatorState()?.pushNamed(PageVariant.songText.route);
    } else if (oldPageVariant == PageVariant.songText && newPageVariant == PageVariant.songList && !systemBack) {
      getNavigatorState()?.pop();
    } else if (oldPageVariant == PageVariant.songList && newPageVariant == PageVariant.cloudSearch) {
      getNavigatorState()?.pushNamed(PageVariant.cloudSearch.route);
    } else if (oldPageVariant == PageVariant.cloudSearch && newPageVariant == PageVariant.songList && !systemBack) {
      getNavigatorState()?.pop();
    } else if (oldPageVariant == PageVariant.cloudSearch && newPageVariant == PageVariant.cloudSongText) {
      getNavigatorState()?.pushNamed(PageVariant.cloudSongText.route);
    } else if (oldPageVariant == PageVariant.cloudSongText && newPageVariant == PageVariant.cloudSearch && !systemBack) {
      getNavigatorState()?.pop();
    } else if (oldPageVariant == PageVariant.songList && newPageVariant == PageVariant.settings) {
      getNavigatorState()?.pushNamed(PageVariant.settings.route);
    } else if (oldPageVariant == PageVariant.settings && newPageVariant == PageVariant.songList && !systemBack) {
      getNavigatorState()?.pop();
    }

    appState.currentPageVariant = newPageVariant;
  }

  Future<void> _showSongList(AppStateChanger changeState, AppState appState) async {
    await _initSongs(changeState, appState);
    final newAppState = appState;
    _selectPageVariant(newAppState, PageVariant.songList);
    await changeState(newAppState);
  }

  Future<void> _initSongs(AppStateChanger changeState, AppState appState) async {
    await _initAllArtists(changeState, appState);
    await _selectArtist(changeState, appState, 'Кино');
  }

  Future<void> _initAllArtists(AppStateChanger changeState, AppState appState) async {
    final artists = await GetIt.I<SongRepository>().getArtists();
    log(artists.toString());
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.allArtists = artists;
    newAppState.localState = newLocalState;
    await changeState(newAppState);
  }

  Future<void> _selectArtist(AppStateChanger changeState, AppState appState, String artist) async {
    log("select artist: $artist");
    if (artist == SongRepository.artistCloudSearch) {
      _backupSearchState(changeState, appState, '', OrderBy.byIdDesc);
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.cloudSearch);
      await changeState(newAppState);
      _performCloudSearch(changeState, appState, '', OrderBy.byIdDesc);
    } else {
      final songs = await GetIt.I<SongRepository>().getSongsByArtist(artist);
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentArtist = artist;
      newLocalState.currentSongs = songs;
      newLocalState.currentCount = songs.length;
      newLocalState.scrollPosition = 0;
      newAppState.localState = newLocalState;
      await changeState(newAppState);
    }
  }

  Future<void> _selectSong(AppStateChanger changeState, AppState appState, int position) async {
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.currentSongPosition = position;
    newLocalState.scrollPosition = position;
    newLocalState.currentSong = newLocalState.currentSongs[position];
    newAppState.localState = newLocalState;
    _selectPageVariant(newAppState, PageVariant.songText);
    await changeState(newAppState);
  }

  Future<void> _prevSong(AppStateChanger changeState, AppState appState) async {
    if (appState.localState.currentSongPosition > 0) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSongPosition -= 1;
      newLocalState.scrollPosition = newLocalState.currentSongPosition;
      newLocalState.currentSong = newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      await changeState(newAppState);
    }
  }

  Future<void> _nextSong(AppStateChanger changeState, AppState appState) async {
    if (appState.localState.currentSongPosition < appState.localState.currentSongs.length - 1) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSongPosition += 1;
      newLocalState.scrollPosition = newLocalState.currentSongPosition;
      newLocalState.currentSong = newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      await changeState(newAppState);
    }
  }

  Future<void> _back(AppStateChanger changeState, AppState appState, {bool systemBack = false}) async {
    log("back, system: $systemBack");
    if (appState.currentPageVariant == PageVariant.songText) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      _selectPageVariant(newAppState, PageVariant.songList, systemBack: systemBack);
      newLocalState.currentSong = null;
      newLocalState.currentSongPosition = -1;
      newAppState.localState = newLocalState;
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSearch) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList, systemBack: systemBack);
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSongText) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      _selectPageVariant(newAppState, PageVariant.cloudSearch, systemBack: systemBack);
      newCloudState.currentCloudSong = null;
      newCloudState.currentCloudSongPosition = -1;
      newCloudState.needScroll = true;
      newAppState.cloudState = newCloudState;
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.settings) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList, systemBack: systemBack);
      await changeState(newAppState);
    }
  }

  Future<void> _toggleFavorite(AppStateChanger changeState, AppState appState) async {
    final newAppState = appState;
    final newLocalState = appState.localState;

    if (newLocalState.currentSong != null) {
      final song = newLocalState.currentSong!;
      final becomeFavorite = !song.favorite;
      song.favorite = becomeFavorite;
      await GetIt.I<SongRepository>().updateSong(song);

      if (!becomeFavorite && newLocalState.currentArtist == SongRepository.artistFavorite) {
        final count = await GetIt.I<SongRepository>().getCountByArtist(SongRepository.artistFavorite);
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
          await changeState(newAppState);
        } else {
          newLocalState.currentCount = count;
          newAppState.localState = newLocalState;
          await changeState(newAppState);
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
      await GetIt.I<SongRepository>().updateSong(song);
      await _refreshCurrentSong(changeState, appState);
    }
  }

  Future<void> _refreshCurrentSong(AppStateChanger changeState, AppState appState) async {
    log('refresh current song');
    final songs = await GetIt.I<SongRepository>().getSongsByArtist(appState.localState.currentArtist);
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.currentSong = newLocalState.currentSongPosition >= 0
        ? songs.elementAtOrNull(newLocalState.currentSongPosition)
        : null;
    log(newLocalState.currentSong.toString());
    newLocalState.currentSongs = songs;
    newAppState.localState = newLocalState;
    await changeState(newAppState);
  }

  void _uploadCurrentToCloud(AppState appState) {
    final textWasChanged = appState.localState.currentSong!.textWasChanged;
    if (!textWasChanged) {
      _showToast(appState, AppStrings.strToastUploadDuplicate);
    } else {
      final cloudSong = CloudSong.fromSong(appState.localState.currentSong!);
      GetIt.I<CloudRepository>().addCloudSong(cloudSong, () {
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
    await GetIt.I<SongRepository>().updateSong(song);
    final count = await GetIt.I<SongRepository>().getCountByArtist(newState.localState.currentArtist);
    newState.localState.currentCount = count;
    newState.localState.allArtists = await GetIt.I<SongRepository>().getArtists();
    if (newState.localState.currentCount > 0) {
      if (newState.localState.currentSongPosition >= newState.localState.currentCount) {
        newState.localState.currentSongPosition -= 1;
      }
      _refreshCurrentSong(changeState, newState);
    } else {
      _back(changeState, newState);
    }
    newState.localState.currentSongs = await GetIt.I<SongRepository>()
        .getSongsByArtist(appState.localState.currentArtist);
    await changeState(newState);
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
    await GetIt.I<CloudRepository>().addWarning(warning, () {
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
    newState.cloudState.currentSearchPager = CloudSearchPager(searchFor, orderBy, (searchState, count, lastPage) async {
      newState.cloudState.currentSearchState = searchState;
      newState.cloudState.currentCloudSongCount = count;
      newState.cloudState.lastPage = lastPage;
      log("$searchState $count $lastPage");
      await changeState(newState);
    });
    await changeState(newState);
  }

  Future<void> _resetCloudSearch(AppStateChanger changeState, AppState appState) async {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentSearchState = SearchState.loading;
    newCloudState.currentCloudSongCount = 0;
    newCloudState.lastPage = null;
    newCloudState.cloudScrollPosition = 0;
    newCloudState.allLikes = HashMap();
    newCloudState.allDislikes = HashMap();
    newAppState.cloudState = newCloudState;
    await changeState(newAppState);
  }

  Future<void> _backupSearchState(AppStateChanger changeState, AppState appState, String searchFor, OrderBy orderBy) async {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.searchForBackup = searchFor;
    newCloudState.orderByBackup = orderBy;
    newAppState.cloudState = newCloudState;
    await changeState(newAppState);
  }

  Future<void> _selectCloudSong(AppStateChanger changeState, AppState appState, int position) async {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentCloudSongPosition = position;
    newCloudState.cloudScrollPosition = position;
    newCloudState.currentCloudSong = await newCloudState.currentSearchPager?.getCloudSong(position);
    _selectPageVariant(newAppState, PageVariant.cloudSongText);
    await changeState(newAppState);
  }

  Future<void> _prevCloudSong(AppStateChanger changeState, AppState appState) async {
    if (appState.cloudState.currentCloudSongPosition > 0) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition -= 1;
      newCloudState.cloudScrollPosition = newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = await newCloudState.currentSearchPager?.getCloudSong(
          newCloudState.currentCloudSongPosition);
      await changeState(newAppState);
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
      await changeState(newAppState);
    }
  }

  Future<void> _downloadCurrent(AppStateChanger changeState, AppState appState) async {
    await GetIt.I<SongRepository>().addSongFromCloud(appState.cloudState.currentCloudSong!.asSong());
    final newState = appState;
    newState.localState.allArtists = await GetIt.I<SongRepository>().getArtists();
    final count = await GetIt.I<SongRepository>().getCountByArtist(newState.localState.currentArtist);
    newState.localState.currentCount = count;
    newState.localState.currentSongs = await GetIt.I<SongRepository>()
        .getSongsByArtist(appState.localState.currentArtist);
    await changeState(newState);
    _showToast(newState, AppStrings.strToastDownloadSuccess);
  }

  void _likeCurrent(AppStateChanger changeState, AppState appState) {
    final cloudSong = appState.cloudState.currentCloudSong!;
    GetIt.I<CloudRepository>().vote(cloudSong, 1, (voteValue) async {
      final newState = appState;
      final oldCount = newState.cloudState.allLikes[cloudSong] ?? 0;
      newState.cloudState.allLikes[cloudSong] = oldCount + 1;
      await changeState(newState);
      _showToast(appState, AppStrings.strToastVoteSuccess);
    }, (message) {
      _showToast(appState, message);
    }, () {
      _showToast(appState, AppStrings.strToastInAppError);
    });
  }

  void _dislikeCurrent(AppStateChanger changeState, AppState appState) {
    final cloudSong = appState.cloudState.currentCloudSong!;
    GetIt.I<CloudRepository>().vote(cloudSong, -1, (voteValue) async {
      final newState = appState;
      final oldCount = newState.cloudState.allDislikes[cloudSong] ?? 0;
      newState.cloudState.allDislikes[cloudSong] = oldCount + 1;
      await changeState(newState);
      _showToast(appState, AppStrings.strToastVoteSuccess);
    }, (message) {
      _showToast(appState, message);
    }, () {
      _showToast(appState, AppStrings.strToastInAppError);
    });
  }

  Future<void> _updateCloudSongListNeedScroll(AppStateChanger changeState, AppState appState, bool needScroll) async {
    final newState = appState;
    newState.cloudState.needScroll = needScroll;
    await changeState(newState);
  }

  Future<void> _saveSettings(AppStateChanger changeState, AppState appState, AppSettings settings) async {
    final newThemeIndex = AppTheme.indexFromDescription(settings.theme.description);
    await ThemeVariant.saveThemeIndex(newThemeIndex);
    final newMusicPreferenceIndex = ListenToMusicVariant
        .indexFromDescription(settings.listenToMusicPreference.description);
    await ListenToMusicVariant.savePreferenceIndex(newMusicPreferenceIndex);
    final newFontScaleVariantIndex = FontScaleVariant
        .indexFromDescription(settings.fontScaleVariant.description);
    await FontScaleVariant.savePreferenceIndex(newFontScaleVariantIndex);

    await _reloadSettings(changeState, appState);
  }

  Future<void> _reloadSettings(AppStateChanger changeState, AppState appState) async {
    final themeIndex = await ThemeVariant.getCurrentThemeIndex();
    final theme = AppTheme.getByIndex(themeIndex);
    final listenToMusicPreference = await ListenToMusicVariant.getCurrentPreference();
    final fontScaleVariant = await FontScaleVariant.getCurrentPreference();
    final newState = appState;
    newState.settings.theme = theme;
    newState.settings.fontScaleVariant = fontScaleVariant;
    newState.settings.textStyler = AppTextStyler(theme, fontScaleVariant.fontScale);
    newState.settings.listenToMusicPreference = listenToMusicPreference;
    await changeState(newState);
  }

  Future<void> _openSettings(AppStateChanger changeState, AppState appState) async {
    final newAppState = appState;
    _selectPageVariant(newAppState, PageVariant.settings);
    await changeState(newAppState);
  }
}