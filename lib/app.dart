// app.dart
// Why: Central place for MaterialApp + router + theme. Keeps main.dart tiny and features decoupled.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'core/widgets/biometric_lock_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final themeService = ThemeService();
  bool _isLocked = true;
  bool _biometricsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricSettings();
  }

  Future<void> _checkBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
    
    setState(() {
      _biometricsEnabled = biometricsEnabled;
      _isLocked = biometricsEnabled;
      _isLoading = false;
    });
  }

  void _onAuthenticated() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeService,
      builder: (context, themeMode, _) {
        if (_isLocked && _biometricsEnabled) {
          return MaterialApp(
            title: 'TradeGenius',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            home: BiometricLockScreen(
              onAuthenticated: _onAuthenticated,
            ),
          );
        }

        return MaterialApp.router(
          title: 'TradeGenius',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
