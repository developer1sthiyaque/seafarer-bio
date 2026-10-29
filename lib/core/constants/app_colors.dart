import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Stitch M3 Primary (Midnight Fleet Navy)
  static const Color primary = Color(0xFF0B1F3A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0B1F3A);
  static const Color onPrimaryContainer = Color(0xFF7587A7);
  static const Color primaryFixed = Color(0xFFD6E3FF);
  static const Color primaryFixedDim = Color(0xFFB5C7EA);
  static const Color onPrimaryFixed = Color(0xFF071C36);
  static const Color onPrimaryFixedVariant = Color(0xFF364764);
  static const Color inversePrimary = Color(0xFFB5C7EA);

  // Stitch M3 Secondary (Nautical Brass & Warm Gold)
  static const Color secondary = Color(0xFF795916);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDD182);
  static const Color onSecondaryContainer = Color(0xFF775815);
  static const Color secondaryFixed = Color(0xFFFFDEA7);
  static const Color secondaryFixedDim = Color(0xFFEBC073);
  static const Color onSecondaryFixed = Color(0xFF271900);
  static const Color onSecondaryFixedVariant = Color(0xFF5E4200);

  // Stitch M3 Surface & Background (Warm Nautical Ivory / Parchment)
  static const Color background = Color(0xFFFAF9F6);
  static const Color onBackground = Color(0xFF1B1C1A);
  static const Color surface = Color(0xFFFAF9F6);
  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color surfaceDim = Color(0xFFDBDAD7);
  static const Color surfaceBright = Color(0xFFFAF9F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F0);
  static const Color surfaceContainer = Color(0xFFEFEEEB);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E5);
  static const Color surfaceContainerHighest = Color(0xFFE3E2DF);
  static const Color onSurfaceVariant = Color(0xFF44474D);
  static const Color surfaceTint = Color(0xFF4D5F7D);

  // Stitch M3 Text & Outline Neutrals
  static const Color outline = Color(0xFF75777E);
  static const Color outlineVariant = Color(0xFFC4C6CE);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF2F312F);
  static const Color onInverseSurface = Color(0xFFF2F1EE);

  // Stitch M3 Status, Error & Tertiary
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color tertiary = Color(0xFF170001);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF470007);
  static const Color onTertiaryContainer = Color(0xFFD46462);
  static const Color tertiaryFixed = Color(0xFFFFDAD8);
  static const Color tertiaryFixedDim = Color(0xFFFFB3AF);
  static const Color onTertiaryFixed = Color(0xFF410006);
  static const Color onTertiaryFixedVariant = Color(0xFF812628);

  // Mapped existing AppColors names pointing at mapped values
  static const Color appPrimary = primary;
  static const Color appSecondary = secondary;
  static const Color appAccent = secondaryContainer;
  static const Color appScaffold = surface;
  static const Color appSurface = surfaceContainerLowest;
  static const Color appTextColor = onSurface;
  static const Color appTextMuted = onSurfaceVariant;
  static const Color appErrorColor = error;
  static const Color appBorderColor = outline;
}
