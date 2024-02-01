import 'package:russian_rock_song_book/song.dart';

import 'app_theme.dart';
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