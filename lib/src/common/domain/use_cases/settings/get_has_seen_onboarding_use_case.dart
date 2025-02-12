import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final getHasSeenOnboardingUseCaseProvider = AutoDisposeProvider((ref) {
  return GetHasSeenOnboardingUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class GetHasSeenOnboardingUseCase {
  final SettingsRepository _settingsRepository;

  GetHasSeenOnboardingUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<bool> call() async {
    return _settingsRepository.getHasSeenOnboarding();
  }
}
