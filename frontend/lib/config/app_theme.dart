import 'package:flutter/material.dart';

/// Centralized theme configuration for the Recur app
/// All colors, text styles, and other theme-related values are defined here
/// to make them easy to modify in the future
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============= Colors =============
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFFFF6B35); // Orange/Red
  static const Color primaryLight = Color(0xFFFF8C65);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color activeColor = Color(0xFFFF6B35);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color successColor = Color(0xFF66BB6A);
  static const Color shadowColor = Color(0x1A000000);

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
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusCircular = 999.0;

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

  // ============= Shadows =============
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: shadowColor,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: shadowColor,
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.3),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ];

  // ============= Theme Data =============
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI',
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
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
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: borderColor,
            width: borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: borderColor,
            width: borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: primaryColor,
            width: borderWidthMedium,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing20,
          vertical: spacing16,
        ),
        labelStyle: bodySecondary,
        hintStyle: const TextStyle(color: textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: spacing16,
            horizontal: spacing20,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: buttonText.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: surfaceColor,
          side: const BorderSide(
            color: borderColor,
            width: borderWidthThin,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: spacing16,
            horizontal: spacing20,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: buttonText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
    );
  }
}

