import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final getAreImagesDisabledUseCaseProvider = AutoDisposeFutureProvider((ref) {
  return GetAreImagesDisabledUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  ).call();
});

class GetAreImagesDisabledUseCase {
  final SettingsRepository _settingsRepository;

  const GetAreImagesDisabledUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<bool> call() => _settingsRepository.getAreImagesDisabled();
}
