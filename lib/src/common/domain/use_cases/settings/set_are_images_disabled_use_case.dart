import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final setAreImagesDisabledUseCaseProvider = AutoDisposeFutureProvider.family((ref, bool value) {
  return SetAreImagesDisabledUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  ).call(value);
});

class SetAreImagesDisabledUseCase {
  final SettingsRepository _settingsRepository;

  const SetAreImagesDisabledUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<void> call(bool value) => _settingsRepository.setAreImagesDisabled(value);
}
