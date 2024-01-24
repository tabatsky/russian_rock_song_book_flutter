import 'dart:developer';

import 'package:russian_rock_song_book/asset_manager.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:sqflite/sqflite.dart';

class SongRepository {
  static final SongRepository _instance = SongRepository._privateConstructor();

  static const artistFavorite = 'Избранное';
  static const artistCloudSearch = 'Аккорды онлайн';
  static const predefinedArtists = [artistFavorite, artistCloudSearch];

  static final artistMap = {
  '7Б' :  'b7',
  'Animal ДжаZ' :  'animal_dzhaz',
  'Brainstorm' :  'brainstorm',
  'Flёur' :  'flyour',
  'Louna' :  'louna',
  'Lumen' :  'lumen',
  'TequilaJazzz' :  'tequilajazzz',
  'Uma2rman' :  'umaturnan',
  'Znaki' :  'znaki',
  'Агата Кристи' :  'agata',
  'Адаптация' :  'adaptacia',
  'Аквариум' :  'akvarium',
  'Алиса' :  'alisa',
  'АнимациЯ' :  'animatsya',
  'Ария' :  'aria',
  'АукцЫон' :  'auktsyon',
  'Аффинаж' :  'afinaj',
  'Александр Башлачёв' :  'bashlachev',
  'Белая Гвардия' :  'b_gvardia',
  'Би-2' :  'bi2',
  'Браво' :  'bravo',
  'Бригада С':  'brigada_c',
  'Бригадный Подряд' :  'brigadnyi',
  'Ва-Банкъ' :  'vabank',
  'Високосный год' :  'visokosniy',
  'Воскресенье' :  'voskresenie',
  'Глеб Самойлоff & The Matrixx' :  'samoiloff',
  'Год Змеи' :  'god_zmei',
  'Гражданская Оборона' :  'grob',
  'ДДТ' :  'ddt',
  'Дельфин' :  'dolphin',
  'Дом Кукол' :  'dom_kukol',
  'Звуки Му' :  'zvukimu',
  'Земляне' :  'zemlane',
  'Земфира' :  'zemfira',
  'Зоопарк' :  'zoopark',
  'Игорь Тальков' :  'talkov',
  'Калинов Мост' :  'kalinovmost',
  'Кафе' :  'kafe',
  'Кино' :  'kino',
  'КняZz' :  'knazz',
  'Коридор' :  'koridor',
  'Король и Шут' :  'kish',
  'Крематорий' :  'krematoriy',
  'Кукрыниксы' :  'kukryniksy',
  'Ленинград' :  'leningrad',
  'Линда' :  'linda',
  'Любэ' :  'lyube',
  'Ляпис Трубецкой' :  'trubetskoi',
  'Магелланово Облако' :  'magelanovo_oblako',
  'Марко Поло' :  'marko_polo',
  'Маша и Медведи' :  'mashamedv',
  'Машина Времени' :  'machina',
  'Мельница' :  'melnitsa',
  'Мультfильмы' :  'multfilmi',
  'Мумий Тролль' :  'mumiytrol',
  'Мураками' :  'murakami',
  'Наив' :  'naiv',
  'Настя' :  'nastia',
  'Наутилус Помпилиус' :  'nautilus',
  'Неприкасаемые' :  'neprikasaemye',
  'Немного Нервно' :  'nervno',
  'Ногу Свело' :  'nogusvelo',
  'Ноль' :  'nol',
  'Ночные Снайперы' :  'snaipery',
  'Операция Пластилин' :  'operatsya_plastilin',
  'Павел Кашин' :  'kashin',
  'Павел Пиковский' :  'pikovskij_pavel_xyugo',
  'Пикник' :  'piknik',
  'Пилот' :  'pilot',
  'План Ломоносова' :  'plan_lomonosova',
  'Порнофильмы' :  'pornofilmy',
  'Северный Флот' :  'severnyi_flot',
  'Секрет' :  'sekret',
  'Сектор Газа' :  'sektor',
  'СерьГа' :  'serga',
  'Слот' :  'slot',
  'Смысловые Галлюцинации' :  'smislovie',
  'Сплин' :  'splin',
  'Танцы Минус' :  'minus',
  'Тараканы' :  'tarakany',
  'Телевизор' :  'televizor',
  'Торба-на-Круче' :  'torba_n',
  'Ундервуд' :  'undervud',
  'Чайф' :  'chaif',
  'Чёрный Кофе' :  'cherniykofe',
  'Чёрный Лукич' :  'lukich',
  'Чёрный Обелиск' :  'chobelisk',
  'Чичерина' :  'chicherina',
  'Чиж и Ко' :  'chizh',
  'Эпидемия' :  'epidemia',
  'Юта' :  'uta',
  'Янка Дягилева' :  'yanka',
  'Ясвена' : 'yasvena'
  };

