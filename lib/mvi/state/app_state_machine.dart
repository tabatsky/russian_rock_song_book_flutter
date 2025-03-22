import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:russian_rock_song_book/data/cloud/cloud_search_pager/cloud_search_pager.dart';
import 'package:russian_rock_song_book/data/settings/font_scale_variant.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/data/settings/theme_variant.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/domain/repository/cloud/cloud_repository.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/mvi/state/page_variant.dart';
import 'package:russian_rock_song_book/ui/font/app_font.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

typedef AppStateChanger = Future<void> Function(AppState newState);
typedef NavigatorStateGetter = NavigatorState? Function();
typedef EventSender = void Function(AppUIEvent event);

class AppStateMachine {
  final NavigatorStateGetter getNavigatorState;
  final EventSender sendEvent;

  AppStateMachine(this.getNavigatorState, this.sendEvent);

  Future<bool> performAction(
      AppStateChanger changeState, AppState appState, AppUIEvent event) async {
    final newState = appState.copy();
    if (event is ShowSongList) {
      await _showSongList(changeState, newState);
    } else if (event is ArtistClick) {
      await _selectArtist(changeState, newState, event.artist);
    } else if (event is SongClick) {
      await _selectSong(changeState, newState, event.position);
    } else if (event is PrevSong) {
      await _prevSong(changeState, newState);
    } else if (event is NextSong) {
      await _nextSong(changeState, newState);
    } else if (event is Back) {
      await _back(changeState, newState, systemBack: event.systemBack);
    } else if (event is ToggleFavorite) {
      await _toggleFavorite(changeState, newState);
    } else if (event is UpdateEditorMode) {
      await _updateEditorMode(changeState, appState, event.isEditorMode);
    } else if (event is UpdateAutoPlayMode) {
      await _updateAutoPlayMode(changeState, appState, event.isAutoPlayMode);
    } else if (event is SaveSongText) {
      await _saveSongText(changeState, newState, event.updatedText);
    } else if (event is UpdateMenuExpandedArtistGroup) {
      await _updateMenuExpandedArtistGroup(
          changeState, appState, event.artistGroup);
    } else if (event is UploadCurrentToCloud) {
      _uploadCurrentToCloud(newState);
    } else if (event is DeleteCurrentToTrash) {
      await _deleteCurrentToTrash(changeState, newState);
    } else if (event is OpenVkMusic) {
      _openVkMusic(newState, event.searchFor);
    } else if (event is OpenYandexMusic) {
      _openYandexMusic(newState, event.searchFor);
    } else if (event is OpenYoutubeMusic) {
      _openYoutubeMusic(newState, event.searchFor);
    } else if (event is SendWarning) {
      await _sendWarning(newState, event.warning);
    } else if (event is CloudSearch) {
      await _performCloudSearch(
          changeState, newState, event.searchFor, event.orderBy);
    } else if (event is NewCloudPageLoaded) {
      await _newCloudPageLoaded(changeState, newState, event.searchState,
          event.count, event.lastPage);
    } else if (event is BackupSearchState) {
      await _backupSearchState(
          changeState, newState, event.searchFor, event.orderBy);
    } else if (event is CloudSongClick) {
      await _selectCloudSong(changeState, newState, event.position);
    } else if (event is PrevCloudSong) {
      await _prevCloudSong(changeState, newState);
    } else if (event is NextCLoudSong) {
      await _nextCloudSong(changeState, newState);
    } else if (event is DownloadCurrent) {
      await _downloadCurrent(changeState, newState);
    } else if (event is LikeCurrent) {
      _likeCurrent(changeState, newState);
    } else if (event is DislikeCurrent) {
      _dislikeCurrent(changeState, newState);
    } else if (event is LikeSuccess) {
      _likeSuccess(changeState, newState, event.cloudSong);
    } else if (event is DislikeSuccess) {
      _dislikeSuccess(changeState, newState, event.cloudSong);
    } else if (event is UpdateCloudSongListNeedScroll) {
      await _updateCloudSongListNeedScroll(
          changeState, newState, event.needScroll);
    } else if (event is OpenSettings) {
      await _openSettings(changeState, newState);
    } else if (event is SaveSettings) {
      await _saveSettings(changeState, newState, event.settings);
    } else if (event is ReloadSettings) {
      await _reloadSettings(changeState, newState);
    } else if (event is AddArtistList) {
      await _addArtistList(changeState, appState);
    } else if (event is AddNewSong) {
      await _addNewSong(changeState, appState, event.song);
    } else if (event is ShowToast) {
      _showToast(newState, event.text);
    } else {
      return false;
    }
    return true;
  }

