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

  String get formattedRating => "$thumbUp$likeCount $thumbDown$dislikeCount";
  String get visibleVariant => variant==0 ? '' : " ($variant)";
  String get visibleTitle => "$title$visibleVariant";
  String get visibleTitleWithRating => "$visibleTitle | $formattedRating";
  String get visibleTitleWithArtistAndRating =>
      "$visibleTitle | $artist | $formattedRating";

  String get searchFor => "$artist $title";
}