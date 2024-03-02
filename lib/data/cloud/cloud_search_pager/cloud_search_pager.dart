import 'dart:collection';
import 'dart:developer';

import 'package:russian_rock_song_book/data/cloud/repository/cloud_repository.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';

enum SearchState { empty, error, loading, loadingNextPage, idle, done }

extension IntPlus on int {
  int plus(int amount) => this + amount;
}

const pageSize = 15;

class CloudSearchPager {
  String searchFor;
  OrderBy orderBy;
  void Function(SearchState searchState, int count, int? lastPage) updateSearchPagerState;

  CloudSearchPager(this.searchFor, this.orderBy, this.updateSearchPagerState);

  final Map<int, List<CloudSong>> readyPages = HashMap();

  SearchState searchState = SearchState.loading;
  int count = 0;
  int? lastPage;

  final int _createTime = DateTime.now().millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CloudSearchPager && _createTime == other._createTime;

  @override
  int get hashCode => _createTime;

  Future<CloudSong?> getCloudSong(int index) async {
    final pageIndex = index ~/ pageSize;
    final listIndex = index % pageSize;
    final pageList = await getPage(pageIndex, true);
    return pageList?.elementAt(listIndex);
  }

  Future<List<CloudSong>?> getPage(int pageIndex, bool loadNext) async {
    log("get page $pageIndex");
    if (pageIndex == 0) {
      if (readyPages.containsKey(0)) {
        return readyPages[0];
      } else if (searchState == SearchState.empty) {
        return null;
      } else {
        final pageList = await _loadPage(0);
        await _loadPage(1);
        return pageList;
      }
    } else {
      final List<CloudSong>? pageList;
      if (readyPages.containsKey(pageIndex)) {
        pageList = readyPages[pageIndex];
      } else {
        pageList = (await _loadPage(pageIndex));
      }
      if (loadNext && !readyPages.containsKey(pageIndex + 1)) {
        _loadPage(pageIndex + 1);
      }
      return pageList;
    }
  }

  Future<List<CloudSong>?> _loadPage(int pageIndex) async {
    if (searchState == SearchState.done || searchState == SearchState.empty) {
      return null;
    }

    log("load page $pageIndex");

    if (pageIndex > 1) {
      searchState = SearchState.loadingNextPage;
    }

    try {
      final pageNumber = pageIndex + 1;
      final pageList = await CloudRepository().pagedSearch(
          searchFor, orderBy.orderByStr, pageNumber);
      log(pageList.toString());
      if (pageList.length < pageSize) {
        searchState = SearchState.done;
        if (pageList.isNotEmpty) {
          lastPage = pageIndex;
        } else {
          lastPage = pageIndex - 1;
        }
      } else if (searchState != SearchState.done) {
        searchState = SearchState.idle;
      }
      if (pageList.isNotEmpty) {
        if (!readyPages.containsKey(pageIndex)) {
          readyPages[pageIndex] = pageList;
        }
      }
      if (pageIndex == 0 && pageList.isEmpty) {
        searchState = SearchState.empty;
      }
      final newCount = pageIndex * pageSize + pageList.length;
      count = newCount > count ? newCount : count;
    } catch (e) {
      log(e.toString());
      searchState = SearchState.error;
    }

    updateSearchPagerState(searchState, count, lastPage);

    log(readyPages.keys.toString());

    return readyPages[pageIndex];
  }
}