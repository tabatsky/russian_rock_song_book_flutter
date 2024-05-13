import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';

typedef Success = void Function();
typedef VoteSuccess = void Function(int voteValue);
typedef ServerError = void Function(String message);
typedef InAppError = void Function();

abstract class CloudRepository {
  Future<List<CloudSong>> cloudSearch(String searchFor, String orderBy);
  Future<List<CloudSong>> pagedSearch(String searchFor, String orderBy, int page);
  Future<void> addWarning(Warning warning, Success success, ServerError serverError, InAppError inAppError);
  Future<void> addCloudSong(CloudSong cloudSong, Success success, ServerError serverError, InAppError inAppError);
  Future<void> vote(CloudSong cloudSong, int voteValue, VoteSuccess voteSuccess, ServerError serverError, InAppError inAppError);

}