import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';

class AuthFromAnonymousState {
  final AuthProvider loadingProvider;

  const AuthFromAnonymousState({
    this.loadingProvider = AuthProvider.none,
  });

  AuthFromAnonymousState copyWith({
    AuthProvider? loadingProvider,
  }) {
    return AuthFromAnonymousState(
      loadingProvider: loadingProvider ?? this.loadingProvider,
    );
  }
}