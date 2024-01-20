import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/song.dart';

class SongTextPage extends StatelessWidget {

  Song? currentSong;
  void Function() onBackPressed;

  SongTextPage(this.currentSong, this.onBackPressed, {super.key});

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
        title: Text(currentSong?.title ?? 'null'),
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            onBackPressed();
          },
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
            Flexible(child: _makeSongTextView()),
          ],
        ),
      ),
    );
  }

  Widget _makeSongTextView() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.yellow,
        child: Text(currentSong?.text ?? 'null'),
      ),
    );
  }

}