import 'package:russian_rock_song_book/order_by.dart';
import 'package:russian_rock_song_book/warning.dart';

class UIAction {}

class ShowSongList extends UIAction {}

class SongClick extends UIAction {
  int position;

  SongClick(this.position);
}

class ArtistClick extends UIAction {
  String artist;

  ArtistClick(this.artist);
}

class Back extends UIAction {}
class PrevSong extends UIAction {}
class NextSong extends UIAction {}
class ToggleFavorite extends UIAction {}

class SaveSongText extends UIAction {
  String updatedText;

  SaveSongText(this.updatedText);
}

class UploadCurrentToCloud extends UIAction {}
class DeleteCurrentToTrash extends UIAction {}

class OpenVkMusic extends UIAction {
  String searchFor;

  OpenVkMusic(this.searchFor);
}

class OpenYandexMusic extends UIAction {
  String searchFor;

  OpenYandexMusic(this.searchFor);
}

class OpenYoutubeMusic extends UIAction {
  String searchFor;

  OpenYoutubeMusic(this.searchFor);
}

class SendWarning extends UIAction {
  Warning warning;

  SendWarning(this.warning);
}

class CloudSearch extends UIAction {
  String searchFor;
  OrderBy orderBy;

  CloudSearch(this.searchFor, this.orderBy);
}

class CloudSongClick extends UIAction {
  int position;

  CloudSongClick(this.position);
}

class BackupSearchState extends UIAction {
  String searchFor;
  OrderBy orderBy;

  BackupSearchState(this.searchFor, this.orderBy);
}

class PrevCloudSong extends UIAction {}
class NextCLoudSong extends UIAction {}
class DownloadCurrent extends UIAction {}
class LikeCurrent extends UIAction {}
class DislikeCurrent extends UIAction {}