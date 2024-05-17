enum PageVariant {
  start, songList, songText, cloudSearch, cloudSongText, settings;

  String get route {
    switch (this) {
      case start:
        return '/start';
      case songList:
        return '/songList';
      case songText:
        return '/songText';
      case cloudSearch:
        return '/cloudSearch';
      case cloudSongText:
        return '/cloudSongText';
      case settings:
        return '/settings';
    }
  }
}