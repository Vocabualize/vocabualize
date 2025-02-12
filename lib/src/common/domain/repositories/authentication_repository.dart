import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';

abstract interface class AuthenticationRepository {
  Stream<AppUser?> getCurrentUser();
  Future<AuthProvider?> signInWithGithub(void Function(Uri) urlCallback);
  Future<AuthProvider?> signInWithGoogle(void Function(Uri) urlCallback);
  Future<bool> createUserWithEmailAndPassword(String email, String password);
  Future<bool> signInWithEmailAndPasswort(String email, String password);
  Future<bool> signOut();
  Future<void> sendVerificationEmail();
  Future<void> sendPasswordResetEmail(String email);
}
