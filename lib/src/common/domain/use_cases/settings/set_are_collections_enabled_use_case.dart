import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final setAreCollectionsEnabledUseCaseProvider = AutoDisposeProvider((ref) {
  return SetAreCollectionsEnabledUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class SetAreCollectionsEnabledUseCase {
  final SettingsRepository _settingsRepository;

  const SetAreCollectionsEnabledUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<void> call(bool value) => _settingsRepository.setAreCollectionsEnabled(value);
}
