import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song.dart';
import 'package:russian_rock_song_book/song_repository.dart';

class SongListPage extends StatefulWidget{

  String currentArtist;
  List<Song> currentSongs;
  void Function(Song s) onSongClick;

  SongListPage(this.currentArtist, this.currentSongs, this.onSongClick, {super.key});

  @override
  State<SongListPage> createState() => SongListPageState();
}

class SongListPageState extends State<SongListPage> {

  List<String> allArtists = [];

  @override
  void initState() {
    super.initState();
    _initArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.currentArtist),
      ),
      drawer: Drawer(
        child: _makeMenuListView(),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(child: _makeTitleListView()),
          ],
        ),
      ),
    );
  }

  ListView _makeMenuListView() => ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: allArtists.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              margin: EdgeInsets.zero,
              child: Text('Меню'),
            ),
          );
        } else {
          final artist = allArtists[index - 1];
          return ListTile(
            title: Text(artist),
            onTap: () {
              log("$artist click");
            },
          );
        }
      }
  );

  /*=> ListView(
    // Important: Remove any padding from the ListView.
    padding: EdgeInsets.zero,
    children: [

      ListTile(
        title: const Text('Item 2'),
        onTap: () {
          // Update the state of the app.
          // ...
        },
      ),
    ],
  );
*/
  ListView _makeTitleListView() => ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.currentSongs.length,
      itemBuilder: (BuildContext context, int index) {
        var song = widget.currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.onSongClick(song);
              },
              child: Container(
                  height: 50,
                  color: Colors.yellow,
                  child: Center(
                    child: Text(song.title),
                  )
              ),
            ),
            const Divider(
              height: 3.0,
              color: Colors.black,
            )
          ],
        );
      }
  );

  Future<void> _initArtists() async {
    await SongRepository().initDB();
    final artists = await SongRepository().getArtists();
    log(artists.toString());
    setState(() {
      allArtists = artists;
    });
  }
}