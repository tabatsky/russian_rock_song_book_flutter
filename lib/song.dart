class Song {
  int id = 0;
  String artist;
  String title;
  String text;
  bool favorite = false;
  bool deleted = false;
  bool outOfTheBox = true;
  String origTextMD5 = "";

  Song(this.artist, this.title, this.text);

  @override
  String toString() {
    return "$artist - $title";
  }

  int favoriteInt() => favorite ? 1 : 0;
  int deletedInt() => deleted ? 1 : 0;
  int outOfTheBoxInt() => outOfTheBox ? 1 : 0;
}