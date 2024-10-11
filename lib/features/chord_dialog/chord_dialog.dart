import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:russian_rock_song_book/features/chord_dialog/all_chords.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';

class ChordDialog {
  static Future<void> showChordDialog(BuildContext context, String chordName) {
    const height = 200.0;
    final chord = AllChords.chords.firstWhere((element) =>
    element.actualName == chordName);
    final position = chord.chordPositions[0];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: null,
          content: Container(
            constraints: const BoxConstraints(
              minHeight: height,
              minWidth: 100,
              maxHeight: height,
              maxWidth: 100,
            ),
            child: FlutterGuitarChord(
              baseFret: position.baseFret,
              chordName: chordName,
              fingers: position.fingers,
              frets: position.frets,
              totalString: AllChords.instrument.stringCount,
              // labelColor: Colors.teal,
              // tabForegroundColor: Colors.white,
              // tabBackgroundColor: Colors.deepOrange,
              // barColor: Colors.black,
              // stringColor: Colors.red,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme
                    .of(context)
                    .textTheme
                    .labelLarge,
              ),
              child: const Text(AppStrings.strClose),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}