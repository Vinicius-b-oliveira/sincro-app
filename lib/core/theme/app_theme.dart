import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sincro/core/theme/app_colors.dart';

class AppTheme {
  static const Color _seedColor = AppColors.primary;

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.white,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          error: const Color(0xFFD32F2F), // Cor de erro consistente
          onError: AppColors.white,
        );

    final textTheme = GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme);
    return _buildThemeData(colorScheme, textTheme);
  }

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: const Color(0xFF222831),
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          error: const Color(0xFFD32F2F), // Mesma cor de erro do tema claro
          onError: AppColors.white,
        );

    final textTheme = GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme);
    return _buildThemeData(colorScheme, textTheme);
  }

  static ThemeData _buildThemeData(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final finalTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.brightness == Brightness.light
          ? const Color(0xFFF8F9FA)
          : const Color(0xFF1C2128),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
      ),
    );
    return finalTheme;
  }
}
