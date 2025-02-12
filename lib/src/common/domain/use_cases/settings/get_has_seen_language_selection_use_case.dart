import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final getHasSeenLanguageSelectionUseCaseProvider = AutoDisposeProvider((ref) {
  return GetHasSeenLanguageSelection(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class GetHasSeenLanguageSelection {
  final SettingsRepository _settingsRepository;

  GetHasSeenLanguageSelection({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<bool> call() async {
    return _settingsRepository.getHasSeenLanguageSelection();
  }
}
