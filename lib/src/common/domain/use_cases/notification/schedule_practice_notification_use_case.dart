import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/notification_repository_impl.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/notification_repository.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_vocabularies_to_practice_use_case.dart';

final schedulePracticeNotificationUseCaseProvider = AutoDisposeProvider((ref) {
  // TODO: Refactor schedulePracticeNotificationUseCaseProvider to not use getVocabulariesToPracticeUseCaseProvider (don't mix use cases)
  final vocabulariesToPractice = ref.watch(getVocabulariesToPracticeUseCaseProvider(null));
  return SchedulePracticeNotificationUseCase(
    numberOfVocabulariesToPractice: vocabulariesToPractice.length,
    notificationRepository: ref.watch(notificationRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class SchedulePracticeNotificationUseCase {
  final int _numberOfVocabulariesToPractice;
  final NotificationRepository _notificationRepository;
  final SettingsRepository _settingsRepository;

  const SchedulePracticeNotificationUseCase({
    required int numberOfVocabulariesToPractice,
    required NotificationRepository notificationRepository,
    required SettingsRepository settingsRepository,
  })  : _numberOfVocabulariesToPractice = numberOfVocabulariesToPractice,
        _notificationRepository = notificationRepository,
        _settingsRepository = settingsRepository;

  Future<void> call() async {
    // TODO: Does this even make sense? The number won't be recent (or will it?)
    final timeOfDay = await _settingsRepository.getPracticeNotificationTime();
    _notificationRepository.schedulePracticeNotification(
      time: timeOfDay,
      numberOfVocabularies: _numberOfVocabulariesToPractice,
    );
  }
}
