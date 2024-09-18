import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/domain/models/local/song.dart';

extension ArtistGroup on String {
  String artistGroup() => characters.first.toUpperCase();
}

extension ArtistGroups on List<String> {
  List<String> artistGroups() {
    var result = map((e) => e.artistGroup())
        .toSet()
        .toList();
    result.sort();
    return result;
  }

  List<String> predefinedArtistsWithGroups() =>
      SongRepository.predefinedArtists + artistGroups();
}

abstract class SongRepository {

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

  Future<void> initDB();

  Future<void> fillDB(void Function(int done, int total) onProgressChanged);

  Future<void> insertIgnoreSongs(List<Song> songs);

  Future<List<String>> getArtists();

  Future<List<Song>> getSongsByArtist(String artist);

  Future<void> updateSong(Song song);

  Future<Song?> getSongByArtistAndPosition(String artist, int position);

  Future<int> getCountByArtist(String artist);

  Future<void> addSongFromCloud(Song song);
}