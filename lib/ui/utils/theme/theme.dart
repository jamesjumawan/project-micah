import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.archivo().fontFamily,
    textTheme: GoogleFonts.archivoTextTheme().copyWith(
      // Display styles
      displayLarge: GoogleFonts.archivo(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.archivo(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.archivo(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
      // Headline styles
      headlineLarge: GoogleFonts.archivo(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.archivo(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.archivo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
      // Title styles
      titleLarge: GoogleFonts.archivo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.archivo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.archivo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
      // Body styles
      bodyLarge: GoogleFonts.archivo(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.archivo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.archivo(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
      // Label styles
      labelLarge: GoogleFonts.archivo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.archivo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.archivo(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    ),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.textWhite),
      titleTextStyle: TextStyle(
        color: AppColors.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Archivo',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.textSecondary.withValues(alpha: 0.5),
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.2),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: GoogleFonts.archivo(
        color: AppColors.textWhite,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.archivo().fontFamily,
    textTheme:
        GoogleFonts.archivoTextTheme(ThemeData.dark().textTheme).copyWith(
      // Display styles
      displayLarge: GoogleFonts.archivo(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.archivo(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.archivo(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
        letterSpacing: 0,
      ),
      // Headline styles
      headlineLarge: GoogleFonts.archivo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.archivo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.archivo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
        letterSpacing: 0,
      ),
      // Title styles
      titleLarge: GoogleFonts.archivo(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.archivo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.archivo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.1,
      ),
      // Body styles
      bodyLarge: GoogleFonts.archivo(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.archivo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textWhite,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.archivo(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textWhite,
        letterSpacing: 0.4,
      ),
      // Label styles
      labelLarge: GoogleFonts.archivo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.archivo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.archivo(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      ),
    ),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      surface: AppColors.surfaceDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surfaceDark,
      iconTheme: IconThemeData(color: AppColors.textWhite),
      titleTextStyle: TextStyle(
        color: AppColors.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Archivo',
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
