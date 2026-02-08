import 'package:flutter/material.dart';

class AppTextView extends StatelessWidget {
  final String title;
  final TextAlign textAlign;
  final TextStyle textStyle;
  const AppTextView(
      {super.key, required this.title,required this.textStyle ,this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textStyle,
      textAlign: textAlign,
    );
  }
}
