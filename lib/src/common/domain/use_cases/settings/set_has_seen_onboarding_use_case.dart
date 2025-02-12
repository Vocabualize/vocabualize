import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final setHasSeenOnboardingUseCaseProvider = AutoDisposeProvider((ref) {
  return SetHasSeenOnboardingUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class SetHasSeenOnboardingUseCase {
  final SettingsRepository _settingsRepository;

  SetHasSeenOnboardingUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<void> call(bool hasSeenOnboarding) async {
    await _settingsRepository.setHasSeenOnboarding(hasSeenOnboarding);
  }
}
