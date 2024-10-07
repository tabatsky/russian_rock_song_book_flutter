import 'package:russian_rock_song_book/ui/widgets/clickable_word_text/word.dart';

class WordScanner {
  final String text;

  int _currentIndex = 0;

  WordScanner(this.text);

  bool _isLetter(String ch) =>
      RegExp(r'[A-Za-z0-9#]').hasMatch(ch);

  Word? _scanNextWord() {
    if (!_isLetter(text[_currentIndex])) {
      _currentIndex++;
      return null;
    } else {
      final sb = StringBuffer();
      final start = _currentIndex;
      while (_currentIndex < text.length && _isLetter(text[_currentIndex])) {
        sb.write(text[_currentIndex]);
        _currentIndex++;
      }
      final end = _currentIndex;
      return Word(sb.toString(), start, end);
    }
  }

  List<Word> getWordList() {
    final list = List<Word>.empty(growable: true);

    while (_currentIndex < text.length) {
      final word = _scanNextWord();
      if (word != null) {
        list.add(word);
      }
    }

    return list;
  }
}