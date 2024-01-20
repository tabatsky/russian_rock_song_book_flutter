import 'dart:developer';

import 'package:russian_rock_song_book/asset_manager.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:sqflite/sqflite.dart';

class SongRepository {
  static final SongRepository _instance = SongRepository._privateConstructor();

  static final artistMap = {
    'Агата Кристи': 'agata',
    'Алиса': 'alisa',
    'Кино': 'kino'
  };

  Database? _db;

  factory SongRepository() {
    return _instance;
  }

  SongRepository._privateConstructor();

  Future<void> initDB() async {
    _db = await openDatabase('russian_rock_song_book.db');
    //await _createTableAndIndex();
    //await _fillTable();
  }

  Future<void> closeDB() async {
    await _db?.close();
  }
  
  Future<void> _createTableAndIndex() async {
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
  
  Future<void> _fillTable() async {
    for (var entry in artistMap.entries) {
      final artistName = entry.key;
      final artistId = entry.value;
      final songs = await AssetManager().loadAsset(artistId, artistName);
      await insertIgnoreSongs(songs);
      log("artist '$artistName' added to db: ${songs.length} songs");
    }
  }

  Future<void> insertIgnoreSongs(List<Song> songs) async {
    const query = """
    INSERT OR IGNORE INTO songEntity
    (artist, title, text, favorite, deleted, outOfTheBox, origTextMD5)
    VALUES
    (?, ?, ?, ?, ?, ?, ?);
    """;
    await _db?.transaction((txn) async {
      for (final song in songs) {
        await txn.rawInsert(
            query,
            [
              song.artist, song.title, song.text,
              song.favoriteInt(), song.deletedInt(), song.outOfTheBoxInt(),
              song.origTextMD5
            ]);
      }
    });
  }

  Future<List<String>> getArtists() async {
    List<String> result = <String>[];

    List<Map> list = await _db?.rawQuery(
        'SELECT DISTINCT artist FROM songEntity WHERE deleted=0 ORDER BY artist'
    ) ?? [];

    for (var map in list) {
      String artist = map["artist"] as String;
      result.add(artist);
    }

    return result;
  }

  Future<List<Song>> getSongsByArtist(String artist) async {
    List<Song> result = <Song>[];

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
      final song = Song.withId(id, artist, title, text)
                      ..favorite = favorite > 0
                      ..deleted = deleted > 0
                      ..outOfTheBox = outOfTheBox > 0
                      ..origTextMD5 = origTextMD5;
      result.add(song);
    }

    return result;
  }
}