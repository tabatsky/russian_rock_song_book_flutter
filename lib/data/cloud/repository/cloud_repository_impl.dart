import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';
import 'package:russian_rock_song_book/domain/repository/cloud/cloud_repository.dart';

part 'cloud_repository_impl.g.dart';

class CloudRepositoryImpl implements CloudRepository {

  Dio? dio;
  RestClient? client;

  CloudRepositoryImpl() {
    dio = Dio();
    client = RestClient(dio!);
  }

  @override
  Future<List<CloudSong>> cloudSearch(String searchFor, String orderBy) async {
    final patchedSearchFor = searchFor.isEmpty ? 'empty_search_query' : searchFor;
    final searchResult = await client?.searchSongs(patchedSearchFor, orderBy);
    if (searchResult?.status != 'success') {
      throw "fetch data error: ${searchResult?.message}";
    } else {
      return searchResult
          ?.data
          ?.map((e) => e.toCloudSong())
          .toList() ?? [];
    }
  }

  @override
  Future<List<CloudSong>> pagedSearch(String searchFor, String orderBy, int page) async {
    final patchedSearchFor = searchFor.isEmpty ? 'empty_search_query' : searchFor;
    log("$patchedSearchFor $orderBy $page");
    final searchResult = await client?.pagedSearch(patchedSearchFor, orderBy, page);
    if (searchResult?.status != 'success') {
      throw "fetch data error: ${searchResult?.message}";
    } else {
      return searchResult
          ?.data
          ?.map((e) => e.toCloudSong())
          .toList() ?? [];
    }
  }

  @override
  Future<void> addWarning(Warning warning, Success success, ServerError serverError, InAppError inAppError) async {
    try {
      final warningApiModel = WarningApiModel.fromWarning(warning);
      final warningJSON = jsonEncode(warningApiModel.toJson());
      log(warningJSON);
      final result = await client?.addWarning(warningJSON);
      if (result?.status == 'success') {
        success();
      } else {
        serverError(result?.message ?? 'null');
      }
    } catch (e) {
      inAppError();
    }
  }

  @override
  Future<void> addCloudSong(CloudSong cloudSong, Success success, ServerError serverError, InAppError inAppError) async {
    try {
      final cloudSongApiModel = CloudSongApiModel.fromCloudSong(cloudSong);
      final cloudSongJSON = jsonEncode(cloudSongApiModel.toJson());
      final result = await client?.addSong(cloudSongJSON);
      if (result?.status == 'success') {
        success();
      } else {
        serverError(result?.message ?? 'null');
      }
    } catch (e) {
      print(e);
      inAppError();
    }
  }

  @override
  Future<void> vote(CloudSong cloudSong, int voteValue, VoteSuccess voteSuccess, ServerError serverError, InAppError inAppError) async {
    try {
      final result = await client?.vote(
          'Flutter_debug',
          'Flutter_debug',
          cloudSong.artist,
          cloudSong.title,
          cloudSong.variant,
          voteValue);
      if (result?.status == 'success') {
        final voteValue = result?.data?.toInt() ?? 0;
        voteSuccess(voteValue);
      } else {
        serverError(result?.message ?? 'null');
      }
    } catch (e) {
      inAppError();
    }
  }
}

@RestApi(baseUrl: 'http://tabatsky.ru/SongBook2/api/')
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET('songs/search/{searchFor}/{orderBy}')
  Future<ResultWithCloudSongApiModelListData> searchSongs(
      @Path('searchFor') String searchFor,
      @Path('orderBy') String orderBy);

  @GET('songs/pagedSearchWithLikes/{searchFor}/{orderBy}/{page}')
  Future<ResultWithCloudSongApiModelListData> pagedSearch(
      @Path('searchFor') String searchFor,
      @Path('orderBy') String orderBy,
      @Path('page') int page);

  @POST("warnings/add")
  @FormUrlEncoded()
  Future<ResultWithoutData> addWarning(@Field('warningJSON') String warningJSON);

  @POST("songs/add")
  @FormUrlEncoded()
  Future<ResultWithoutData> addSong(@Field('cloudSongJSON') String cloudSongJSON);

  @GET("songs/vote/{googleAccount}/{deviceIdHash}/{artist}/{title}/{variant}/{voteValue}")
  Future<ResultWithNumber> vote(
      @Path("googleAccount") String googleAccount,
      @Path("deviceIdHash") String deviceIdHash,
      @Path("artist") String artist,
      @Path("title") String title,
      @Path("variant") int variant,
      @Path("voteValue") int voteValue);
}

@JsonSerializable()
class ResultWithCloudSongApiModelListData {
  final String status;
  final String? message;
  final List<CloudSongApiModel>? data;

  const ResultWithCloudSongApiModelListData(this.status, this.message, this.data);

  factory ResultWithCloudSongApiModelListData.fromJson(Map<String, dynamic> json) => _$ResultWithCloudSongApiModelListDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResultWithCloudSongApiModelListDataToJson(this);
}

@JsonSerializable()
class ResultWithNumber {
  final String status;
  final String? message;
  final double? data;

  const ResultWithNumber(this.status, this.message, this.data);

  factory ResultWithNumber.fromJson(Map<String, dynamic> json) => _$ResultWithNumberFromJson(json);

  Map<String, dynamic> toJson() => _$ResultWithNumberToJson(this);
}

@JsonSerializable()
class ResultWithoutData {
  final String status;
  final String? message;

  const ResultWithoutData(this.status, this.message);

  factory ResultWithoutData.fromJson(Map<String, dynamic> json) => _$ResultWithoutDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResultWithoutDataToJson(this);
}

@JsonSerializable()
class CloudSongApiModel {
  final int songId;
  final String googleAccount;
  final String deviceIdHash;
  final String artist;
  final String title;
  final String text;
  final String textHash;
  final bool isUserSong;
  final int variant;
  final double raiting;
  final int likeCount;
  final int dislikeCount;

  const CloudSongApiModel(
      this.songId, this.googleAccount, this.deviceIdHash,
      this.artist, this.title, this.text, this.textHash,
      this.isUserSong, this.variant, this.raiting,
      this.likeCount, this.dislikeCount);

  factory CloudSongApiModel.fromJson(Map<String, dynamic> json) => _$CloudSongApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CloudSongApiModelToJson(this);

  factory CloudSongApiModel.fromCloudSong(CloudSong cloudSong) => CloudSongApiModel(
      cloudSong.songId,
      cloudSong.googleAccount,
      cloudSong.deviceIdHash,
      cloudSong.artist,
      cloudSong.title,
      cloudSong.text,
      cloudSong.textHash,
      cloudSong.isUserSong,
      cloudSong.variant,
      cloudSong.raiting,
      cloudSong.likeCount,
      cloudSong.dislikeCount
  );

  CloudSong toCloudSong() => CloudSong(
      songId,
      googleAccount,
      deviceIdHash,
      artist,
      title,
      text,
      textHash,
      isUserSong,
      variant,
      raiting,
      likeCount,
      dislikeCount
  );
}

@JsonSerializable()
class WarningApiModel {
  String warningType;
  String artist;
  String title;
  int variant;
  String comment;

  WarningApiModel(this.warningType, this.artist, this.title, this.variant,
      this.comment);

  static WarningApiModel fromWarning(Warning warning) =>
      WarningApiModel(
          warning.warningType,
          warning.artist,
          warning.title,
          warning.variant,
          warning.comment);

  Map<String, dynamic> toJson() => _$WarningApiModelToJson(this);
}