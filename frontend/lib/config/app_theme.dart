import 'package:flutter/material.dart';

/// Centralized theme configuration for the Recur app
/// All colors, text styles, and other theme-related values are defined here
/// to make them easy to modify in the future
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============= Colors =============
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color surfaceColor = Color(0xFF2A2A2A);
  static const Color primaryColor = Color(0xFF4A9EFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Colors.white;
  static const Color dividerColor = Color(0xFF333333);
  static const Color activeGreen = Color(0xFF2D5A2D);
  static const Color errorColor = Color(0xFFFF4444);

  // ============= Spacing =============
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing15 = 15.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing30 = 30.0;
  static const double spacing40 = 40.0;
  static const double spacing60 = 60.0;

  // ============= Border Radius =============
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 13.0;
  static const double radiusCircular = 50.0;

  // ============= Border Width =============
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;

  // ============= Font Sizes =============
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeHuge = 24.0;
  static const double fontSizeDisplay = 32.0;
  static const double fontSizeTimer = 48.0;

  // ============= Text Styles =============
  static const TextStyle heading1 = TextStyle(
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: fontSizeLarge,
    color: textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: fontSizeMedium,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeSmall,
    color: textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle logo = TextStyle(
    fontSize: fontSizeDisplay,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // ============= Theme Data =============
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI',
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        displayLarge: logo,
        headlineLarge: heading1,
        headlineMedium: heading2,
        bodyLarge: body,
        bodyMedium: bodySecondary,
        bodySmall: caption,
        labelLarge: buttonText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(
            color: borderColor,
            width: borderWidthMedium,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(
            color: borderColor,
            width: borderWidthMedium,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(
            color: primaryColor,
            width: borderWidthMedium,
          ),
        ),
        labelStyle: bodySecondary,
        hintStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(vertical: spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(
            color: borderColor,
            width: borderWidthMedium,
          ),
          padding: const EdgeInsets.symmetric(vertical: spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: buttonText,
        ),
      ),
    );
  }
}

