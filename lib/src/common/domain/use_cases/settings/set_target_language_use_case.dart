import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/data/repositories/user_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';
import 'package:vocabualize/src/common/domain/repositories/user_repository.dart';

final setTargetLanguageUseCaseProvider = AutoDisposeProvider.family((ref, Language language) {
  return SetTargetLanguageUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  ).call(language);
});

class SetTargetLanguageUseCase {
  final SettingsRepository _settingsRepository;
  final UserRepository _userRepository;

  const SetTargetLanguageUseCase({
    required SettingsRepository settingsRepository,
    required UserRepository userRepository,
  })  : _settingsRepository = settingsRepository,
        _userRepository = userRepository;

  Future<void> call(Language language) async {
    final user = await _userRepository.getUser();
    user?.let((u) {
      _userRepository.updateUser(u.copyWith(targetLanguageId: language.id));
    });
    await _settingsRepository.setTargetLanguage(language);
  }
}
