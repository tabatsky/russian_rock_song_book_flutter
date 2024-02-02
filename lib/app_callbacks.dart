class LocalCallbacks {
  final void Function(int position) onSongClick;
  final void Function(String artist) onArtistClick;
  final void Function() onBackPressed;
  final void Function() onPrevSong;
  final void Function() onNextSong;
  final void Function() onToggleFavorite;
  final void Function(String updatedText) onSaveSongText;
  final void Function() onUploadCurrentToCloud;
  final void Function() onOpenVkMusic;
  final void Function() onOpenYandexMusic;
  final void Function() onOpenYoutubeMusic;

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