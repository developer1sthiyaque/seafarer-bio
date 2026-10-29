
import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';

class AppTheme {
  static const String fontSans = 'Plus Jakarta Sans';
  static const String fontSerif = 'Playfair Display';

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    inversePrimary: AppColors.inversePrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: AppColors.secondaryFixedDim,
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: AppColors.tertiaryFixedDim,
    onTertiaryFixed: AppColors.onTertiaryFixed,
    onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surfaceBright,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    shadow: AppColors.shadow,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.onInverseSurface,
    surfaceTint: AppColors.surfaceTint,
  );

  static TextTheme get _textTheme {
    return const TextTheme(
      // Display (Playfair Display)
      displayLarge: TextStyle(
        fontFamily: fontSerif,
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        color: AppColors.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: fontSerif,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.48,
        color: AppColors.onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: fontSerif,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.onSurface,
      ),

      // Headline (Playfair Display)
      headlineLarge: TextStyle(
        fontFamily: fontSerif,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: AppColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontSerif,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontSerif,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),

      // Title (Plus Jakarta Sans)
      titleLarge: TextStyle(
        fontFamily: fontSans,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: fontSans,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.08,
        color: AppColors.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: fontSans,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),

      // Body (Plus Jakarta Sans)
      bodyLarge: TextStyle(
        fontFamily: fontSans,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontSans,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: fontSans,
        fontSize: 12, // Floored at 12sp
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),

      // Label (Plus Jakarta Sans)
      labelLarge: TextStyle(
        fontFamily: fontSans,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: fontSans,
        fontSize: 12, // Floored at 12sp
        fontWeight: FontWeight.w600,
        letterSpacing: 0.48,
        color: AppColors.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: fontSans,
        fontSize: 12, // Floored at 12sp
        fontWeight: FontWeight.w600,
        letterSpacing: 0.66,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontSans,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: lightColorScheme,

      // AppBar - Professional Maritime look
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      // Global Text Styles (all floored at >= 12sp)
      textTheme: _textTheme,

      // Input Decoration (Text fields for Profile/Login)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        labelStyle: const TextStyle(
          fontFamily: fontSans,
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: fontSans,
          fontSize: 14,
          color: AppColors.primary,
        ),
        // Enabled border strictly uses outline token (#75777E), 1px
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // Card Theme (outline-variant for borders)
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),

      // Divider Theme (outline-variant for dividers)
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Primary Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: fontSans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}