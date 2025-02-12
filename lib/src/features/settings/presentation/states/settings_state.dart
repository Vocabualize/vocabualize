import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';

class SettingsState {
  final AppUser? currentUser;
  final bool isKeepDataEnabled;
  final Language sourceLanguage;
  final Language targetLanguage;
  final bool areCollectionsEnabled;
  final bool areImagesDisabled;
  final bool usePremiumTranslator;
  final TimeOfDay gatherNotificationTime;
  final TimeOfDay practiceNotificationTime;
  final bool showExperimental;

  const SettingsState({
    required this.currentUser,
    required this.isKeepDataEnabled,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.areCollectionsEnabled,
    required this.areImagesDisabled,
    required this.usePremiumTranslator,
    required this.gatherNotificationTime,
    required this.practiceNotificationTime,
    this.showExperimental = false,
  });

  SettingsState copyWith({
    AppUser? currentUser,
    bool? isKeepDataEnabled,
    Language? sourceLanguage,
    Language? targetLanguage,
    bool? areCollectionsEnabled,
    bool? areImagesDisabled,
    bool? usePremiumTranslator,
    TimeOfDay? gatherNotificationTime,
    TimeOfDay? practiceNotificationTime,
    bool? showExperimental,
  }) {
    return SettingsState(
      currentUser: currentUser ?? this.currentUser,
      isKeepDataEnabled: isKeepDataEnabled ?? this.isKeepDataEnabled,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      areCollectionsEnabled: areCollectionsEnabled ?? this.areCollectionsEnabled,
      areImagesDisabled: areImagesDisabled ?? this.areImagesDisabled,
      usePremiumTranslator: usePremiumTranslator ?? this.usePremiumTranslator,
      gatherNotificationTime: gatherNotificationTime ?? this.gatherNotificationTime,
      practiceNotificationTime: practiceNotificationTime ?? this.practiceNotificationTime,
      showExperimental: showExperimental ?? this.showExperimental,
    );
  }
}
