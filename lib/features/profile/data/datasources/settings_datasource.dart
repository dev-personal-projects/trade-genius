/*
 * ═══════════════════════════════════════════════════════════════════════════
 * SETTINGS DATASOURCE - Local Settings Storage
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * PURPOSE: Save and load user settings from local storage
 * 
 * CONCEPTS:
 * - SharedPreferences: Key-value storage
 * - Async operations: Non-blocking I/O
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:shared_preferences/shared_preferences.dart';

class SettingsDataSource {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricsKey = 'biometrics_enabled';
  static const String _languageKey = 'language';

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<bool> getBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricsKey) ?? false;
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsKey, enabled);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
}
