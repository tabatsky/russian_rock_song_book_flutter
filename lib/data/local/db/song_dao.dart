import 'dart:developer';

import 'package:russian_rock_song_book/data/local/repository/song_repository_impl.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:sqflite/sqflite.dart';

class SongDao {
  Database? _db;

  Future<void> initDB() async {
    _db = await openDatabase('russian_rock_song_book.db');
  }

  Future<void> closeDB() async {
    await _db?.close();
  }

  Future<void> createTableAndIndex() async {
    const tableQuery = """
    CREATE TABLE IF NOT EXISTS songEntity
    (id INTEGER PRIMARY KEY AUTOINCREMENT,
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    text TEXT NOT NULL,
    favorite INTEGER NOT NULL DEFAULT 0,
    deleted INTEGER NOT NULL DEFAULT 0 ,
    outOfTheBox INTEGER NOT NULL DEFAULT 1,
    origTextMD5 TEXT NOT NULL)
    """;

    await _db?.execute(tableQuery);
    log('table create if not exists done');

    const indexQuery = 'CREATE UNIQUE INDEX IF NOT EXISTS the_index ON songEntity (artist, title)';
    await _db?.execute(indexQuery);
    log('index create if not exists done');
  }

  Future<void> insertIgnoreSongs(List<SongEntity> songEntities) async {
    const query = """
    INSERT OR IGNORE INTO songEntity
    (artist, title, text, favorite, deleted, outOfTheBox, origTextMD5)
    VALUES
    (?, ?, ?, ?, ?, ?, ?);
    """;
    await _db?.transaction((txn) async {
      for (final songEntity in songEntities) {
        await txn.rawInsert(
            query,
            [
              songEntity.artist, songEntity.title, songEntity.text,
              songEntity.favorite, songEntity.deleted, songEntity.outOfTheBox,
              songEntity.origTextMD5
            ]);
      }
    });
  }
  
  Future<void> insertReplaceSong(SongEntity songEntity) async {
    const query = """
    INSERT OR REPLACE INTO songEntity
    (artist, title, text, favorite, deleted, outOfTheBox, origTextMD5)
    VALUES
    (?, ?, ?, ?, ?, ?, ?);
    """;

    await _db?.rawInsert(
        query,
        [
          songEntity.artist, songEntity.title, songEntity.text,
          songEntity.favorite, songEntity.deleted, songEntity.outOfTheBox,
          songEntity.origTextMD5
        ]);
  }

  Future<List<String>> getArtists() async {
    List<String> result = <String>[];

    result.add(SongRepository.artistFavorite);
    result.add(SongRepository.artistCloudSearch);

    List<Map> list = await _db?.rawQuery(
        'SELECT DISTINCT artist FROM songEntity WHERE deleted=0 ORDER BY artist'
    ) ?? [];

    for (var map in list) {
      String artist = map["artist"] as String;
      result.add(artist);
    }

    return result;
  }

  Future<List<SongEntity>> getSongsByArtist(String artist) async {
    if (artist == SongRepository.artistFavorite) {
      return _getSongsFavorite();
    } else {
      return _getSongsByArtistNotFavorite(artist);
    }
  }

  Future<List<SongEntity>> _getSongsByArtistNotFavorite(String artist) async {
    List<SongEntity> result = <SongEntity>[];

    const query = 'SELECT * FROM songEntity WHERE artist=? AND deleted=0 ORDER BY title';

    List<Map> list = await _db?.rawQuery(query, [artist]) ?? [];

    for (var map in list) {
      int id = map['id'] as int;
      String title = map['title'] as String;
      String text = map['text'] as String;
      int favorite = map['favorite'] as int;
      int deleted = map['deleted'] as int;
      int outOfTheBox = map['outOfTheBox'] as int;
      String origTextMD5 = map['origTextMD5'] as String;
      final songEntity = SongEntity.withId(id, artist, title, text)
        ..favorite = favorite
        ..deleted = deleted
        ..outOfTheBox = outOfTheBox
        ..origTextMD5 = origTextMD5;
      result.add(songEntity);
    }

    return result;
  }

  Future<List<SongEntity>> _getSongsFavorite() async {
    List<SongEntity> result = <SongEntity>[];

    const query = 'SELECT * FROM songEntity WHERE favorite=1 AND deleted=0 ORDER BY artist||title';

    List<Map> list = await _db?.rawQuery(query, []) ?? [];

    for (var map in list) {
      int id = map['id'] as int;
      String artist = map['artist'] as String;
      String title = map['title'] as String;
      String text = map['text'] as String;
      int favorite = map['favorite'] as int;
      int deleted = map['deleted'] as int;
      int outOfTheBox = map['outOfTheBox'] as int;
      String origTextMD5 = map['origTextMD5'] as String;
      final songEntity = SongEntity.withId(id, artist, title, text)
        ..favorite = favorite
        ..deleted = deleted
        ..outOfTheBox = outOfTheBox
        ..origTextMD5 = origTextMD5;
      result.add(songEntity);
    }

    return result;
  }

