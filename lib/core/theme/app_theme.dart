import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF0FA3A3);
  static const primaryDark = Color(0xFF0B7C80);
  static const indigo = Color(0xFF4F46E5);
  static const background = Color(0xFFF4F7FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE5EAF2);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const coral = Color(0xFFF43F5E);
  static const amber = Color(0xFFF59E0B);
  static const sky = Color(0xFF0EA5E9);
  static const violet = Color(0xFF8B5CF6);
  static const green = Color(0xFF22C55E);
  static const callBackground = Color(0xFF0B1220);

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF0FA3A3), Color(0xFF1D7FD8), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

extension ColorFade on Color {
  /// Version-safe alternative to withOpacity / withValues.
  Color fade(double opacity) => withAlpha((opacity * 255).round());
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.indigo,
      surface: AppColors.surface,
      error: AppColors.coral,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.fade(0.14),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
