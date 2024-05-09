import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:russian_rock_song_book/data/local/repository/song_repository_impl.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/russian_rock_song_book_app.dart';

void main() {
  GetIt.I.registerLazySingleton<SongRepository>(() => SongRepositoryImpl());

  runApp(RussianRockSongBookApp());
}

