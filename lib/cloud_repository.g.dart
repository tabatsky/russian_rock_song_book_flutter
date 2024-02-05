// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultWithCloudSongApiModelListData
    _$ResultWithCloudSongApiModelListDataFromJson(Map<String, dynamic> json) =>
        ResultWithCloudSongApiModelListData(
          json['status'] as String,
          json['message'] as String?,
          (json['data'] as List<dynamic>?)
              ?.map(
                  (e) => CloudSongApiModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$ResultWithCloudSongApiModelListDataToJson(
        ResultWithCloudSongApiModelListData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

CloudSongApiModel _$CloudSongApiModelFromJson(Map<String, dynamic> json) =>
    CloudSongApiModel(
      json['songId'] as int,
      json['googleAccount'] as String,
      json['deviceIdHash'] as String,
      json['artist'] as String,
      json['title'] as String,
      json['text'] as String,
      json['textHash'] as String,
      json['isUserSong'] as bool,
      json['variant'] as int,
      (json['raiting'] as num).toDouble(),
      json['likeCount'] as int,
      json['dislikeCount'] as int,
    );

Map<String, dynamic> _$CloudSongApiModelToJson(CloudSongApiModel instance) =>
    <String, dynamic>{
      'songId': instance.songId,
      'googleAccount': instance.googleAccount,
      'deviceIdHash': instance.deviceIdHash,
      'artist': instance.artist,
      'title': instance.title,
      'text': instance.text,
      'textHash': instance.textHash,
      'isUserSong': instance.isUserSong,
      'variant': instance.variant,
      'raiting': instance.raiting,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _RestClient implements RestClient {
  _RestClient(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://tabatsky.ru/SongBook2/api/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<ResultWithCloudSongApiModelListData> searchSongs(
    String searchFor,
    String orderBy,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ResultWithCloudSongApiModelListData>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'songs/search/${searchFor}/${orderBy}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ResultWithCloudSongApiModelListData.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}