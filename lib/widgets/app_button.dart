import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const AppButton({super.key, required this.title,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.appPrimary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 42,
          width: MediaQuery.sizeOf(context).width * 0.45,
          decoration: BoxDecoration(
            color: AppColors.appAccent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.appPrimary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.appPrimary.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.appTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
