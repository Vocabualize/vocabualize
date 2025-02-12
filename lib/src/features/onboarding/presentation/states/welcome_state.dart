import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';

class WelcomeState {
  final Alert? latestAlert;
  final AuthProvider loadingProvider;

  const WelcomeState({
    required this.latestAlert,
    this.loadingProvider = AuthProvider.none,
  });

  WelcomeState copyWith({
    AuthProvider? loadingProvider,
  }) {
    return WelcomeState(
      latestAlert: latestAlert,
      loadingProvider: loadingProvider ?? this.loadingProvider,
    );
  }
}