  void _selectPageVariant(AppState appState, PageVariant newPageVariant,
      {bool systemBack = false}) {
    final oldPageVariant = appState.currentPageVariant;
    log(oldPageVariant.toString());
    log(newPageVariant.toString());

    if (oldPageVariant == PageVariant.start &&
        newPageVariant == PageVariant.songList) {
      getNavigatorState()?.pop();
      getNavigatorState()?.pushNamed(PageVariant.songList.route);
      appState.currentPageVariant = newPageVariant;
    } else if (oldPageVariant == PageVariant.songList &&
        newPageVariant == PageVariant.songText) {
      getNavigatorState()?.pushNamed(PageVariant.songText.route);
      appState.currentPageVariant = newPageVariant;
    } else if (oldPageVariant == PageVariant.songText &&
        newPageVariant == PageVariant.songList) {
      if (!systemBack) {
        getNavigatorState()?.pop();
      } else {
        appState.currentPageVariant = newPageVariant;
      }
    } else if (oldPageVariant == PageVariant.songList &&
        newPageVariant == PageVariant.cloudSearch) {
      getNavigatorState()?.pushNamed(PageVariant.cloudSearch.route);
      appState.currentPageVariant = newPageVariant;
    } else if (oldPageVariant == PageVariant.cloudSearch &&
        newPageVariant == PageVariant.songList) {
      if (!systemBack) {
        getNavigatorState()?.pop();
      } else {
        appState.currentPageVariant = newPageVariant;
      }
    } else if (oldPageVariant == PageVariant.cloudSearch &&
        newPageVariant == PageVariant.cloudSongText) {
      getNavigatorState()?.pushNamed(PageVariant.cloudSongText.route);
      appState.currentPageVariant = newPageVariant;
    } else if (oldPageVariant == PageVariant.cloudSongText &&
        newPageVariant == PageVariant.cloudSearch) {
      if (!systemBack) {
        getNavigatorState()?.pop();
      } else {
        appState.currentPageVariant = newPageVariant;
      }
    } else if (oldPageVariant == PageVariant.songList &&
        newPageVariant == PageVariant.settings) {
      getNavigatorState()?.pushNamed(PageVariant.settings.route);
      appState.currentPageVariant = newPageVariant;
    } else if (oldPageVariant == PageVariant.settings &&
        newPageVariant == PageVariant.songList) {
      if (!systemBack) {
        getNavigatorState()?.pop();
      } else {
        appState.currentPageVariant = newPageVariant;
      }
    } else if (oldPageVariant == PageVariant.songList &&
        newPageVariant == PageVariant.addArtist) {
      getNavigatorState()?.pushNamed(PageVariant.addArtist.route);
      appState.currentPageVariant = newPageVariant;
    } else if (oldPageVariant == PageVariant.addArtist &&
        newPageVariant == PageVariant.songList) {
      if (!systemBack) {
        getNavigatorState()?.pop();
      } else {
        appState.currentPageVariant = newPageVariant;
      }
    } else if (oldPageVariant == PageVariant.songList &&
        newPageVariant == PageVariant.addSong) {
      getNavigatorState()?.pushNamed(PageVariant.addSong.route);
      appState.currentPageVariant = newPageVariant;
     } else if (oldPageVariant == PageVariant.addSong &&
        newPageVariant == PageVariant.songList) {
      if (!systemBack) {
        getNavigatorState()?.pop();
      } else {
        appState.currentPageVariant = newPageVariant;
      }
    }
  }

  Future<void> _showSongList(
      AppStateChanger changeState, AppState appState) async {
    await _initSongs(changeState, appState);
    final newAppState = appState;
    _selectPageVariant(newAppState, PageVariant.songList);
    await changeState(newAppState);
  }

