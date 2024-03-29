import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';

class BottomButton extends StatelessWidget {
  final String icon;
  final double buttonSize;
  final void Function() onPressed;

  const BottomButton(this.icon, this.buttonSize, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      color: AppTheme.colorDarkYellow,
      child:
      IconButton(
        icon: Image.asset(icon),
        padding: const EdgeInsets.all(8),
        onPressed: onPressed,
      ),
    );
  }

}