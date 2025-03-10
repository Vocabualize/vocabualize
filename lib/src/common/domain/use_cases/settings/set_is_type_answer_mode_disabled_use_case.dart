import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final setIsTypeAnswerModeDisabledUseCaseProvider = AutoDisposeProvider((ref) {
  return SetIsTypeAnswerModeDisabledUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class SetIsTypeAnswerModeDisabledUseCase {
  final SettingsRepository _settingsRepository;

  const SetIsTypeAnswerModeDisabledUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<void> call(bool value) => _settingsRepository.setIsTypeAnswerModeDisabled(value);
}
