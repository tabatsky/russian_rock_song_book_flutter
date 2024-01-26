import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

import 'cloud_song.dart';

part 'cloud_repository.g.dart';

class CloudRepository {
  static final CloudRepository _instance = CloudRepository._privateConstructor();

  Dio? dio;
  RestClient? client;

  factory CloudRepository() {
    return _instance;
  }

  CloudRepository._privateConstructor() {
    dio = Dio();
    client = RestClient(dio!);
  }

  Future<List<CloudSong>> cloudSearch(String searchFor, String orderBy) async {
    final patchedSearchFor = searchFor.isEmpty ? 'empty_search_query' : searchFor;
    final searchResult = await client?.searchSongs(patchedSearchFor, orderBy);
    if (searchResult?.status != 'success') {
      return throw "fetch data error: ${searchResult?.message}";
    } else {
      return searchResult
          ?.data
          ?.map((e) => e.toCloudSong())
          .toList() ?? [];
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
