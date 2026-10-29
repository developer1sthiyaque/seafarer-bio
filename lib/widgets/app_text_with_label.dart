import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';

class AppTextWithLabel extends StatelessWidget {
  final String label;
  final String title;
  final TextAlign textAlign;
  final int maxLine;

  const AppTextWithLabel({
    super.key,
    required this.label,
    required this.title,
    this.textAlign = TextAlign.start,
    this.maxLine = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              letterSpacing: 0.3,
            ),
            textAlign: textAlign,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryContainer,
            ),
            textAlign: textAlign,
            maxLines: maxLine,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
