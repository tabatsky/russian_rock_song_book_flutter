import 'dart:convert';

import 'package:crypto/crypto.dart';

class Song {
  int id = 0;
  final String artist;
  final String title;
  String text;
  bool favorite = false;
  bool deleted = false;
  bool outOfTheBox = true;
  String origTextMD5 = "";

  Song({required this.artist, required this.title, required this.text});

  Song.fromAll(
      {required this.id,
      required this.artist,
      required this.title,
      required this.text,
      required this.favorite,
      required this.deleted,
      required this.outOfTheBox,
      required this.origTextMD5});

  @override
  String toString() {
    return """
    $id
    $artist - $title
    $favorite
    $deleted
    $outOfTheBox
    """;
  }

  String get searchFor => "$artist $title";

  bool get textWasChanged => origTextMD5 != songTextHash(text);

  static const userSongMD5 = "USER";

  static String songTextHash(String text) {
    final String preparedText = text.replaceAll(RegExp('\\s+'), ' ');
    final hash = md5.convert(preparedText.codeUnits).bytes;
    return base64Encode(hash);
  }
}
