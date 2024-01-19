import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:russian_rock_song_book/song.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._privateConstructor();

  factory AssetManager() {
    return _instance;
  }

  AssetManager._privateConstructor();

  Future<List<Song>> loadAsset(String artist) async {
    final jsonString = await rootBundle.loadString('assets/json/$artist.json');
    final jsonSongbook = jsonDecode(jsonString) as Map<String, dynamic>;
    final songbook = jsonSongbook['songbook'] as List<dynamic>;
    final songList = songbook.map((jsonSong) {
      final title = jsonSong['title'];
      final text = jsonSong['text'];
      final song = Song(title, text);
      return song;
    }).toList();
    return songList;
  }
}