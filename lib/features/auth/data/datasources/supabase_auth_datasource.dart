import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/user.dart' as domain;

class SupabaseAuthDatasource {
  final SupabaseClient _client = SupabaseService.client;

  Future<domain.User> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user == null) {
      throw Exception('Sign up failed');
    }

    await _createProfile(
      userId: response.user!.id,
      email: email,
      fullName: fullName,
    );

    return _mapToUser(response.user!, fullName);
  }

  Future<domain.User> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed');
    }

    final profile = await _getProfile(response.user!.id);
    return _mapToUser(response.user!, profile['full_name'] ?? '');
  }

Future<domain.User> signInWithGoogle() async {
  try {
    // Use Supabase native OAuth with proper redirect
    final response = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.tradegenius://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    if (!response) {
      throw Exception('Google sign in cancelled');
    }

    // Listen to auth state changes instead of waiting
    final completer = Completer<domain.User>();
    
    final subscription = _client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        final user = session.user;
        final fullName = user.userMetadata?['full_name'] ?? 
                         user.userMetadata?['name'] ?? 
                         user.email?.split('@')[0] ?? '';

        _createProfile(
          userId: user.id,
          email: user.email ?? '',
          fullName: fullName,
        ).then((_) {
          if (!completer.isCompleted) {
            completer.complete(_mapToUser(user, fullName));
          }
        });
      }
    });

    // Timeout after 30 seconds
    return await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        subscription.cancel();
        throw Exception('Google sign in timeout');
      },
    ).whenComplete(() => subscription.cancel());
  } catch (e) {
    throw Exception('Google sign in error: $e');
  }
}

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<domain.User?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final profile = await _getProfile(user.id);
    return _mapToUser(user, profile['full_name'] ?? '');
  }

  Stream<domain.User?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((state) async {
      final user = state.session?.user;
      if (user == null) return null;

      final profile = await _getProfile(user.id);
      return _mapToUser(user, profile['full_name'] ?? '');
    });
  }

  Future<void> _createProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  domain.User _mapToUser(User supabaseUser, String fullName) {
    return domain.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: fullName,
    );
  }
}
