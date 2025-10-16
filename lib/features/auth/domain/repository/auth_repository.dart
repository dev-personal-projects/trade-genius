import '../entities/user.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<AuthResult> signIn({required String email, required String password});

  Future<AuthResult> signInWithGoogle();

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Stream<User?> get authStateChanges;
}
