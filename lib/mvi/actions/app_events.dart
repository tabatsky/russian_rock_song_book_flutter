import 'package:russian_rock_song_book/data/cloud/cloud_search_pager/cloud_search_pager.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';
import 'package:russian_rock_song_book/domain/models/common/warning.dart';

class AppUIEvent {}

class ShowSongList extends AppUIEvent {}

class SongClick extends AppUIEvent {
  int position;

  SongClick(this.position);
}

class ArtistClick extends AppUIEvent {
  String artist;

  ArtistClick(this.artist);
}

class Back extends AppUIEvent {
  bool systemBack;

  Back({this.systemBack = false});
}
class PrevSong extends AppUIEvent {}
class NextSong extends AppUIEvent {}
class ToggleFavorite extends AppUIEvent {}

class SaveSongText extends AppUIEvent {
  String updatedText;

  SaveSongText(this.updatedText);
}

class UploadCurrentToCloud extends AppUIEvent {}
class DeleteCurrentToTrash extends AppUIEvent {}

class OpenVkMusic extends AppUIEvent {
  String searchFor;

  OpenVkMusic(this.searchFor);
}

class OpenYandexMusic extends AppUIEvent {
  String searchFor;

  OpenYandexMusic(this.searchFor);
}

class OpenYoutubeMusic extends AppUIEvent {
  String searchFor;

  OpenYoutubeMusic(this.searchFor);
}

class SendWarning extends AppUIEvent {
  Warning warning;

  SendWarning(this.warning);
}

class CloudSearch extends AppUIEvent {
  String searchFor;
  OrderBy orderBy;

  CloudSearch(this.searchFor, this.orderBy);
}

class NewCloudPageLoaded extends AppUIEvent {
  SearchState searchState;
  int count;
  int? lastPage;

  NewCloudPageLoaded(this.searchState, this.count, this.lastPage);
}

class CloudSongClick extends AppUIEvent {
  int position;

  CloudSongClick(this.position);
}

class BackupSearchState extends AppUIEvent {
  String searchFor;
  OrderBy orderBy;

  BackupSearchState(this.searchFor, this.orderBy);
}

class PrevCloudSong extends AppUIEvent {}
class NextCLoudSong extends AppUIEvent {}
class DownloadCurrent extends AppUIEvent {}
class LikeCurrent extends AppUIEvent {}
class DislikeCurrent extends AppUIEvent {}

class LikeSuccess extends AppUIEvent {
  CloudSong cloudSong;

  LikeSuccess(this.cloudSong);
}

class DislikeSuccess extends AppUIEvent {
  CloudSong cloudSong;

  DislikeSuccess(this.cloudSong);
}

class UpdateCloudSongListNeedScroll extends AppUIEvent {
  bool needScroll;

  UpdateCloudSongListNeedScroll(this.needScroll);
}

class OpenSettings extends AppUIEvent {}
class SaveSettings extends AppUIEvent {
  AppSettings settings;

  SaveSettings(this.settings);
}
class ReloadSettings extends AppUIEvent {}