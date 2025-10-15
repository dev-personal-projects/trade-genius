import 'package:flutter/material.dart';

class AppColors {
  // TradingView-inspired colors
  static const Color primary = Color(0xFF2962FF);
  static const Color bullish = Color(0xFF00C851);
  static const Color bearish = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFBB33);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightOnSurface = Color(0xFF131722);
  static const Color lightBorder = Color(0xFFE0E3EB);
  
  // Dark theme colors (TradingView style)
  static const Color darkBackground = Color(0xFF131722);
  static const Color darkSurface = Color(0xFF1E222D);
  static const Color darkOnSurface = Color(0xFFD1D4DC);
  static const Color darkBorder = Color(0xFF2A2E39);
  static const Color darkCard = Color(0xFF2A2E39);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        outline: AppColors.lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
      ),
    );
  }
}