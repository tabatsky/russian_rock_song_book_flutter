import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song.dart';

class SongListPage extends StatelessWidget {

  String currentArtist;
  List<Song> currentSongs;
  void Function(Song s) onSongClick;

  SongListPage(this.currentArtist, this.currentSongs, this.onSongClick, {super.key});

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
        title: Text(currentArtist),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
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

  ListView _makeTitleListView() => ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: currentSongs.length,
      itemBuilder: (BuildContext context, int index) {
        var song = currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                onSongClick(song);
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

}