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

  Song.fromAll(
      this.id,
      this.artist,
      this.title,
      this.text,
      this.favorite,
      this.deleted,
      this.outOfTheBox,
      this.origTextMD5
      );

  @override
  String toString() {
    return """
    $id
    $artist - $title
    $favorite
    $deleted
    $outOfTheBox
    """;
  }
}