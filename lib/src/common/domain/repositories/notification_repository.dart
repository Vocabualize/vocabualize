import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';

abstract interface class NotificationRepository {
  void initCloudNotifications();
  Future<void> initLocalNotifications();
  void scheduleGatherNotification({required TimeOfDay time, required Language targetLanguage});
  void schedulePracticeNotification({required TimeOfDay time, int? numberOfVocabularies});
}
