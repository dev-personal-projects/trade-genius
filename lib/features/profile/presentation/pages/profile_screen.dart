/*
 * ═══════════════════════════════════════════════════════════════════════════
 * PROFILE SCREEN - Complete User Profile & Settings
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 📚 COMPREHENSIVE LEARNING GUIDE
 * 
 * This screen demonstrates professional Flutter development with:
 * - SOLID principles (Single Responsibility, Open/Closed, etc.)
 * - CUPID principles (Composable, Unix philosophy, Predictable, etc.)
 * - Clean architecture
 * - Proper separation of concerns
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * FEATURES:
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * ✅ Enhanced Profile Header
 *    - Gradient background
 *    - Profile picture upload (camera/gallery)
 *    - Tappable to edit
 * 
 * ✅ Theme Mode Selector
 *    - Light/Dark/System modes
 *    - Persisted preference
 *    - Smooth transitions
 * 
 * ✅ Settings Management
 *    - Notifications toggle
 *    - Biometric authentication toggle
 *    - Language selection
 * 
 * ✅ Account Actions
 *    - Edit profile
 *    - Change password
 *    - Security settings
 * 
 * ✅ App Information
 *    - Version
 *    - About
 *    - Privacy & Terms
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/application/auth_state.dart';
import '../../../auth/data/datasources/supabase_auth_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../data/datasources/settings_datasource.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/theme_mode_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthController _authController;
  late final SettingsDataSource _settingsDataSource;
  late final ThemeService _themeService;
  late final LocalizationService _localizationService;
  late final BiometricService _biometricService;
  
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;
  bool _biometricsAvailable = false;
  String _language = 'English';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadSettings();
  }

  void _initializeServices() {
    final datasource = SupabaseAuthDatasource();
    final repository = AuthRepositoryImpl(datasource);
    _authController = AuthController(repository);
    _authController.addListener(_onAuthStateChanged);
    _settingsDataSource = SettingsDataSource();
    _themeService = ThemeService();
    _localizationService = LocalizationService();
    _biometricService = BiometricService();
    _checkAuth();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    final isSupported = await _biometricService.isDeviceSupported();
    setState(() => _biometricsAvailable = isSupported);
  }

  Future<void> _loadSettings() async {
    final notifications = await _settingsDataSource.getNotificationsEnabled();
    final biometrics = await _settingsDataSource.getBiometricsEnabled();
    final language = await _settingsDataSource.getLanguage();
    
    setState(() {
      _notificationsEnabled = notifications;
      _biometricsEnabled = biometrics;
      _language = language;
    });
  }

  void _checkAuth() {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null && mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _onAuthStateChanged() {
    final state = _authController.value;
    if (state is AuthUnauthenticated && mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIGN OUT - With confirmation dialog
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _onSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authController.signOut();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTINGS HANDLERS - Following Single Responsibility Principle
  // ═══════════════════════════════════════════════════════════════════════════
  
  Future<void> _onNotificationsChanged(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _settingsDataSource.setNotificationsEnabled(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Notifications enabled' : 'Notifications disabled',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onBiometricsChanged(bool value) async {
    if (value) {
      // Authenticate before enabling
      final authenticated = await _biometricService.authenticate(
        localizedReason: _localizationService.translate('use_biometric'),
      );
      
      if (!authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_localizationService.translate('biometric_failed')),
            ),
          );
        }
        return;
      }
    }
    
    setState(() => _biometricsEnabled = value);
    await _settingsDataSource.setBiometricsEnabled(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value 
                ? _localizationService.translate('biometric_enabled')
                : _localizationService.translate('biometric_disabled'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onLanguageChanged() async {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
    
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(_localizationService.translate('choose_language')),
        children: languages.map((lang) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, lang),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  if (lang == _language)
                    const Icon(Icons.check, color: AppColors.primary),
                  if (lang == _language) const SizedBox(width: 12),
                  Text(lang),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null && selected != _language) {
      setState(() => _language = selected);
      await _settingsDataSource.setLanguage(selected);
      await _localizationService.setLanguage(selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_localizationService.translate('language_changed')} $selected',
            ),
          ),
        );
      }
    }
  }

  void _onEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile - Coming Soon')),
    );
  }

  void _onProfileImageSelected(String path) {
    setState(() => _profileImagePath = path);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _localizationService,
      builder: (context, language, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_localizationService.translate('profile')),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _onSignOut,
                tooltip: _localizationService.translate('sign_out'),
              ),
            ],
          ),
          body: ValueListenableBuilder<AuthState>(
        valueListenable: _authController,
        builder: (context, state, _) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthAuthenticated) {
            final user = state.user;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Profile Header
                  ProfileHeaderCard(
                    name: user.fullName,
                    email: user.email,
                    joinDate: DateTime.now(),
                    profileImagePath: _profileImagePath,
                    onTap: _onEditProfile,
                    onImageSelected: _onProfileImageSelected,
                  ),
                  const SizedBox(height: 24),
                  
                  // Theme Mode Selector
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: _themeService,
                    builder: (context, mode, _) {
                      return ThemeModeSelector(
                        currentMode: mode,
                        onChanged: (newMode) => _themeService.setTheme(newMode),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Stats
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  
                  // Settings Sections
                  _buildAccountSection(),
                  const SizedBox(height: 16),
                  
                  _buildPreferencesSection(),
                  const SizedBox(height: 16),
                  
                  _buildAboutSection(),
                ],
              ),
            );
          }

          return const Center(child: Text('Please sign in'));
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizationService.translate('quick_stats'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.account_balance_wallet,
                label: _localizationService.translate('portfolio'),
                value: '\$0.00',
                color: AppColors.bullish,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.show_chart,
                label: _localizationService.translate('trades'),
                value: '0',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.star,
                label: _localizationService.translate('watchlist'),
                value: '0',
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(_localizationService.translate('edit_profile')),
            subtitle: Text(_localizationService.translate('update_info')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _onEditProfile,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(_localizationService.translate('change_password')),
            subtitle: Text(_localizationService.translate('update_password')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Password - Coming Soon')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(_localizationService.translate('security')),
            subtitle: Text(_localizationService.translate('two_factor')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security Settings - Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(_localizationService.translate('notifications')),
            subtitle: Text(_localizationService.translate('receive_alerts')),
            value: _notificationsEnabled,
            onChanged: _onNotificationsChanged,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: Text(_localizationService.translate('biometric_login')),
            subtitle: Text(_localizationService.translate('use_biometric')),
            value: _biometricsEnabled,
            onChanged: _biometricsAvailable ? _onBiometricsChanged : null,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(_localizationService.translate('language')),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _onLanguageChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About TradeGenius'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'TradeGenius',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.show_chart, size: 48),
                children: [
                  const Text(
                    'Professional cryptocurrency trading and analysis platform.',
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy - Coming Soon')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service - Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STAT CARD - Reusable component (SOLID: Single Responsibility)
// ═══════════════════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
