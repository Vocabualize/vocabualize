import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/authentication_repository_impl.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/authentication_repository.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final signOutUseCaseProvider = AutoDisposeProvider((ref) {
  return SignOutUseCase(
    authenticationRepository: ref.watch(authenticationRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class SignOutUseCase {
  final AuthenticationRepository _authenticationRepository;
  final SettingsRepository _settingsRepository;

  const SignOutUseCase({
    required AuthenticationRepository authenticationRepository,
    required SettingsRepository settingsRepository,
  })  : _authenticationRepository = authenticationRepository,
        _settingsRepository = settingsRepository;

  Future<bool> call() async {
    return await _settingsRepository.clearLocalSettings().then((_) async {
      return await _authenticationRepository.signOut();
    });
  }
}
