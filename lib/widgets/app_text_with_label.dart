import 'package:flutter/material.dart';

class AppTextWithLabel extends StatelessWidget {
  final String label;
  final String title;
  final TextAlign textAlign;
  final int maxLine;
  const AppTextWithLabel(
      {super.key,
      required this.label,
      required this.title,
      this.textAlign = TextAlign.start,
      this.maxLine = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.grey),
          textAlign: TextAlign.start,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.start,
          maxLines: maxLine,
        ),
      ],
    );
  }
}
