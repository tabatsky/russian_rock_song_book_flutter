import 'package:guitar_chord_library/guitar_chord_library.dart';

class AllChords {
  static final instrument = GuitarChordLibrary.instrument();

  static final keys = instrument.getKeys();

  static final chords = keys
      .expand((element) => instrument.getChordsByKey(element) ?? [])
      .map((e) => e as Chord)
      .toList();

  static final chordsNames = chords
      .map((e) => e.actualName)
      .toList();

  static final chordMappings = {
    'H': 'A',
    'Eb': 'D#',
    'Bb': 'A#',
    'Ab': 'G#'
  };
}

extension ActualName on Chord {
  String get actualName {
    String actualSuffix;
    if (suffix == "major") {
      actualSuffix = '';
    } else if (suffix == "minor") {
      actualSuffix = 'm';
    } else {
      actualSuffix = suffix;
    }
    return chordKey + actualSuffix;
  }
}