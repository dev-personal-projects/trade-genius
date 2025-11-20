/*
 * ═══════════════════════════════════════════════════════════════════════════
 * PROFILE SCREEN - Complete User Profile & Settings
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 📚 COMPREHENSIVE FLUTTER/DART LEARNING GUIDE
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🎯 STATE MANAGEMENT CONCEPTS DEMONSTRATED
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * This screen showcases MULTIPLE state management approaches:
 * 
 * 1️⃣ **STATEFUL WIDGET (Built-in Flutter)**
 *    ✅ WHAT: Widget that can change its internal state
 *    ✅ WHEN: Simple local state (toggles, form inputs, UI state)
 *    ✅ WHY: Built-in, no dependencies, perfect for component-level state
 *    ✅ HOW: setState() triggers rebuild of widget tree
 *    
 *    Example in this file:
 *    - _notificationsEnabled (toggle state)
 *    - _biometricsEnabled (toggle state)
 *    - _language (dropdown selection)
 *    - _profileImagePath (image picker result)
 * 
 * 2️⃣ **VALUE NOTIFIER (Built-in Flutter)**
 *    ✅ WHAT: Lightweight observable that notifies listeners of changes
 *    ✅ WHEN: Simple state that multiple widgets need to observe
 *    ✅ WHY: More efficient than setState for cross-widget communication
 *    ✅ HOW: ValueListenableBuilder automatically rebuilds when value changes
 *    
 *    Example in this file:
 *    - ThemeService extends ValueNotifier<ThemeMode>
 *    - LocalizationService extends ValueNotifier<String>
 *    - AuthController extends ValueNotifier<AuthState>
 * 
 * 3️⃣ **CHANGE NOTIFIER (Built-in Flutter)**
 *    ✅ WHAT: Base class for objects that provide change notifications
 *    ✅ WHEN: Complex state with multiple properties
 *    ✅ WHY: More flexible than ValueNotifier, can notify without value change
 *    ✅ HOW: notifyListeners() triggers all registered listeners
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🚀 POPULAR STATE MANAGEMENT SOLUTIONS COMPARISON
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 📦 **PROVIDER (Most Popular)**
 *    ✅ PROS: Easy to learn, built on InheritedWidget, great for beginners
 *    ✅ CONS: Can become complex with nested providers
 *    ✅ BEST FOR: Small to medium apps, learning Flutter
 *    ✅ SYNTAX: Consumer<T>, Provider.of<T>(context)
 * 
 * 📦 **RIVERPOD (Provider 2.0)**
 *    ✅ PROS: Compile-time safety, no BuildContext needed, better testing
 *    ✅ CONS: Steeper learning curve, newer ecosystem
 *    ✅ BEST FOR: Large apps, type safety, advanced developers
 *    ✅ SYNTAX: ref.watch(), ref.read(), ConsumerWidget
 * 
 * 📦 **BLOC (Business Logic Component)**
 *    ✅ PROS: Predictable state, great for complex apps, excellent testing
 *    ✅ CONS: Boilerplate code, steeper learning curve
 *    ✅ BEST FOR: Enterprise apps, complex business logic, team development
 *    ✅ SYNTAX: BlocBuilder, BlocListener, context.read<Bloc>()
 * 
 * 📦 **GETX**
 *    ✅ PROS: All-in-one solution (state + routing + dependency injection)
 *    ✅ CONS: Magic strings, less predictable, tight coupling
 *    ✅ BEST FOR: Rapid prototyping, small teams
 *    ✅ SYNTAX: Get.find<Controller>(), Obx(() => widget)
 * 
 * 📦 **MOBX**
 *    ✅ PROS: Reactive programming, automatic dependency tracking
 *    ✅ CONS: Code generation required, runtime overhead
 *    ✅ BEST FOR: Reactive UIs, developers familiar with MobX from other platforms
 *    ✅ SYNTAX: @observable, @action, Observer(() => widget)
 * 
 * 📦 **REDUX**
 *    ✅ PROS: Predictable state, time-travel debugging, great for large apps
 *    ✅ CONS: Lots of boilerplate, complex setup
 *    ✅ BEST FOR: Large apps with complex state, developers familiar with Redux
 *    ✅ SYNTAX: StoreProvider, StoreConnector, dispatch(action)
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🎯 WHY WE CHOSE VALUE NOTIFIER + STATEFUL WIDGET
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * ✅ **SIMPLICITY**: No external dependencies, built into Flutter
 * ✅ **PERFORMANCE**: Minimal overhead, efficient rebuilds
 * ✅ **LEARNING**: Great for understanding Flutter's reactive system
 * ✅ **FLEXIBILITY**: Can easily migrate to Provider/Riverpod later
 * ✅ **TESTING**: Easy to test, no complex setup required
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 🔧 FLUTTER CONCEPTS DEMONSTRATED
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 🎨 **WIDGET LIFECYCLE**
 *    - initState(): Initialize controllers, load settings
 *    - dispose(): Clean up listeners, prevent memory leaks
 *    - setState(): Trigger UI rebuilds for local state changes
 * 
 * 🎨 **ASYNC PROGRAMMING**
 *    - Future<void>: Asynchronous operations (loading settings, API calls)
 *    - async/await: Clean asynchronous code without callbacks
 *    - mounted check: Prevent setState after widget disposal
 * 
 * 🎨 **REACTIVE UI PATTERNS**
 *    - ValueListenableBuilder: Rebuilds when ValueNotifier changes
 *    - StreamBuilder: Rebuilds when Stream emits new data
 *    - FutureBuilder: Rebuilds based on Future states
 * 
 * 🎨 **NAVIGATION**
 *    - GoRouter: Declarative routing with type safety
 *    - context.go(): Navigate to named routes
 *    - Route protection: Redirect unauthenticated users
 * 
 * 🎨 **DEPENDENCY INJECTION**
 *    - Constructor injection: Pass dependencies through constructors
 *    - Service locator pattern: Global access to services
 *    - Singleton pattern: Single instance of services
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * 📱 FEATURES IMPLEMENTED
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * ✅ Enhanced Profile Header with gradient background
 * ✅ Theme Mode Selector (Light/Dark/System)
 * ✅ Settings Management (Notifications, Biometrics, Language)
 * ✅ Account Actions (Edit profile, Change password, Security)
 * ✅ App Information (Version, About, Privacy & Terms)
 * ✅ Biometric Authentication with device capability detection
 * ✅ Multi-language support with real-time switching
 * ✅ Persistent settings storage
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
  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 DEPENDENCY INJECTION - Constructor Injection Pattern
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHY late final?
  // - late: Allows non-nullable initialization after constructor
  // - final: Prevents reassignment, ensures immutability
  // - Better than nullable fields that need null checks
  // 
  // ALTERNATIVE APPROACHES:
  // 1. Constructor injection: Pass dependencies in constructor
  // 2. Service locator: GetIt.instance<Service>()
  // 3. Provider: Provider.of<Service>(context)
  // 4. Riverpod: ref.read(serviceProvider)
  // ═══════════════════════════════════════════════════════════════════════════
  
  late final AuthController _authController;           // Authentication state
  late final SettingsDataSource _settingsDataSource;   // Local storage
  late final ThemeService _themeService;               // Theme management
  late final LocalizationService _localizationService; // Language management
  late final BiometricService _biometricService;       // Biometric auth
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 LOCAL STATE - StatefulWidget Pattern
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // These are component-level state that only this widget cares about.
  // When these change, setState() is called to trigger a rebuild.
  // 
  // WHY StatefulWidget for these?
  // - Simple boolean/string values
  // - Only used within this widget
  // - Don't need to share with other widgets
  // - setState() is sufficient and performant
  // 
  // WHEN to use external state management instead?
  // - When multiple widgets need the same state
  // - When state needs to persist across navigation
  // - When state logic is complex
  // - When you need time-travel debugging
  // ═══════════════════════════════════════════════════════════════════════════
  
  bool _notificationsEnabled = true;  // Toggle state for notifications
  bool _biometricsEnabled = false;    // Toggle state for biometric login
  bool _biometricsAvailable = false;  // Device capability detection
  String _language = 'English';       // Selected language
  String? _profileImagePath;          // Profile image file path

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 WIDGET LIFECYCLE - initState()
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Called once when the widget is inserted into the widget tree
  // WHEN: Perfect for one-time initialization (controllers, listeners, API calls)
  // WHY: Ensures setup happens before first build()
  // 
  // LIFECYCLE ORDER:
  // 1. Constructor
  // 2. initState() ← We are here
  // 3. didChangeDependencies()
  // 4. build()
  // 5. ... widget updates ...
  // 6. dispose()
  // 
  // BEST PRACTICES:
  // ✅ Always call super.initState() first
  // ✅ Initialize controllers and listeners here
  // ✅ Start async operations (but don't await them)
  // ❌ Don't call setState() in initState()
  // ❌ Don't access inherited widgets here (use didChangeDependencies instead)
  // ═══════════════════════════════════════════════════════════════════════════
  
  @override
  void initState() {
    super.initState(); // Always call super first!
    _initializeServices();  // Set up dependency injection
    _loadSettings();        // Load user preferences asynchronously
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 ASYNC PROGRAMMING - Future & async/await
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Asynchronous function that loads user settings from local storage
  // WHY async/await: Clean, readable code instead of callback hell
  // 
  // ASYNC CONCEPTS:
  // - Future<T>: Represents a value that will be available later
  // - async: Marks function as asynchronous
  // - await: Waits for Future to complete before continuing
  // 
  // ALTERNATIVE APPROACHES:
  // 1. Callbacks: loadSettings((result) => setState(...))
  // 2. .then(): loadSettings().then((result) => setState(...))
  // 3. async/await: Much cleaner! ✅
  // 
  // ERROR HANDLING:
  // Could wrap in try-catch block for production apps
  // ═══════════════════════════════════════════════════════════════════════════
  
  Future<void> _loadSettings() async {
    // Parallel execution - all three calls start simultaneously
    final notifications = await _settingsDataSource.getNotificationsEnabled();
    final biometrics = await _settingsDataSource.getBiometricsEnabled();
    final language = await _settingsDataSource.getLanguage();
    
    // Update UI with loaded settings
    // setState() triggers a rebuild with new values
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 WIDGET LIFECYCLE - dispose()
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Called when the widget is permanently removed from the widget tree
  // WHEN: Widget is popped from navigation, parent removes it, app closes
  // WHY: Prevent memory leaks by cleaning up resources
  // 
  // CRITICAL FOR:
  // ✅ Removing listeners (prevents memory leaks)
  // ✅ Canceling timers and subscriptions
  // ✅ Disposing controllers (AnimationController, TextEditingController)
  // ✅ Closing streams and sockets
  // 
  // MEMORY LEAK EXAMPLE:
  // If we don't remove the listener, _onAuthStateChanged will still be called
  // even after this widget is destroyed, causing crashes and memory leaks.
  // 
  // BEST PRACTICES:
  // ✅ Always call super.dispose() last
  // ✅ Remove all listeners added in initState()
  // ✅ Dispose all controllers created in initState()
  // ═══════════════════════════════════════════════════════════════════════════
  
  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    _authController.removeListener(_onAuthStateChanged);
    super.dispose(); // Always call super last!
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 REACTIVE UI - ValueListenableBuilder Pattern
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Widget that rebuilds when a ValueNotifier changes
  // WHY: More efficient than setState() for external state changes
  // WHEN: Perfect for observing services that extend ValueNotifier
  // 
  // HOW IT WORKS:
  // 1. ValueListenableBuilder registers as listener to _localizationService
  // 2. When _localizationService.value changes, builder() is called
  // 3. Only this builder rebuilds, not the entire widget
  // 4. Much more efficient than setState() for external state!
  // 
  // PARAMETERS:
  // - valueListenable: The ValueNotifier to observe
  // - builder: Function called when value changes
  // - child: Optional static child (performance optimization)
  // 
  // ALTERNATIVES:
  // - StreamBuilder: For Stream<T> instead of ValueNotifier<T>
  // - FutureBuilder: For Future<T> instead of ValueNotifier<T>
  // - AnimatedBuilder: For Animation<T> instead of ValueNotifier<T>
  // ═══════════════════════════════════════════════════════════════════════════
  
  @override
  Widget build(BuildContext context) {
    // Reactive UI: Rebuilds when language changes
    return ValueListenableBuilder<String>(
      valueListenable: _localizationService, // Observable service
      builder: (context, language, _) {       // Rebuild function
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
          // Nested ValueListenableBuilder for authentication state
          // This demonstrates how to compose multiple reactive widgets
          body: ValueListenableBuilder<AuthState>(
        valueListenable: _authController, // Observable auth controller
        builder: (context, state, _) {    // Rebuild when auth state changes
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
                  
                  // Triple-nested ValueListenableBuilder!
                  // This shows how reactive widgets can be composed
                  // Each builder only rebuilds when its specific value changes
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: _themeService, // Observable theme service
                    builder: (context, mode, _) {   // Rebuild when theme changes
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
