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

  const CloudSong(
      this.songId, this.googleAccount, this.deviceIdHash,
      this.artist, this.title, this.text, this.textHash,
      this.isUserSong, this.variant, this.raiting,
      this.likeCount, this.dislikeCount);

  String description() => "$artist; $title; $variant";

  @override
  String toString() => description();

  String formattedRating(int extraLikes, int extraDislikes) {
    final actualLikeCount = likeCount + extraLikes;
    final actualDislikeCount = dislikeCount + extraDislikes;
    return "$thumbUp$actualLikeCount $thumbDown$actualDislikeCount";
  }
  String get visibleVariant => variant==0 ? '' : " ($variant)";
  String get visibleTitle => "$title$visibleVariant";
  String visibleTitleWithRating(int extraLikes, int extraDislikes) =>
      "$visibleTitle | ${formattedRating(extraLikes, extraDislikes)}";
  String visibleTitleWithArtistAndRating(int extraLikes, int extraDislikes) =>
      "$visibleTitle | $artist | ${formattedRating(extraLikes, extraDislikes)}";

  String get searchFor => "$artist $title";

  Song asSong() => Song(artist, visibleTitle, text)
      ..favorite = true;

  static CloudSong fromSong(Song song) => CloudSong(
      -1, 'Flutter_debug', 'Flutter_debug',
      song.artist, song.title, song.text,
      Song.songTextHash(song.text), song.origTextMD5 == Song.userSongMD5,
      -1, 0.0, 0, 0
  );

}