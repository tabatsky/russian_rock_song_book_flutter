import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/ui/widgets/clickable_word_text/word_scanner.dart';

class ClickableWordText extends StatelessWidget {
  final String text;
  final TextStyle style1;
  final TextStyle style2;
  final Key key;

  const ClickableWordText({required this.text, required this.style1, required this.style2, required this.key});

  @override
  Widget build(BuildContext context) {
    final words = WordScanner(text).getWordList();
    final list = List<TextSpan>.empty(growable: true);
    int index = 0;
    int position = 0;

    while (index < words.length) {
      final word = words[index];
      final text1 = text.substring(position, word.startIndex);
      final text2 = text.substring(word.startIndex, word.endIndex);
      final textSpan1 = TextSpan(
        text: text1,
        style: style1
      );
      final textSpan2 = TextSpan(
          text: text2,
          style: style2,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              print(text2);
            },
      );
      list.add(textSpan1);
      list.add(textSpan2);
      position = word.endIndex;
      index++;
    }

    position = words.lastOrNull?.endIndex ?? 0;
    final text1 = text.substring(position);
    final textSpan1 = TextSpan(
        text: text1,
        style: style1
    );
    list.add(textSpan1);

    return RichText(
        key: key,
        text: TextSpan(
          children: list,
        )
    );
  }

}