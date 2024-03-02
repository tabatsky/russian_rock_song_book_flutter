import 'dart:developer';

import 'package:russian_rock_song_book/data/asset_manager/asset_manager.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';
import 'package:russian_rock_song_book/data/local/db/song_dao.dart';

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


  factory SongRepository() {
    return _instance;
  }

  SongRepository._privateConstructor();

  SongDao? _songDao;

  Future<void> initDB() async {
    _songDao = SongDao();
    await _songDao?.initDB();
  }

  Future<void> fillDB(void Function(int done, int total) onProgressChanged) async {
    await _songDao?.createTableAndIndex();
    await _fillTable(onProgressChanged);
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
    final songEntities = songs.map((e) => SongEntity.fromSong(e)).toList();
    _songDao?.insertIgnoreSongs(songEntities);
  }


  Future<List<String>> getArtists() async {
    final result = await _songDao?.getArtists();
    return result ?? [];
  }

  Future<List<Song>> getSongsByArtist(String artist) async {
    final result = await _songDao?.getSongsByArtist(artist);
    return result?.map((e) => e.toSong()).toList() ?? [];
  }

  Future<void> updateSong(Song song) async => _songDao?.updateSong(SongEntity.fromSong(song));

  Future<Song?> getSongByArtistAndPosition(String artist, int position) async {
    final songEntity = await _songDao?.getSongByArtistAndPosition(artist, position);
    return songEntity?.toSong();
  }

  Future<int> getCountByArtist(String artist) async {
    final result = await _songDao?.getCountByArtist(artist);
    return result ?? 0;
  }

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