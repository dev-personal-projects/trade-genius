/*
 * ═══════════════════════════════════════════════════════════════════════════
 * THEME SERVICE - Dark/Light Mode Management
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * PURPOSE: Manage app theme (dark/light mode) with persistence
 * 
 * CONCEPTS:
 * - SharedPreferences: Local storage for user preferences
 * - ValueNotifier: Reactive state management
 * - Singleton pattern: Single instance across app
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  
  ThemeService._internal() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'system';
    value = _themeModeFromString(themeName);
  }

  Future<void> setTheme(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeModeToString(mode));
  }

  ThemeMode _themeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  bool get isDarkMode => value == ThemeMode.dark;
  bool get isLightMode => value == ThemeMode.light;
  bool get isSystemMode => value == ThemeMode.system;
}
