import 'package:guitar_chord_library/guitar_chord_library.dart';

class AllChords {
  static final instrument = GuitarChordLibrary.instrument();

  static final keys = instrument.getKeys();

  static final chordsNames = keys
      .expand((element) => instrument.getChordsByKey(element) ?? [])
      .map((e) {
    if (e is Chord) {
      final suffix = e.suffix;
      String actualSuffix;
      if (suffix == "major") {
        actualSuffix = '';
      } else if (suffix == "minor") {
        actualSuffix = 'm';
      } else {
        actualSuffix = suffix;
      }
      return e.chordKey + actualSuffix;
    } else {
      return '';
    }
  }).toList();

  static final chordMappings = {
    'H': 'A',
    'Eb': 'D#',
    'Bb': 'A#',
    'Ab': 'G#'
  };
}