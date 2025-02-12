import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';

extension AuthProviderStringMappers on String {
  AuthProvider? toAuthProvider() {
    return switch (toLowerCase()) {
      "github" => AuthProvider.github,
      "google" => AuthProvider.google,
      _ => null,
    };
  }
}
