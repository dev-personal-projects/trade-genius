import 'package:flutter/material.dart';
import '../domain/entities/auth_result.dart';
import '../domain/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthController extends ValueNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = await _repository.getCurrentUser();
    value = user != null
        ? AuthAuthenticated(user)
        : const AuthUnauthenticated();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    value = const AuthLoading();

    final result = await _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    switch (result) {
      case AuthSuccess(:final user):
        value = AuthAuthenticated(user);
      case AuthFailure(:final message):
        value = AuthError(message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    value = const AuthLoading();

    final result = await _repository.signIn(email: email, password: password);

    switch (result) {
      case AuthSuccess(:final user):
        value = AuthAuthenticated(user);
      case AuthFailure(:final message):
        value = AuthError(message);
    }
  }

  Future<void> signInWithGoogle() async {
    value = const AuthLoading();

    final result = await _repository.signInWithGoogle();

    switch (result) {
      case AuthSuccess(:final user):
        value = AuthAuthenticated(user);
      case AuthFailure(:final message):
        value = AuthError(message);
    }
  }

  Future<void> signInWithBiometric() async {
  value = const AuthLoading();

  final result = await _repository.signInWithGoogle();

  switch (result) {
    case AuthSuccess(:final user):
      value = AuthAuthenticated(user);
    case AuthFailure(:final message):
      value = AuthError(message);
  }
}


  Future<void> signOut() async {
    await _repository.signOut();
    value = const AuthUnauthenticated();
  }
}
