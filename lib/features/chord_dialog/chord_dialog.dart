import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:russian_rock_song_book/features/chord_dialog/all_chords.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';

class ChordDialog {
  static Future<void> showChordDialog(BuildContext context, AppSettings settings, String chordName) {
    const height = 200.0;
    final color1 = settings.theme.colorMain;
    final color2 = settings.theme.colorBg;
    final chord = AllChords.chords.firstWhere((element) =>
    element.actualName == chordName);
    final position = chord.chordPositions[0];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: null,
          backgroundColor: settings.theme.colorCommon,
          surfaceTintColor: Colors.black,
          content: Container(
            color: color1,
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
              labelColor: color2,
              tabForegroundColor: color1,
              tabBackgroundColor: color2,
              barColor: color2,
              stringColor: color2,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings.strClose, style: settings.textStyler.textStyleSmallBlack),
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