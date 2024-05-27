import 'package:russian_rock_song_book/domain/models/local/song.dart';

class SongEntity {
  int id = 0;
  String artist;
  String title;
  String text;
  int favorite = 0;
  int deleted = 0;
  int outOfTheBox = 1;
  String origTextMD5 = "";

  SongEntity.withId(this.id, this.artist, this.title, this.text);

  SongEntity.fromAll(
      this.id,
      this.artist,
      this.title,
      this.text,
      this.favorite,
      this.deleted,
      this.outOfTheBox,
      this.origTextMD5
      );

  factory SongEntity.fromSong(Song song) => SongEntity.fromAll(
      song.id,
      song.artist,
      song.title,
      song.text,
      song.favorite ? 1 : 0,
      song.deleted ? 1 : 0,
      song.outOfTheBox ? 1: 0,
      song.origTextMD5
  );

  Song toSong() => Song.fromAll(
      id,
      artist,
      title,
      text,
      favorite > 0,
      deleted > 0,
      outOfTheBox > 0,
      origTextMD5);
}