import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tradegenius/features/auth/presentation/widgets/loading_overlay.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../application/auth_controller.dart';
import '../../application/auth_state.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_auth_button.dart';

/// Login screen with email/password and Google sign-in
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    // Create dependency chain: Datasource → Repository → Controller
    final datasource = SupabaseAuthDatasource();
    final repository = AuthRepositoryImpl(datasource);
    _authController = AuthController(repository);
    _authController.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    final state = _authController.value;

    if (state is AuthAuthenticated) {
      context.go(AppRoutes.home);
    } else if (state is AuthError) {
      // Better error messages
      String errorMessage = state.message;
      if (errorMessage.contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      } else if (errorMessage.contains('Email not confirmed')) {
        errorMessage = 'Please verify your email first';
      } else if (errorMessage.contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      _authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _onGoogleSignIn() {
    _authController.signInWithGoogle();
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = _authController.value is AuthLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Welcome back text
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your trading journey',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email field
                  AuthTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  AuthTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    validator: Validators.password,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 24),
                  // Login button
                  AuthButton(
                    text: 'Sign In',
                    onPressed: _onLogin,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: theme.colorScheme.outline),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Google sign-in button
                  SocialAuthButton(
                    text: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: _onGoogleSignIn,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 24),
                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.signup),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
