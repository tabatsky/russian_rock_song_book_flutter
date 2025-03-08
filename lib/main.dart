import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:russian_rock_song_book/data/cloud/repository/cloud_repository_impl.dart';
import 'package:russian_rock_song_book/data/local/repository/song_repository_impl.dart';
import 'package:russian_rock_song_book/domain/repository/cloud/cloud_repository.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/russian_rock_song_book_app.dart';

void main() {
  try {
    GetIt.I.registerLazySingleton<SongRepository>(() => SongRepositoryImpl());
    GetIt.I.registerLazySingleton<CloudRepository>(() => CloudRepositoryImpl());
  } catch (e) {
    print('failed to init dependencies');
  }

  runApp(RussianRockSongBookApp());
}

void testMain() {
  try {
    GetIt.I.registerLazySingleton<SongRepository>(() => SongRepositoryImpl());
    GetIt.I.registerLazySingleton<CloudRepository>(() => CloudRepositoryImpl());
  } catch (e) {
    print('failed to init dependencies');
  }

  runApp(RussianRockSongBookApp());
}
