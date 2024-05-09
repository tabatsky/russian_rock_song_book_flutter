import 'dart:developer';

import 'package:russian_rock_song_book/data/asset_manager/asset_manager.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/data/local/db/song_dao.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';

class SongRepositoryImpl implements SongRepository {
  SongRepositoryImpl();

  SongDao? _songDao;

  @override
  Future<void> initDB() async {
    _songDao = SongDao();
    await _songDao?.initDB();
  }

  @override
  Future<void> fillDB(void Function(int done, int total) onProgressChanged) async {
    await _songDao?.createTableAndIndex();
    await _fillTable(onProgressChanged);
  }

  Future<void> _fillTable(void Function(int done, int total) onProgressChanged) async {
    final total = SongRepository.artistMap.length;
    var done = 0;
    onProgressChanged(done, total);

    for (var entry in SongRepository.artistMap.entries) {
      final artistName = entry.key;
      final artistId = entry.value;
      final songs = await AssetManager().loadAsset(artistId, artistName);
      await insertIgnoreSongs(songs);
      log("artist '$artistName' added to db: ${songs.length} songs");
      done++;
      onProgressChanged(done, total);
    }
  }

  @override
  Future<void> insertIgnoreSongs(List<Song> songs) async {
    final songEntities = songs.map((e) => SongEntity.fromSong(e)).toList();
    _songDao?.insertIgnoreSongs(songEntities);
  }

  @override
  Future<List<String>> getArtists() async {
    final result = await _songDao?.getArtists();
    return result ?? [];
  }

  @override
  Future<List<Song>> getSongsByArtist(String artist) async {
    final result = await _songDao?.getSongsByArtist(artist);
    return result?.map((e) => e.toSong()).toList() ?? [];
  }

  @override
  Future<void> updateSong(Song song) async => _songDao?.updateSong(SongEntity.fromSong(song));

  @override
  Future<Song?> getSongByArtistAndPosition(String artist, int position) async {
    final songEntity = await _songDao?.getSongByArtistAndPosition(artist, position);
    return songEntity?.toSong();
  }

  @override
  Future<int> getCountByArtist(String artist) async {
    final result = await _songDao?.getCountByArtist(artist);
    return result ?? 0;
  }

  @override
  Future<void> addSongFromCloud(Song song) async {
    final existingSong = await _songDao?.getSongByArtistAndTitle(song.artist, song.title);

    if (existingSong == null) {
      final songEntity = SongEntity.fromSong(song);
      await _songDao?.insertReplaceSong(songEntity);
    } else {
      existingSong.text = song.text;
      existingSong.deleted = 0;
      existingSong.favorite = 1;
      await _songDao?.updateSong(existingSong);
    }
  }
}

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