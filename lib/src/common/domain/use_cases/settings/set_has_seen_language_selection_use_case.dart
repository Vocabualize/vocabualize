import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final setHasSeenLanguageSelectionUseCaseProvider = AutoDisposeProvider((ref) {
  return SetHasSeenLanguageSelectionUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class SetHasSeenLanguageSelectionUseCase {
  final SettingsRepository _settingsRepository;

  SetHasSeenLanguageSelectionUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<void> call(bool hasSeenLanguageSelection) async {
    await _settingsRepository.setHasSeenLanguageSelection(hasSeenLanguageSelection);
  }
}
