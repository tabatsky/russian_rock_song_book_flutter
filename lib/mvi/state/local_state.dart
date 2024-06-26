import 'package:russian_rock_song_book/domain/models/local/song.dart';

class LocalState{
  String currentArtist = 'Кино';
  List<Song> currentSongs = <Song>[];
  int currentCount = 0;
  List<String> allArtists = [];
  Song? currentSong;
  int currentSongPosition = -1;
  int scrollPosition = 0;

  LocalState();

  LocalState._newInstance(
      this.currentArtist,
      this.currentSongs,
      this.currentCount,
      this.allArtists,
      this.currentSong,
      this.currentSongPosition,
      this.scrollPosition
      );

  LocalState copy() => LocalState._newInstance(
      currentArtist,
      currentSongs,
      currentCount,
      allArtists,
      currentSong,
      currentSongPosition,
      scrollPosition
  );
}