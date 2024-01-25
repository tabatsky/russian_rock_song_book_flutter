import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'cloud_repository.g.dart';

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

  String description() => "$artist; $title; $variant";
}
