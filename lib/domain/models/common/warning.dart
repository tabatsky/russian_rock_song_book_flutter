import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';

const typeCloud = 'cloud';
const typeOutOfTheBox = 'outOfTheBox';

class Warning {
  String warningType;
  String artist;
  String title;
  int variant;
  String comment;
  
  Warning(this.warningType, this.artist, this.title, this.variant, this.comment);

  static Warning fromSongWithComment(Song song, String comment) =>
      Warning(typeOutOfTheBox, song.artist, song.title, -1, comment);

  static Warning fromCloudSongWithComment(CloudSong cloudSong, String comment) =>
      Warning(typeCloud, cloudSong.artist, cloudSong.title, cloudSong.variant, comment);
}