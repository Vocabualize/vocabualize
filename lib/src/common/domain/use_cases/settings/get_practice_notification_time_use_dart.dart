import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final getPracticeNotificationTimeUseCaseProvider = AutoDisposeProvider((ref) {
  return GetPracticeNotificationTimeUseDart(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  ).call();
});

class GetPracticeNotificationTimeUseDart {
  final SettingsRepository _settingsRepository;

  const GetPracticeNotificationTimeUseDart({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<TimeOfDay> call() => _settingsRepository.getPracticeNotificationTime();
}