  Future<void> updateSong(SongEntity songEntity) async {
    const query = 'UPDATE songEntity SET text=?, favorite=?, deleted=? WHERE id=?';

    await _db?.rawUpdate(query, [
      songEntity.text, songEntity.favorite, songEntity.deleted, songEntity.id
    ]);
  }

  Future<void> setFavorite(bool favorite, String artist, String title) async {
    const query = 'UPDATE songEntity SET favorite=? WHERE artist=? AND title=?';

    await _db?.rawUpdate(query, [
      favorite ? 1 : 0, artist, title
    ]);
  }

  Future<SongEntity?> getSongByArtistAndPosition(String artist, int position) async {
    if (artist == SongRepository.artistFavorite) {
      return _getSongByPositionFavorite(position);
    } else {
      return _getSongByArtistAndPositionNotFavorite(artist, position);
    }
  }

  Future<SongEntity?> _getSongByArtistAndPositionNotFavorite(String artist, int position) async {
    const query = """
    SELECT * FROM songEntity WHERE artist=? AND deleted=0
    ORDER BY title LIMIT 1 OFFSET ?
    """;

    List<SongEntity> result = <SongEntity>[];

    List<Map> list = await _db?.rawQuery(query, [artist, position]) ?? [];

    for (var map in list) {
      int id = map['id'] as int;
      String title = map['title'] as String;
      String text = map['text'] as String;
      int favorite = map['favorite'] as int;
      int deleted = map['deleted'] as int;
      int outOfTheBox = map['outOfTheBox'] as int;
      String origTextMD5 = map['origTextMD5'] as String;
      final songEntity = SongEntity.withId(id, artist, title, text)
        ..favorite = favorite
        ..deleted = deleted
        ..outOfTheBox = outOfTheBox
        ..origTextMD5 = origTextMD5;
      result.add(songEntity);
    }

    return result.elementAtOrNull(0);
  }

  Future<SongEntity?> _getSongByPositionFavorite(int position) async {
    const query = """
    SELECT * FROM songEntity WHERE favorite=1 AND deleted=0
    ORDER BY artist||title LIMIT 1 OFFSET ?
    """;

    List<SongEntity> result = <SongEntity>[];

    List<Map> list = await _db?.rawQuery(query, [position]) ?? [];

    for (var map in list) {
      int id = map['id'] as int;
      String artist = map['artist'] as String;
      String title = map['title'] as String;
      String text = map['text'] as String;
      int favorite = map['favorite'] as int;
      int deleted = map['deleted'] as int;
      int outOfTheBox = map['outOfTheBox'] as int;
      String origTextMD5 = map['origTextMD5'] as String;
      final songEntity = SongEntity.withId(id, artist, title, text)
        ..favorite = favorite
        ..deleted = deleted
        ..outOfTheBox = outOfTheBox
        ..origTextMD5 = origTextMD5;
      result.add(songEntity);
    }

    return result.elementAtOrNull(0);
  }
  
  Future<SongEntity?> getSongByArtistAndTitle(String artist, String title) async {
    const query = """
      SELECT * FROM songEntity WHERE artist=? AND title=?
    """;

    List<SongEntity> result = <SongEntity>[];

    List<Map> list = await _db?.rawQuery(query, [artist, title]) ?? [];

    for (var map in list) {
      int id = map['id'] as int;
      String artist = map['artist'] as String;
      String title = map['title'] as String;
      String text = map['text'] as String;
      int favorite = map['favorite'] as int;
      int deleted = map['deleted'] as int;
      int outOfTheBox = map['outOfTheBox'] as int;
      String origTextMD5 = map['origTextMD5'] as String;
      final songEntity = SongEntity.withId(id, artist, title, text)
        ..favorite = favorite
        ..deleted = deleted
        ..outOfTheBox = outOfTheBox
        ..origTextMD5 = origTextMD5;
      result.add(songEntity);
    }

    return result.elementAtOrNull(0);
  }

  Future<int> getCountByArtist(String artist) async {
    if (artist == SongRepository.artistFavorite) {
      return _getCountFavorite();
    } else {
      return _getCountByArtist(artist);
    }
  }

  Future<int> _getCountByArtist(String artist) async {
    const query = 'SELECT COUNT(*) AS count FROM songEntity WHERE artist=? AND deleted=0';

    List<int> result = <int>[];

    List<Map> list = await _db?.rawQuery(query, [artist]) ?? [];

    for (var map in list) {
      int count = map['count'] as int;
      result.add(count);
    }

    return result.elementAtOrNull(0) ?? 0;
  }

  Future<int> _getCountFavorite() async {
    const query = 'SELECT COUNT(*) AS count FROM songEntity WHERE favorite=1 AND deleted=0';

    List<int> result = <int>[];

    List<Map> list = await _db?.rawQuery(query, []) ?? [];

    for (var map in list) {
      int count = map['count'] as int;
      result.add(count);
    }

    return result.elementAtOrNull(0) ?? 0;
  }

}