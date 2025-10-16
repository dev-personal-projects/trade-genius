import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await _datasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return AuthSuccess(user);
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _datasource.signIn(email: email, password: password);
      return AuthSuccess(user);
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final user = await _datasource.signInWithGoogle();
      return AuthSuccess(user);
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }


  @override
  Future<void> signOut() async {
    await _datasource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _datasource.getCurrentUser();
  }

  @override
  Stream<User?> get authStateChanges => _datasource.authStateChanges;
}
