import 'package:russian_rock_song_book/domain/models/local/song.dart';

class CloudSong {
  static const thumbUp = '\u{1F44D}';
  static const thumbDown = '\u{1F44E}';

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

  CloudSong(
      {required this.songId,
      required this.googleAccount,
      required this.deviceIdHash,
      required this.artist,
      required this.title,
      required this.text,
      required this.textHash,
      required this.isUserSong,
      required this.variant,
      required this.raiting,
      required this.likeCount,
      required this.dislikeCount});

  String description() => "$artist; $title; $variant";

  @override
  String toString() => description();

  String formattedRating(int extraLikes, int extraDislikes) {
    final actualLikeCount = likeCount + extraLikes;
    final actualDislikeCount = dislikeCount + extraDislikes;
    return "$thumbUp$actualLikeCount $thumbDown$actualDislikeCount";
  }

  String get visibleVariant => variant == 0 ? '' : " ($variant)";
  String get visibleTitle => "$title$visibleVariant";
  String visibleTitleWithRating(int extraLikes, int extraDislikes) =>
      "$visibleTitle | ${formattedRating(extraLikes, extraDislikes)}";
  String visibleTitleWithArtistAndRating(int extraLikes, int extraDislikes) =>
      "$visibleTitle | $artist | ${formattedRating(extraLikes, extraDislikes)}";

  String get searchFor => "$artist $title";

  Song asSong() =>
      Song(artist: artist, title: visibleTitle, text: text)..favorite = true;

  static CloudSong fromSong(Song song) => CloudSong(
      songId: -1,
      googleAccount: 'Flutter_debug',
      deviceIdHash: 'Flutter_debug',
      artist: song.artist,
      title: song.title,
      text: song.text,
      textHash: Song.songTextHash(song.text),
      isUserSong: song.origTextMD5 == Song.userSongMD5,
      variant: -1,
      raiting: 0.0,
      likeCount: 0,
      dislikeCount: 0);
}
