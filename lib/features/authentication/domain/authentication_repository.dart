import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/authentication/domain/auth_user.dart';

abstract interface class AuthenticationRepository {
  Stream<AuthUser?> authStateChanges();

  Future<Result<AuthUser>> signInWithGoogle();

  Future<Result<Unit>> signOut();

  Future<Result<Unit>> deleteAccount();
}
