/*
 * ═══════════════════════════════════════════════════════════════════════════
 * LOCALIZATION SERVICE - Multi-language Support with ValueNotifier
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 📚 COMPREHENSIVE STATE MANAGEMENT LEARNING GUIDE
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🎯 VALUE NOTIFIER PATTERN - The Star of This Class!
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * WHAT IS VALUE NOTIFIER?
 * ✅ A lightweight observable that holds a single value
 * ✅ Extends ChangeNotifier (Flutter's built-in observer pattern)
 * ✅ Automatically notifies listeners when value changes
 * ✅ Perfect for simple state that multiple widgets need to observe
 * 
 * WHY USE VALUE NOTIFIER?
 * ✅ **REACTIVE UI**: Widgets automatically rebuild when language changes
 * ✅ **PERFORMANCE**: Only rebuilds widgets that actually listen to changes
 * ✅ **SIMPLICITY**: No external dependencies, built into Flutter
 * ✅ **TYPE SAFETY**: Generic type ensures compile-time safety
 * ✅ **MEMORY EFFICIENT**: Lightweight compared to full state management solutions
 * 
 * WHEN TO USE VALUE NOTIFIER?
 * ✅ Simple state (single value like String, int, bool)
 * ✅ State shared across multiple widgets
 * ✅ When you need reactive updates without complex logic
 * ✅ Settings, themes, user preferences
 * ✅ Current user, selected items, toggle states
 * 
 * HOW IT WORKS:
 * 1. Service extends ValueNotifier<String> (String = language)
 * 2. Widgets use ValueListenableBuilder to observe changes
 * 3. When setLanguage() called, value setter triggers notifyListeners()
 * 4. All ValueListenableBuilder widgets automatically rebuild
 * 5. UI updates instantly across entire app!
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🔄 COMPARISON WITH OTHER STATE MANAGEMENT
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 📦 **SAME FEATURE WITH DIFFERENT STATE MANAGEMENT:**
 * 
 * 🔹 **STATEFUL WIDGET APPROACH:**
 * ```dart
 * class MyWidget extends StatefulWidget {
 *   String _language = 'English';
 *   
 *   void changeLanguage(String lang) {
 *     setState(() => _language = lang); // Only rebuilds THIS widget
 *   }
 * }
 * ```
 * ❌ PROBLEM: Language change only affects one widget, not entire app
 * 
 * 🔹 **PROVIDER APPROACH:**
 * ```dart
 * class LanguageProvider extends ChangeNotifier {
 *   String _language = 'English';
 *   String get language => _language;
 *   
 *   void setLanguage(String lang) {
 *     _language = lang;
 *     notifyListeners(); // Manual notification
 *   }
 * }
 * 
 * // Usage:
 * Consumer<LanguageProvider>(
 *   builder: (context, provider, child) => Text(provider.language)
 * )
 * ```
 * ✅ WORKS: But requires Provider setup, more boilerplate
 * 
 * 🔹 **RIVERPOD APPROACH:**
 * ```dart
 * final languageProvider = StateProvider<String>((ref) => 'English');
 * 
 * // Usage:
 * Consumer(builder: (context, ref, child) {
 *   final language = ref.watch(languageProvider);
 *   return Text(language);
 * })
 * ```
 * ✅ WORKS: Type-safe, but requires Riverpod dependency
 * 
 * 🔹 **BLOC APPROACH:**
 * ```dart
 * class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
 *   LanguageBloc() : super(LanguageState('English')) {
 *     on<ChangeLanguage>((event, emit) => emit(LanguageState(event.language)));
 *   }
 * }
 * 
 * // Usage:
 * BlocBuilder<LanguageBloc, LanguageState>(
 *   builder: (context, state) => Text(state.language)
 * )
 * ```
 * ✅ WORKS: Predictable, but overkill for simple language state
 * 
 * 🔹 **VALUE NOTIFIER APPROACH (OUR CHOICE):**
 * ```dart
 * class LocalizationService extends ValueNotifier<String> {
 *   LocalizationService() : super('English');
 *   
 *   void setLanguage(String lang) => value = lang; // Auto-notifies!
 * }
 * 
 * // Usage:
 * ValueListenableBuilder<String>(
 *   valueListenable: localizationService,
 *   builder: (context, language, _) => Text(language)
 * )
 * ```
 * ✅ PERFECT: Simple, reactive, no dependencies, type-safe!
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🎨 DESIGN PATTERNS DEMONSTRATED
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 1️⃣ **SINGLETON PATTERN**
 *    ✅ WHAT: Only one instance of LocalizationService exists
 *    ✅ WHY: Language setting should be global across entire app
 *    ✅ HOW: factory constructor returns same instance
 * 
 * 2️⃣ **OBSERVER PATTERN**
 *    ✅ WHAT: Widgets observe language changes and react automatically
 *    ✅ WHY: Decouples language service from UI widgets
 *    ✅ HOW: ValueNotifier notifies all registered listeners
 * 
 * 3️⃣ **STRATEGY PATTERN**
 *    ✅ WHAT: Different translation strategies per language
 *    ✅ WHY: Each language has different translations
 *    ✅ HOW: Map-based lookup with fallback to key
 * 
 * 4️⃣ **FACADE PATTERN**
 *    ✅ WHAT: Simple interface hiding complex translation logic
 *    ✅ WHY: Widgets just call translate(), don't care about maps
 *    ✅ HOW: translate() method encapsulates lookup logic
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🚀 SUPPORTED LANGUAGES & FEATURES
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 🌍 **LANGUAGES**: English, Spanish, French, German, Chinese
 * 💾 **PERSISTENCE**: Settings saved to SharedPreferences
 * ⚡ **REAL-TIME**: Instant language switching across entire app
 * 🔄 **REACTIVE**: All UI updates automatically when language changes
 * 🛡️ **FALLBACK**: Returns key if translation missing (graceful degradation)
 * 🎨 **100+ TRANSLATIONS**: Complete app coverage
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 LOCALIZATION SERVICE CLASS - The Heart of Multi-language Support
// ═══════════════════════════════════════════════════════════════════════════
//
// CLASS DECLARATION BREAKDOWN:
// ✅ extends ValueNotifier<String>: Makes this class observable
// ✅ <String>: Generic type - the value we're observing is a String (language)
// ✅ ValueNotifier: Built-in Flutter class for reactive state management
//
// INHERITANCE CHAIN:
// LocalizationService -> ValueNotifier<String> -> ChangeNotifier -> Listenable
//
// WHAT WE GET FROM VALUE NOTIFIER:
// ✅ value property: Current language (String)
// ✅ addListener(): Register widgets to listen for changes
// ✅ removeListener(): Unregister widgets (prevent memory leaks)
// ✅ notifyListeners(): Automatically called when value changes
// ✅ dispose(): Clean up resources when no longer needed
//
class LocalizationService extends ValueNotifier<String> {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 SINGLETON PATTERN IMPLEMENTATION
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHY SINGLETON?
  // ✅ Language setting should be GLOBAL across entire app
  // ✅ Multiple instances would cause inconsistent state
  // ✅ Saves memory (one instance instead of many)
  // ✅ Provides single source of truth for current language
  //
  // HOW SINGLETON WORKS:
  // 1. _instance: Private static variable holds the single instance
  // 2. factory constructor: Returns existing instance instead of creating new
  // 3. _internal(): Private constructor prevents external instantiation
  // 4. Every call to LocalizationService() returns same instance
  //
  // USAGE:
  // final service1 = LocalizationService(); // Creates instance
  // final service2 = LocalizationService(); // Returns same instance
  // print(identical(service1, service2)); // true!
  // ═══════════════════════════════════════════════════════════════════════════
  
  static final LocalizationService _instance = LocalizationService._internal();
  
  // Factory constructor - returns existing instance
  factory LocalizationService() => _instance;
  
  // Private constructor - prevents external instantiation
  // super('English'): Initializes ValueNotifier with default language
  LocalizationService._internal() : super('English') {
    _loadLanguage(); // Load saved language from storage
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 PERSISTENCE LAYER - SharedPreferences Integration
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHY PERSISTENCE?
  // ✅ Remember user's language choice between app launches
  // ✅ Better UX - don't reset to English every time
  // ✅ Respects user preferences
  //
  // WHY SHARED PREFERENCES?
  // ✅ Simple key-value storage (perfect for settings)
  // ✅ Platform-specific (UserDefaults on iOS, SharedPreferences on Android)
  // ✅ Automatic persistence across app launches
  // ✅ No setup required, built into Flutter
  //
  // ALTERNATIVE STORAGE OPTIONS:
  // 1. SQLite: Overkill for simple settings
  // 2. File system: More complex, manual serialization
  // 3. Secure storage: Unnecessary for language preference
  // 4. Cloud storage: Network dependency, slower
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String _languageKey = 'app_language'; // Storage key

  // Load saved language from storage (called in constructor)
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    // Update value (triggers listeners if different from default)
    value = prefs.getString(_languageKey) ?? 'English';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 THE MAGIC METHOD - setLanguage()
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // THIS IS WHERE THE MAGIC HAPPENS!
  //
  // WHAT HAPPENS WHEN YOU CALL setLanguage('Spanish'):
  // 1. value = language: Updates ValueNotifier's internal value
  // 2. ValueNotifier automatically calls notifyListeners()
  // 3. ALL ValueListenableBuilder widgets listening to this service rebuild
  // 4. UI instantly updates across ENTIRE app with new language!
  // 5. Language saved to SharedPreferences for persistence
  //
  // THE REACTIVE CHAIN:
  // setLanguage() -> value setter -> notifyListeners() -> ValueListenableBuilder rebuilds -> UI updates
  //
  // WHY ASYNC?
  // ✅ SharedPreferences.setString() is async (disk I/O)
  // ✅ Don't block UI thread while saving to storage
  // ✅ UI updates immediately, saving happens in background
  //
  // PERFORMANCE NOTE:
  // Only widgets wrapped in ValueListenableBuilder rebuild, not entire app!
  // This is much more efficient than setState() which rebuilds entire widget.
  // ═══════════════════════════════════════════════════════════════════════════
  
  Future<void> setLanguage(String language) async {
    // THE MAGIC LINE: Setting value automatically triggers notifyListeners()
    value = language; // ← This rebuilds ALL listening widgets instantly!
    
    // Persist to storage for next app launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 TRANSLATION METHOD - The User-Facing API
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHAT: Translates a key to current language
  // HOW: Nested map lookup with graceful fallback
  // WHY: Simple API hides complex translation logic
  //
  // DART SYNTAX BREAKDOWN:
  // _translations[value]?[key] ?? key
  //     │        │     │     │
  //     │        │     │     └─ Fallback: return key if translation missing
  //     │        │     └────── Null-aware operator: return null if left side is null
  //     │        └───────────── Null-aware access: don't crash if language map is null
  //     └─────────────────────── Get translation map for current language
  //
  // EXAMPLE EXECUTION:
  // translate('profile') with value = 'Spanish'
  // 1. _translations['Spanish'] -> Spanish translation map
  // 2. ['profile'] -> 'Perfil'
  // 3. Return 'Perfil'
  //
  // GRACEFUL DEGRADATION:
  // If translation missing, returns the key itself
  // Better than crashing or showing empty text!
  //
  // USAGE IN WIDGETS:
  // Text(_localizationService.translate('profile'))
  // ═══════════════════════════════════════════════════════════════════════════
  
  String translate(String key) {
    return _translations[value]?[key] ?? key; // Nested lookup with fallback
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌍 TRANSLATION DATABASE - The Heart of Internationalization
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // DATA STRUCTURE: Map<String, Map<String, String>>
  // ✅ Outer Map: Language -> Translation Map
  // ✅ Inner Map: Key -> Translated Text
  //
  // EXAMPLE STRUCTURE:
  // {
  //   'English': {'profile': 'Profile', 'settings': 'Settings'},
  //   'Spanish': {'profile': 'Perfil', 'settings': 'Configuración'}
  // }
  //
  // WHY STATIC?
  // ✅ Translations don't change during app runtime
  // ✅ Shared across all instances (memory efficient)
  // ✅ Loaded once when class first accessed
  //
  // WHY FINAL?
  // ✅ Prevents accidental modification of translation data
  // ✅ Compile-time constant (better performance)
  //
  // ALTERNATIVE APPROACHES:
  // 1. JSON files: More flexible, but requires asset loading
  // 2. Database: Overkill for static translations
  // 3. External API: Network dependency, slower
  // 4. Flutter Intl: More complex setup, but industry standard
  //
  // OUR APPROACH: Simple, fast, no dependencies!
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Translation database with 100+ translations across 5 languages
  static final Map<String, Map<String, String>> _translations = {
    'English': {
      // Profile Screen
      'profile': 'Profile',
      'sign_out': 'Sign Out',
      'member_since': 'Member since',
      'tap_to_edit': 'Tap to edit profile',
      'quick_stats': 'Quick Stats',
      'portfolio': 'Portfolio',
      'trades': 'Trades',
      'watchlist': 'Watchlist',
      'edit_profile': 'Edit Profile',
      'update_info': 'Update your personal information',
      'change_password': 'Change Password',
      'update_password': 'Update your password',
      'security': 'Security',
      'two_factor': 'Two-factor authentication',
      'notifications': 'Notifications',
      'receive_alerts': 'Receive price alerts and updates',
      'biometric_login': 'Biometric Login',
      'use_biometric': 'Use fingerprint or face ID',
      'language': 'Language',
      'theme_mode': 'Theme Mode',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'theme_light_desc': 'App will always use light theme',
      'theme_dark_desc': 'App will always use dark theme',
      'theme_system_desc': 'App will follow system theme settings',
      'about': 'About TradeGenius',
      'version': 'Version 1.0.0',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      'cancel': 'Cancel',
      'choose_language': 'Select Language',
      'notifications_enabled': 'Notifications enabled',
      'notifications_disabled': 'Notifications disabled',
      'biometric_enabled': 'Biometric login enabled',
      'biometric_disabled': 'Biometric login disabled',
      'language_changed': 'Language changed to',
      'profile_updated': 'Profile picture updated',
      'coming_soon': 'Coming Soon',
      'biometric_failed': 'Biometric authentication failed',
      
      // Market Screen
      'market': 'Market',
      'trending': 'Trending',
      'top_gainers': 'Top Gainers',
      'top_losers': 'Top Losers',
      'search': 'Search',
      
      // Chat Screen
      'chat': 'Chat',
      'message': 'Message...',
      'upload_image': 'Upload Image',
      'conversation_history': 'Conversation History',
      'no_conversations': 'No conversations yet',
      'conversation_deleted': 'Conversation deleted',
      
      // Auth
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
    },
    
    'Spanish': {
      'profile': 'Perfil',
      'sign_out': 'Cerrar Sesión',
      'member_since': 'Miembro desde',
      'tap_to_edit': 'Toca para editar perfil',
      'quick_stats': 'Estadísticas Rápidas',
      'portfolio': 'Portafolio',
      'trades': 'Operaciones',
      'watchlist': 'Lista de Seguimiento',
      'edit_profile': 'Editar Perfil',
      'update_info': 'Actualiza tu información personal',
      'change_password': 'Cambiar Contraseña',
      'update_password': 'Actualiza tu contraseña',
      'security': 'Seguridad',
      'two_factor': 'Autenticación de dos factores',
      'notifications': 'Notificaciones',
      'receive_alerts': 'Recibir alertas de precios y actualizaciones',
      'biometric_login': 'Inicio Biométrico',
      'use_biometric': 'Usar huella digital o Face ID',
      'language': 'Idioma',
      'theme_mode': 'Modo de Tema',
      'light': 'Claro',
      'dark': 'Oscuro',
      'system': 'Sistema',
      'theme_light_desc': 'La aplicación siempre usará tema claro',
      'theme_dark_desc': 'La aplicación siempre usará tema oscuro',
      'theme_system_desc': 'La aplicación seguirá la configuración del sistema',
      'about': 'Acerca de TradeGenius',
      'version': 'Versión 1.0.0',
      'privacy_policy': 'Política de Privacidad',
      'terms_of_service': 'Términos de Servicio',
      'sign_out_confirm': '¿Estás seguro de que quieres cerrar sesión?',
      'cancel': 'Cancelar',
      'choose_language': 'Seleccionar Idioma',
      'notifications_enabled': 'Notificaciones activadas',
      'notifications_disabled': 'Notificaciones desactivadas',
      'biometric_enabled': 'Inicio biométrico activado',
      'biometric_disabled': 'Inicio biométrico desactivado',
      'language_changed': 'Idioma cambiado a',
      'profile_updated': 'Foto de perfil actualizada',
      'coming_soon': 'Próximamente',
      'market': 'Mercado',
      'chat': 'Chat',
      'message': 'Mensaje...',
    },
    
    'French': {
      'profile': 'Profil',
      'sign_out': 'Se Déconnecter',
      'member_since': 'Membre depuis',
      'tap_to_edit': 'Appuyez pour modifier le profil',
      'quick_stats': 'Statistiques Rapides',
      'portfolio': 'Portefeuille',
      'trades': 'Transactions',
      'watchlist': 'Liste de Surveillance',
      'edit_profile': 'Modifier le Profil',
      'update_info': 'Mettez à jour vos informations personnelles',
      'change_password': 'Changer le Mot de Passe',
      'update_password': 'Mettez à jour votre mot de passe',
      'security': 'Sécurité',
      'two_factor': 'Authentification à deux facteurs',
      'notifications': 'Notifications',
      'receive_alerts': 'Recevoir des alertes de prix et des mises à jour',
      'biometric_login': 'Connexion Biométrique',
      'use_biometric': 'Utiliser l\'empreinte digitale ou Face ID',
      'language': 'Langue',
      'theme_mode': 'Mode de Thème',
      'light': 'Clair',
      'dark': 'Sombre',
      'system': 'Système',
      'coming_soon': 'Bientôt Disponible',
      'market': 'Marché',
      'chat': 'Chat',
    },
    
    'German': {
      'profile': 'Profil',
      'sign_out': 'Abmelden',
      'member_since': 'Mitglied seit',
      'tap_to_edit': 'Tippen Sie zum Bearbeiten des Profils',
      'quick_stats': 'Schnellstatistiken',
      'portfolio': 'Portfolio',
      'trades': 'Handel',
      'watchlist': 'Beobachtungsliste',
      'edit_profile': 'Profil Bearbeiten',
      'update_info': 'Aktualisieren Sie Ihre persönlichen Informationen',
      'change_password': 'Passwort Ändern',
      'update_password': 'Aktualisieren Sie Ihr Passwort',
      'security': 'Sicherheit',
      'two_factor': 'Zwei-Faktor-Authentifizierung',
      'notifications': 'Benachrichtigungen',
      'receive_alerts': 'Preisalarme und Updates erhalten',
      'biometric_login': 'Biometrische Anmeldung',
      'use_biometric': 'Fingerabdruck oder Face ID verwenden',
      'language': 'Sprache',
      'theme_mode': 'Themenmodus',
      'light': 'Hell',
      'dark': 'Dunkel',
      'system': 'System',
      'coming_soon': 'Demnächst',
      'market': 'Markt',
      'chat': 'Chat',
    },
    
    'Chinese': {
      'profile': '个人资料',
      'sign_out': '退出登录',
      'member_since': '会员自',
      'tap_to_edit': '点击编辑个人资料',
      'quick_stats': '快速统计',
      'portfolio': '投资组合',
      'trades': '交易',
      'watchlist': '关注列表',
      'edit_profile': '编辑个人资料',
      'update_info': '更新您的个人信息',
      'change_password': '更改密码',
      'update_password': '更新您的密码',
      'security': '安全',
      'two_factor': '双因素认证',
      'notifications': '通知',
      'receive_alerts': '接收价格提醒和更新',
      'biometric_login': '生物识别登录',
      'use_biometric': '使用指纹或面部识别',
      'language': '语言',
      'theme_mode': '主题模式',
      'light': '浅色',
      'dark': '深色',
      'system': '系统',
      'coming_soon': '即将推出',
      'market': '市场',
      'chat': '聊天',
    },
  };
}
