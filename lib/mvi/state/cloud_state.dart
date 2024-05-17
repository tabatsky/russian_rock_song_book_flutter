import 'dart:collection';

import 'package:russian_rock_song_book/data/cloud/cloud_search_pager/cloud_search_pager.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';

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

  CloudState();

  CloudState._newInstance(
      this.currentSearchPager,
      this.currentSearchState,
      this.currentCloudSongCount,
      this.lastPage,
      this.currentCloudSong,
      this.currentCloudSongPosition,
      this.cloudScrollPosition,
      this.needScroll,
      this.searchForBackup,
      this.orderByBackup,
      this.allLikes,
      this.allDislikes
      );

  CloudState copy() => CloudState._newInstance(
      currentSearchPager,
      currentSearchState,
      currentCloudSongCount,
      lastPage,
      currentCloudSong,
      currentCloudSongPosition,
      cloudScrollPosition,
      needScroll,
      searchForBackup,
      orderByBackup,
      allLikes,
      allDislikes
  );
}