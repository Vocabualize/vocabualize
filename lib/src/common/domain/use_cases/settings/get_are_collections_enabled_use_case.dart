import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final getAreCollectionsEnabledUseCaseProvider = AutoDisposeFutureProvider((ref) {
  return GetAreCollectionsEnabledUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  ).call();
});

class GetAreCollectionsEnabledUseCase {
  final SettingsRepository _settingsRepository;

  const GetAreCollectionsEnabledUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<bool> call() => _settingsRepository.getAreCollectionsEnabled();
}
