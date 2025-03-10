import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/extensions/iterable_extensions.dart';

extension AuthProviderStringMappers on String {
  AuthProvider? toAuthProvider() {
    return AuthProvider.values.firstWhereOrNull((provider) {
      return provider?.name.toLowerCase() == toLowerCase();
    });
  }
}