  Future<void> _initSongs(
      AppStateChanger changeState, AppState appState) async {
    await _initAllArtists(changeState, appState);
    await _selectArtist(changeState, appState, 'Кино');
  }

  Future<void> _initAllArtists(
      AppStateChanger changeState, AppState appState) async {
    final artists = await GetIt.I<SongRepository>().getArtists();
    log(artists.toString());
    final newAppState = appState;
    final newLocalState = appState.localState;
    newLocalState.allArtists = artists;
    newAppState.localState = newLocalState;
    await changeState(newAppState);
  }

  Future<void> _selectArtist(
      AppStateChanger changeState, AppState appState, String artist) async {
    log("select artist: $artist");
    if (artist == SongRepository.artistCloudSearch) {
      _backupSearchState(changeState, appState, '', OrderBy.byIdDesc);
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.cloudSearch);
      await changeState(newAppState);
      _performCloudSearch(changeState, appState, '', OrderBy.byIdDesc);
    } else if (artist == SongRepository.artistAddArtist) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.addArtist);
      await changeState(newAppState);
    } else if (artist == SongRepository.artistAddSong) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.addSong);
      await changeState(newAppState);
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

  Future<void> _selectSong(
      AppStateChanger changeState, AppState appState, int position) async {
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
      newLocalState.currentSong =
          newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      await changeState(newAppState);
    }
  }

  Future<void> _nextSong(AppStateChanger changeState, AppState appState) async {
    if (appState.localState.currentSongPosition <
        appState.localState.currentSongs.length - 1) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSongPosition += 1;
      newLocalState.scrollPosition = newLocalState.currentSongPosition;
      newLocalState.currentSong =
          newLocalState.currentSongs[newLocalState.currentSongPosition];
      newAppState.localState = newLocalState;
      await changeState(newAppState);
    }
  }

  Future<void> _back(AppStateChanger changeState, AppState appState,
      {bool systemBack = false}) async {
    log("back, system: $systemBack");
    if (appState.currentPageVariant == PageVariant.songText) {
      final newAppState = appState;
      final newLocalState = appState.localState;
      newLocalState.currentSong = null;
      newLocalState.currentSongPosition = -1;
      newAppState.localState = newLocalState;
      _selectPageVariant(newAppState, PageVariant.songList,
          systemBack: systemBack);
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSearch) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList,
          systemBack: systemBack);
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.cloudSongText) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSong = null;
      newCloudState.currentCloudSongPosition = -1;
      newCloudState.needScroll = true;
      newAppState.cloudState = newCloudState;
      _selectPageVariant(newAppState, PageVariant.cloudSearch,
          systemBack: systemBack);
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.settings) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList,
          systemBack: systemBack);
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.addArtist) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList,
          systemBack: systemBack);
      await changeState(newAppState);
    } else if (appState.currentPageVariant == PageVariant.addSong) {
      final newAppState = appState;
      _selectPageVariant(newAppState, PageVariant.songList,
          systemBack: systemBack);
      await changeState(newAppState);
    }
  }

  Future<void> _toggleFavorite(
      AppStateChanger changeState, AppState appState) async {
    final newAppState = appState;
    final newLocalState = appState.localState;

    var needSendBack = false;

    if (newLocalState.currentSong != null) {
      final song = newLocalState.currentSong!;
      final becomeFavorite = !song.favorite;
      song.favorite = becomeFavorite;
      await GetIt.I<SongRepository>().updateSong(song);

      if (!becomeFavorite &&
          newLocalState.currentArtist == SongRepository.artistFavorite) {
        final count = await GetIt.I<SongRepository>()
            .getCountByArtist(SongRepository.artistFavorite);
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
          needSendBack = true;
        }
      }

      await _refreshCurrentSong(changeState, newAppState);

      if (becomeFavorite) {
        _showToast(newAppState, AppStrings.strToastAddedToFavorite);
      } else {
        _showToast(newAppState, AppStrings.strToastDeletedFromFavorite);
      }

      if (needSendBack) {
        sendEvent(Back());
      }
    }
  }

  Future<void> _updateEditorMode(
      AppStateChanger changeState, AppState appState, bool isEditorMode) async {
    final newState = appState.copy();
    newState.localState.isEditorMode = isEditorMode;
    await changeState(newState);
  }

  Future<void> _updateAutoPlayMode(AppStateChanger changeState,
      AppState appState, bool isAutoPlayMode) async {
    final newState = appState.copy();
    newState.localState.isAutoPlayMode = isAutoPlayMode;
    await changeState(newState);
  }

  Future<void> _saveSongText(AppStateChanger changeState, AppState appState,
      String updatedText) async {
    if (appState.localState.currentSong != null) {
      final song = appState.localState.currentSong!;
      song.text = updatedText;
      await GetIt.I<SongRepository>().updateSong(song);
      await _refreshCurrentSong(changeState, appState);
    }
  }

  Future<void> _refreshCurrentSong(
      AppStateChanger changeState, AppState appState) async {
    log('refresh current song');
    final songs = await GetIt.I<SongRepository>()
        .getSongsByArtist(appState.localState.currentArtist);
    final newAppState = appState.copy();
    final newLocalState = appState.localState;
    newLocalState.currentSong = newLocalState.currentSongPosition >= 0
        ? songs.elementAtOrNull(newLocalState.currentSongPosition)
        : null;
    log(newLocalState.currentSong.toString());
    newLocalState.currentSongs = songs;
    newAppState.localState = newLocalState;
    await changeState(newAppState);
  }

  Future<void> _updateMenuExpandedArtistGroup(AppStateChanger changeState,
      AppState appState, String artistGroup) async {
    final newState = appState.copy();
    newState.localState.menuExpandedArtistGroup = artistGroup;
    await changeState(newState);
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

  Future<void> _deleteCurrentToTrash(
      AppStateChanger changeState, AppState appState) async {
    final newState = appState;
    final song = newState.localState.currentSong!;
    song.deleted = true;
    await GetIt.I<SongRepository>().updateSong(song);
    final count = await GetIt.I<SongRepository>()
        .getCountByArtist(newState.localState.currentArtist);
    newState.localState.currentCount = count;
    newState.localState.allArtists =
        await GetIt.I<SongRepository>().getArtists();
    var needSendBack = false;
    if (newState.localState.currentCount > 0) {
      if (newState.localState.currentSongPosition >=
          newState.localState.currentCount) {
        newState.localState.currentSongPosition -= 1;
      }
      _refreshCurrentSong(changeState, newState);
    } else {
      needSendBack = true;
    }
    newState.localState.currentSongs = await GetIt.I<SongRepository>()
        .getSongsByArtist(appState.localState.currentArtist);
    await changeState(newState);
    _showToast(newState, AppStrings.strToastDeleted);

    if (needSendBack) {
      sendEvent(Back());
    }
  }

  void _showToast(AppState appState, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: appState.settings.theme.colorMain,
        textColor: appState.settings.theme.colorBg,
        fontSize: 16.0);
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

  Future<void> _performCloudSearch(AppStateChanger changeState,
      AppState appState, String searchFor, OrderBy orderBy) async {
    _resetCloudSearch(changeState, appState);
    await changeState(appState);
    appState.cloudState.currentSearchPager = CloudSearchPager(
        searchFor, orderBy, (searchState, count, lastPage) async {
      sendEvent(NewCloudPageLoaded(searchState, count, lastPage));
    });
  }

  Future<void> _newCloudPageLoaded(
      AppStateChanger changeState,
      AppState appState,
      SearchState searchState,
      int count,
      int? lastPage) async {
    appState.cloudState.currentSearchState = searchState;
    appState.cloudState.currentCloudSongCount = count;
    appState.cloudState.lastPage = lastPage;
    log("$searchState $count $lastPage");
    await changeState(appState);
  }

  Future<void> _resetCloudSearch(
      AppStateChanger changeState, AppState appState) async {
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

  Future<void> _backupSearchState(AppStateChanger changeState,
      AppState appState, String searchFor, OrderBy orderBy) async {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.searchForBackup = searchFor;
    newCloudState.orderByBackup = orderBy;
    newAppState.cloudState = newCloudState;
    await changeState(newAppState);
  }

  Future<void> _selectCloudSong(
      AppStateChanger changeState, AppState appState, int position) async {
    final newAppState = appState;
    final newCloudState = appState.cloudState;
    newCloudState.currentCloudSongPosition = position;
    newCloudState.cloudScrollPosition = position;
    newCloudState.currentCloudSong =
        await newCloudState.currentSearchPager?.getCloudSong(position);
    newAppState.cloudState = newCloudState;
    _selectPageVariant(newAppState, PageVariant.cloudSongText);
    await changeState(newAppState);
  }

  Future<void> _prevCloudSong(
      AppStateChanger changeState, AppState appState) async {
    if (appState.cloudState.currentCloudSongPosition > 0) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition -= 1;
      newCloudState.cloudScrollPosition =
          newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = await newCloudState.currentSearchPager
          ?.getCloudSong(newCloudState.currentCloudSongPosition);
      await changeState(newAppState);
    }
  }

  Future<void> _nextCloudSong(
      AppStateChanger changeState, AppState appState) async {
    if (appState.cloudState.currentCloudSongPosition <
        appState.cloudState.currentCloudSongCount - 1) {
      final newAppState = appState;
      final newCloudState = appState.cloudState;
      newCloudState.currentCloudSongPosition += 1;
      newCloudState.cloudScrollPosition =
          newCloudState.currentCloudSongPosition;
      newCloudState.currentCloudSong = await newCloudState.currentSearchPager
          ?.getCloudSong(newCloudState.currentCloudSongPosition);
      await changeState(newAppState);
    }
  }

  Future<void> _downloadCurrent(
      AppStateChanger changeState, AppState appState) async {
    await GetIt.I<SongRepository>()
        .addSongFromCloud(appState.cloudState.currentCloudSong!.asSong());
    final newState = appState;
    newState.localState.allArtists =
        await GetIt.I<SongRepository>().getArtists();
    final count = await GetIt.I<SongRepository>()
        .getCountByArtist(newState.localState.currentArtist);
    newState.localState.currentCount = count;
    newState.localState.currentSongs = await GetIt.I<SongRepository>()
        .getSongsByArtist(appState.localState.currentArtist);
    await changeState(newState);
    _showToast(newState, AppStrings.strToastDownloadSuccess);
  }

  void _likeCurrent(AppStateChanger changeState, AppState appState) {
    final cloudSong = appState.cloudState.currentCloudSong!;
    GetIt.I<CloudRepository>().vote(cloudSong, 1, (voteValue) async {
      log('vote: $voteValue');
      sendEvent(LikeSuccess(cloudSong));
    }, (message) {
      _showToast(appState, message);
    }, () {
      _showToast(appState, AppStrings.strToastInAppError);
    });
  }

  void _dislikeCurrent(AppStateChanger changeState, AppState appState) {
    final cloudSong = appState.cloudState.currentCloudSong!;
    GetIt.I<CloudRepository>().vote(cloudSong, -1, (voteValue) async {
      log('vote: $voteValue');
      sendEvent(DislikeSuccess(cloudSong));
    }, (message) {
      _showToast(appState, message);
    }, () {
      _showToast(appState, AppStrings.strToastInAppError);
    });
  }

  Future<void> _likeSuccess(AppStateChanger changeState, AppState appState,
      CloudSong cloudSong) async {
    final newState = appState;
    final oldCount = newState.cloudState.allLikes[cloudSong] ?? 0;
    newState.cloudState.allLikes[cloudSong] = oldCount + 1;
    await changeState(newState);
    _showToast(appState, AppStrings.strToastVoteSuccess);
  }

  Future<void> _dislikeSuccess(AppStateChanger changeState, AppState appState,
      CloudSong cloudSong) async {
    final newState = appState;
    final oldCount = newState.cloudState.allDislikes[cloudSong] ?? 0;
    newState.cloudState.allDislikes[cloudSong] = oldCount + 1;
    await changeState(newState);
    _showToast(appState, AppStrings.strToastVoteSuccess);
  }

  Future<void> _updateCloudSongListNeedScroll(
      AppStateChanger changeState, AppState appState, bool needScroll) async {
    final newState = appState;
    newState.cloudState.needScroll = needScroll;
    await changeState(newState);
  }

  Future<void> _saveSettings(AppStateChanger changeState, AppState appState,
      AppSettings settings) async {
    final newThemeIndex =
        AppTheme.indexFromDescription(settings.theme.description);
    await ThemeVariant.saveThemeIndex(newThemeIndex);
    final newMusicPreferenceIndex = ListenToMusicVariant.indexFromDescription(
        settings.listenToMusicPreference.description);
    await ListenToMusicVariant.savePreferenceIndex(newMusicPreferenceIndex);
    final newFontScaleVariantIndex = FontScaleVariant.indexFromDescription(
        settings.fontScaleVariant.description);
    await FontScaleVariant.savePreferenceIndex(newFontScaleVariantIndex);

    await _reloadSettings(changeState, appState);
  }

  Future<void> _reloadSettings(
      AppStateChanger changeState, AppState appState) async {
    final themeIndex = await ThemeVariant.getCurrentThemeIndex();
    final theme = AppTheme.getByIndex(themeIndex);
    final listenToMusicPreference =
        await ListenToMusicVariant.getCurrentPreference();
    final fontScaleVariant = await FontScaleVariant.getCurrentPreference();
    final newState = appState;
    newState.settings.theme = theme;
    newState.settings.fontScaleVariant = fontScaleVariant;
    newState.settings.textStyler =
        AppTextStyler(theme, fontScaleVariant.fontScale);
    newState.settings.listenToMusicPreference = listenToMusicPreference;
    await changeState(newState);
  }

  Future<void> _openSettings(
      AppStateChanger changeState, AppState appState) async {
    final newAppState = appState;
    _selectPageVariant(newAppState, PageVariant.settings);
    await changeState(newAppState);
  }

  Future<void> _addArtistList(
      AppStateChanger changeState, AppState appState) async {
    const platform =
        MethodChannel('jatx.flutter.russian_rock_song_book/channel');
    try {
      final result =
          await platform.invokeMethod<List<Object?>>('getFolderContents') ?? [];
      final strings = result.map((e) => e as String).toList();
      if (strings.length < 3) {
        _showToast(appState, AppStrings.strToastSongsNotFound);
        return;
      }
      final artist = strings[0];
      final songList = List<Song>.empty(growable: true);
      for (var i = 0; 2 * i < strings.length - 1; i++) {
        final title = strings[2 * i + 1];
        final text = strings[2 * i + 2];
        final song = Song(artist: artist, title: title, text: text);
        songList.add(song);
      }
      await GetIt.I<SongRepository>().insertReplaceSongs(songList);
      final newAppState = appState;
      newAppState.localState.allArtists =
          await GetIt.I<SongRepository>().getArtists();
      await _selectArtist((newState) async {
        final newAppState = newState;
        _selectPageVariant(newAppState, PageVariant.songList);
        changeState(newAppState);
      }, newAppState, artist);
    } catch (e) {
      log('add artist error: $e');
      _showToast(appState, AppStrings.strToastError);
    }
  }

  Future<void> _addNewSong(
      AppStateChanger changeState, AppState appState, Song song) async {
    try {
      final songList = [song];
      await GetIt.I<SongRepository>().insertReplaceSongs(songList);
      final newAppState = appState;
      newAppState.localState.allArtists =
      await GetIt.I<SongRepository>().getArtists();
      getNavigatorState()?.pop();
      await _back((newState) async {
        await changeState(newState);
        await _selectArtist((newState2) async {
          final newAppState2 = newState2;
          _selectPageVariant(newAppState2, PageVariant.songList);
          await changeState(newAppState2);
          final songsByArtist = await GetIt.I<SongRepository>().getSongsByArtist(song.artist);
          final position = songsByArtist.indexWhere((test) => test.title == song.title);
          await _selectSong(changeState, newAppState2, position);
        }, newState, song.artist);
      }, newAppState, systemBack: true);
    } catch (e) {
      log('add new song error: $e');
      _showToast(appState, AppStrings.strToastError);
    }
  }
}
