
import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.appScaffold,

      // Color Scheme for built-in components
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.appPrimary,
        primary: AppColors.appPrimary,
        secondary: AppColors.appSecondary,
        tertiary: AppColors.appAccent,
        error: AppColors.appErrorColor,
        surface: AppColors.appSurface,
        onSurface: AppColors.appTextColor,
      ),

      // AppBar - Professional Navy look
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),

      // Global Text Styles
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.appTextColor, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.appTextColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.appTextColor),
        bodySmall: TextStyle(color: AppColors.appTextMuted),
      ),

      // Input Decoration (Text fields for Profile/Login)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.appSurface,
        labelStyle: const TextStyle(color: AppColors.appTextMuted),
        floatingLabelStyle: const TextStyle(color: AppColors.appPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.appErrorColor),
        ),
      ),

      // Primary Button (The "Next" or "Sign In" button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appAccent,
          foregroundColor: AppColors.appTextColor,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}