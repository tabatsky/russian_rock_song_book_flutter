import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';

class AppUIAction {}

class ShowSongList extends AppUIAction {}

class SongClick extends AppUIAction {
  int position;

  SongClick(this.position);
}

class ArtistClick extends AppUIAction {
  String artist;

  ArtistClick(this.artist);
}

class Back extends AppUIAction {
  bool systemBack;

  Back({this.systemBack = false});
}
class PrevSong extends AppUIAction {}
class NextSong extends AppUIAction {}
class ToggleFavorite extends AppUIAction {}

class SaveSongText extends AppUIAction {
  String updatedText;

  SaveSongText(this.updatedText);
}

class UploadCurrentToCloud extends AppUIAction {}
class DeleteCurrentToTrash extends AppUIAction {}

class OpenVkMusic extends AppUIAction {
  String searchFor;

  OpenVkMusic(this.searchFor);
}

class OpenYandexMusic extends AppUIAction {
  String searchFor;

  OpenYandexMusic(this.searchFor);
}

class OpenYoutubeMusic extends AppUIAction {
  String searchFor;

  OpenYoutubeMusic(this.searchFor);
}

class SendWarning extends AppUIAction {
  Warning warning;

  SendWarning(this.warning);
}

class CloudSearch extends AppUIAction {
  String searchFor;
  OrderBy orderBy;

  CloudSearch(this.searchFor, this.orderBy);
}

class CloudSongClick extends AppUIAction {
  int position;

  CloudSongClick(this.position);
}

class BackupSearchState extends AppUIAction {
  String searchFor;
  OrderBy orderBy;

  BackupSearchState(this.searchFor, this.orderBy);
}

class PrevCloudSong extends AppUIAction {}
class NextCLoudSong extends AppUIAction {}
class DownloadCurrent extends AppUIAction {}
class LikeCurrent extends AppUIAction {}
class DislikeCurrent extends AppUIAction {}

class UpdateCloudSongListNeedScroll extends AppUIAction {
  bool needScroll;

  UpdateCloudSongListNeedScroll(this.needScroll);
}

class OpenSettings extends AppUIAction {}
class SaveSettings extends AppUIAction {
  AppSettings settings;

  SaveSettings(this.settings);
}
class ReloadSettings extends AppUIAction {}