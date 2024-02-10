import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final double height;
  final Color color;

  const AppDivider({super.key, required this.height, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    color: color,
  );

}