import 'package:get_it/get_it.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/domain/repository/cloud/cloud_repository.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';

const PAGE_SIZE = 15;

class CloudRepositoryTestImpl implements CloudRepository {

  List<CloudSong> list = [];

  Future<void> _init() async {
    final songRepo = GetIt.I<SongRepository>();
    final list1 = await songRepo.getSongsByArtist('Немного Нервно');
    final list2 = await songRepo.getSongsByArtist('Александр Башлачёв');
    final list3 = await songRepo.getSongsByArtist('Сплин');
    list = (list1 + list2 + list3)
        .reversed
        .map((song) => CloudSong.fromSong(song))
        .toList();
  }

  String orderByFun(CloudSong cloudSong, String orderBy) {
    if (orderBy == OrderBy.byArtist.orderByStr) {
      return cloudSong.artist + cloudSong.title;
    } else if (orderBy == OrderBy.byTitle.orderByStr) {
      return cloudSong.title + cloudSong.artist;
    } else {
      final index = list.length - list.indexOf(cloudSong);
      return index.toString().padLeft(5, '0');
    }
  }

  Future<List<CloudSong>> search(String searchFor, String orderBy) async {
    if (list.isEmpty) await _init();
    final result = list
        .where((test) =>
          test.artist.toLowerCase().contains(searchFor.toLowerCase()) ||
          test.title.toLowerCase().contains(searchFor.toLowerCase())
        )
        .toList();
    result.sort((a, b) => orderByFun(a, orderBy).compareTo(orderByFun(b, orderBy)));
    return result;
  }


  @override
  Future<void> addCloudSong(CloudSong cloudSong, Success success, ServerError serverError, InAppError inAppError) {
    // TODO: implement addCloudSong
    throw UnimplementedError();
  }

  @override
  Future<void> addWarning(Warning warning, Success success, ServerError serverError, InAppError inAppError) {
    // TODO: implement addWarning
    throw UnimplementedError();
  }

  @override
  Future<List<CloudSong>> cloudSearch(String searchFor, String orderBy) {
    // TODO: implement cloudSearch
    throw UnimplementedError();
  }

  @override
  Future<List<CloudSong>> pagedSearch(String searchFor, String orderBy, int page) async {
    final searchResult = await search(searchFor, orderBy);
    return safeSublist(searchResult, (page - 1) * PAGE_SIZE, page * PAGE_SIZE);
  }

  @override
  Future<void> vote(CloudSong cloudSong, int voteValue, VoteSuccess voteSuccess, ServerError serverError, InAppError inAppError) {
    // TODO: implement vote
    throw UnimplementedError();
  }

}

List<CloudSong> safeSublist(List<CloudSong> list, int fromIndex, int toIndex) {
  if (fromIndex >= list.length) return [];
  if (toIndex >= list.length) return list.sublist(fromIndex, list.length - 1);
  return list.sublist(fromIndex, toIndex);
}