  Database? _db;

  factory SongRepository() {
    return _instance;
  }

  SongRepository._privateConstructor();

  Future<void> initDB() async {
    _db = await openDatabase('russian_rock_song_book.db');
  }

  Future<void> fillDB(void Function(int done, int total) onProgressChanged) async {
    await _createTableAndIndex();
    await _fillTable(onProgressChanged);
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
  
  Future<void> _fillTable(void Function(int done, int total) onProgressChanged) async {
    final total = artistMap.length;
    var done = 0;
    onProgressChanged(done, total);

    for (var entry in artistMap.entries) {
      final artistName = entry.key;
      final artistId = entry.value;
      final songs = await AssetManager().loadAsset(artistId, artistName);
      await insertIgnoreSongs(songs);
      log("artist '$artistName' added to db: ${songs.length} songs");
      done++;
      onProgressChanged(done, total);
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

    result.add(artistFavorite);
    result.add(artistCloudSearch);

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
    if (artist == artistFavorite) {
      return _getSongsFavorite();
    } else {
      return _getSongsByArtist(artist);
    }
  }

  Future<List<Song>> _getSongsByArtist(String artist) async {
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

  Future<List<Song>> _getSongsFavorite() async {
    List<Song> result = <Song>[];

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
      final song = Song.withId(id, artist, title, text)
        ..favorite = favorite > 0
        ..deleted = deleted > 0
        ..outOfTheBox = outOfTheBox > 0
        ..origTextMD5 = origTextMD5;
      result.add(song);
    }

    return result;
  }


  Future<void> updateSong(Song song) async {
    const query = 'UPDATE songEntity SET text=?, favorite=?, deleted=? WHERE id=?';

    await _db?.rawUpdate(query, [
      song.text, song.favoriteInt(), song.deletedInt(), song.id
    ]);
  }

  Future<Song?> getSongByArtistAndPosition(String artist, int position) async {
    if (artist == artistFavorite) {
      return _getSongByPositionFavorite(position);
    } else {
      return _getSongByArtistAndPosition(artist, position);
    }
  }

  Future<Song?> _getSongByArtistAndPosition(String artist, int position) async {
    const query = """
    SELECT * FROM songEntity WHERE artist=? AND deleted=0
    ORDER BY title LIMIT 1 OFFSET ?
    """;

    List<Song> result = <Song>[];

    List<Map> list = await _db?.rawQuery(query, [artist, position]) ?? [];

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

    return result.elementAtOrNull(0);
  }

  Future<Song?> _getSongByPositionFavorite(int position) async {
    const query = """
    SELECT * FROM songEntity WHERE favorite=1 AND deleted=0
    ORDER BY artist||title LIMIT 1 OFFSET ?
    """;

    List<Song> result = <Song>[];

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
      final song = Song.withId(id, artist, title, text)
        ..favorite = favorite > 0
        ..deleted = deleted > 0
        ..outOfTheBox = outOfTheBox > 0
        ..origTextMD5 = origTextMD5;
      result.add(song);
    }

    return result.elementAtOrNull(0);
  }

  Future<int> getCountByArtist(String artist) async {
    if (artist == artistFavorite) {
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