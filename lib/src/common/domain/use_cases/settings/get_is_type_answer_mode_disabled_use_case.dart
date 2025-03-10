import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final getIsTypeAnswerModeDisabledUseCaseProvider = AutoDisposeFutureProvider((ref) {
  return GetIsTypeAnswerModeDisabledUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  ).call();
});

class GetIsTypeAnswerModeDisabledUseCase {
  final SettingsRepository _settingsRepository;

  const GetIsTypeAnswerModeDisabledUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<bool> call() => _settingsRepository.getIsTypeAnswerModeDisabled();
}
