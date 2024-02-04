import 'order_by.dart';

class LocalCallbacks {
  final void Function(int position) onSongClick;
  final void Function(String artist) onArtistClick;
  final void Function() onBackPressed;
  final void Function() onPrevSong;
  final void Function() onNextSong;
  final void Function() onToggleFavorite;
  final void Function(String updatedText) onSaveSongText;
  final void Function() onUploadCurrentToCloud;
  final void Function(String searchFor) onOpenVkMusic;
  final void Function(String searchFor) onOpenYandexMusic;
  final void Function(String searchFor) onOpenYoutubeMusic;

  LocalCallbacks(
      this.onSongClick,
      this.onArtistClick,
      this.onBackPressed,
      this.onPrevSong,
      this.onNextSong,
      this.onToggleFavorite,
      this.onSaveSongText,
      this.onUploadCurrentToCloud,
      this.onOpenVkMusic,
      this.onOpenYandexMusic,
      this.onOpenYoutubeMusic
      );
}

class CloudCallbacks {
  final void Function(String searchFor, OrderBy orderBy) onPerformCloudSearch;
  final void Function(String searchFor, OrderBy orderBy) onBackupSearchState;
  final void Function(int position) onCloudSongClick;
  final void Function() onBackPressed;
  final void Function() onPrevCloudSong;
  final void Function() onNextCloudSong;
  final void Function() onDownloadCurrent;
  final void Function(String searchFor) onOpenVkMusic;
  final void Function(String searchFor) onOpenYandexMusic;
  final void Function(String searchFor) onOpenYoutubeMusic;
  final void Function() onLikeCurrent;
  final void Function() onDislikeCurrent;

  CloudCallbacks(
      this.onPerformCloudSearch,
      this.onBackupSearchState,
      this.onCloudSongClick,
      this.onBackPressed,
      this.onPrevCloudSong,
      this.onNextCloudSong,
      this.onDownloadCurrent,
      this.onOpenVkMusic,
      this.onOpenYandexMusic,
      this.onOpenYoutubeMusic,
      this.onLikeCurrent,
      this.onDislikeCurrent
      );
}