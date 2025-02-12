import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/ui/widgets/clickable_word_text/word_scanner.dart';

class ClickableWordText extends StatelessWidget {
  final String text;
  final List<String> actualWords;
  final Map<String, String> actualMappings;
  final void Function(String word) onWordTap;
  final TextStyle style1;
  final TextStyle style2;
  final Key textKey;

  const ClickableWordText({super.key, required this.text, required this.actualWords, required this.actualMappings, required this.onWordTap, required this.style1, required this.style2, required this.textKey});

  @override
  Widget build(BuildContext context) {
    final words = WordScanner(text)
        .getWordList()
        .where((element) {
          var text = element.text;
          actualMappings.forEach((key, value) {
            text = text.replaceAll(key, value);
          });
          return actualWords.contains(text);
        })
        .toList();
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
              var text = text2;
              actualMappings.forEach((key, value) {
                text = text.replaceAll(key, value);
              });
              onWordTap(text);
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
        key: textKey,
        text: TextSpan(
          children: list,
        )
    );
  }

}