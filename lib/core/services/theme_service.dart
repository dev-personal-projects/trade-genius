/*
 * ═══════════════════════════════════════════════════════════════════════════
 * THEME SERVICE - Advanced Dark/Light Mode with ValueNotifier
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 📚 ADVANCED STATE MANAGEMENT CONCEPTS
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🎯 ENUM STATE MANAGEMENT - Beyond Simple Types
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * This service demonstrates ValueNotifier with ENUM types (ThemeMode)
 * 
 * WHY ENUMS FOR STATE?
 * ✅ **TYPE SAFETY**: Compile-time checking prevents invalid states
 * ✅ **READABILITY**: ThemeMode.dark is clearer than 'dark' string
 * ✅ **AUTOCOMPLETE**: IDE suggests valid options
 * ✅ **REFACTORING**: Easy to rename across entire codebase
 * ✅ **EXHAUSTIVE CHECKING**: Switch statements catch missing cases
 * 
 * COMPARISON:
 * ❌ String-based: value = 'dark' (typos possible, no validation)
 * ✅ Enum-based: value = ThemeMode.dark (type-safe, validated)
 * 
 * FLUTTER'S THEMEMODE ENUM:
 * - ThemeMode.light: Always use light theme
 * - ThemeMode.dark: Always use dark theme  
 * - ThemeMode.system: Follow device system setting
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🔄 STATE SERIALIZATION - Enum to String Conversion
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * CHALLENGE: SharedPreferences only stores primitive types (String, int, bool)
 * SOLUTION: Convert enum to/from String for storage
 * 
 * SERIALIZATION PATTERN:
 * 1. Enum -> String: _themeModeToString(ThemeMode.dark) -> 'dark'
 * 2. String -> Enum: _themeModeFromString('dark') -> ThemeMode.dark
 * 
 * WHY NOT toString()?
 * ThemeMode.dark.toString() = 'ThemeMode.dark' (includes class name)
 * We want clean strings: 'dark', 'light', 'system'
 * 
 * ALTERNATIVE APPROACHES:
 * 1. JSON serialization: Overkill for simple enum
 * 2. Index-based: Fragile if enum order changes
 * 3. name property: Dart 2.17+ feature, but less readable
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🎨 COMPUTED PROPERTIES - Derived State
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * WHAT: Properties that derive their value from primary state
 * WHY: Convenient API for common checks
 * WHEN: Use for frequently accessed derived values
 * 
 * EXAMPLES IN THIS CLASS:
 * - isDarkMode: Returns true if value == ThemeMode.dark
 * - isLightMode: Returns true if value == ThemeMode.light  
 * - isSystemMode: Returns true if value == ThemeMode.system
 * 
 * BENEFITS:
 * ✅ Cleaner code: if (themeService.isDarkMode) vs if (themeService.value == ThemeMode.dark)
 * ✅ Consistent API: All boolean checks follow same pattern
 * ✅ Performance: Computed on-demand, no extra storage
 * 
 * USAGE:
 * ```dart
 * final theme = ThemeService();
 * if (theme.isDarkMode) {
 *   // Show dark-specific UI
 * }
 * ```
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 THEME SERVICE CLASS - Enum-Based State Management
// ═══════════════════════════════════════════════════════════════════════════
//
// GENERIC TYPE: ValueNotifier<ThemeMode>
// ✅ ThemeMode: Flutter's built-in enum for theme states
// ✅ Type safety: Only ThemeMode values allowed
// ✅ IDE support: Autocomplete shows enum options
// ✅ Compile-time checking: Prevents invalid assignments
//
// ENUM ADVANTAGES OVER STRINGS:
// ❌ String: value = 'darkk' (typo, runtime error)
// ✅ Enum: value = ThemeMode.dark (validated, safe)
//
class ThemeService extends ValueNotifier<ThemeMode> {
  // Singleton pattern - same as LocalizationService
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  
  // Initialize with ThemeMode.system (follow device setting)
  ThemeService._internal() : super(ThemeMode.system) {
    _loadTheme(); // Load saved preference
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'system';
    value = _themeModeFromString(themeName);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 PUBLIC API - setTheme()
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // REACTIVE UPDATE FLOW:
  // 1. value = mode: Updates ValueNotifier, triggers notifyListeners()
  // 2. All ValueListenableBuilder<ThemeMode> widgets rebuild instantly
  // 3. MaterialApp.themeMode updates, entire app theme changes
  // 4. Serialize enum to string and save to SharedPreferences
  //
  // TYPE SAFETY:
  // Parameter is ThemeMode (not String), so only valid values accepted:
  // ✅ setTheme(ThemeMode.dark)
  // ❌ setTheme('dark') // Compile error!
  //
  // USAGE EXAMPLES:
  // themeService.setTheme(ThemeMode.dark);   // Force dark mode
  // themeService.setTheme(ThemeMode.light);  // Force light mode  
  // themeService.setTheme(ThemeMode.system); // Follow system
  // ═══════════════════════════════════════════════════════════════════════════
  
  Future<void> setTheme(ThemeMode mode) async {
    value = mode; // Instant UI update across entire app!
    
    // Persist to storage (serialize enum to string)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeModeToString(mode));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 SERIALIZATION METHODS - Enum <-> String Conversion
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHY NEEDED?
  // SharedPreferences only stores primitive types (String, int, bool, double)
  // Enums must be converted to/from String for persistence
  //
  // DESERIALIZATION: String -> Enum (loading from storage)
  // ✅ Handles invalid strings gracefully (returns default)
  // ✅ Uses switch for exhaustive checking
  // ✅ Default case prevents crashes
  //
  // SERIALIZATION: Enum -> String (saving to storage)
  // ✅ Clean string representation ('dark' not 'ThemeMode.dark')
  // ✅ Consistent with deserialization
  // ✅ Human-readable in storage
  //
  // ALTERNATIVE APPROACHES:
  // 1. enum.index: Fragile if enum order changes
  // 2. enum.toString(): Includes class name 'ThemeMode.dark'
  // 3. enum.name: Dart 2.17+ feature, but less control
  // 4. JSON: Overkill for simple enum
  //
  // OUR APPROACH: Explicit, safe, readable!
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Convert stored string back to ThemeMode enum
  ThemeMode _themeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system; // Safe fallback
    }
  }

  // Convert ThemeMode enum to storage string
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 COMPUTED PROPERTIES - Convenient Boolean Getters
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHAT: Derived state computed from primary state (value)
  // WHY: Cleaner, more readable code in widgets
  // WHEN: Use for frequently checked conditions
  //
  // DART GETTER SYNTAX:
  // bool get isDarkMode => value == ThemeMode.dark;
  //   │   │      │           │
  //   │   │      │           └─ Expression (computed on access)
  //   │   │      └──────────── Property name
  //   │   └───────────────────── get keyword (computed property)
  //   └─────────────────────────── Return type
  //
  // USAGE COMPARISON:
  // ❌ Verbose: if (themeService.value == ThemeMode.dark)
  // ✅ Clean: if (themeService.isDarkMode)
  //
  // PERFORMANCE:
  // ✅ No extra storage (computed on-demand)
  // ✅ Fast comparison (enum equality is O(1))
  // ✅ No caching needed (simple boolean check)
  //
  // WIDGET USAGE:
  // ```dart
  // Widget build(BuildContext context) {
  //   final theme = ThemeService();
  //   return Container(
  //     color: theme.isDarkMode ? Colors.black : Colors.white,
  //   );
  // }
  // ```
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Convenient boolean getters for theme checking
  bool get isDarkMode => value == ThemeMode.dark;   // Force dark theme?
  bool get isLightMode => value == ThemeMode.light; // Force light theme?
  bool get isSystemMode => value == ThemeMode.system; // Follow system setting?
}
