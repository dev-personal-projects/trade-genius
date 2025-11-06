/*
 * ═══════════════════════════════════════════════════════════════════════════
 * LOCALIZATION SERVICE - Multi-language Support
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * PURPOSE: Manage app language and translations
 * 
 * CONCEPTS:
 * - Internationalization (i18n): Supporting multiple languages
 * - ValueNotifier: Reactive state for language changes
 * - Map-based translations: Simple translation system
 * 
 * SUPPORTED LANGUAGES:
 * - English
 * - Spanish
 * - French
 * - German
 * - Chinese
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ValueNotifier<String> {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  
  LocalizationService._internal() : super('English') {
    _loadLanguage();
  }

  static const String _languageKey = 'app_language';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_languageKey) ?? 'English';
  }

  Future<void> setLanguage(String language) async {
    value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  String translate(String key) {
    return _translations[value]?[key] ?? key;
  }

  // Translation map
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
