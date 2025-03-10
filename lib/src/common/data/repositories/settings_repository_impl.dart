import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/common_constants.dart';
import 'package:vocabualize/constants/due_algorithm_constants.dart';
import 'package:vocabualize/constants/notification_constants.dart';
import 'package:vocabualize/src/common/data/data_sources/shared_preferences_data_source.dart';
import 'package:vocabualize/src/common/data/mappers/language_mappers.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider((ref) {
  return SettingsRepositoryImpl(
    sharedPreferencesDataSource: ref.watch(sharedPreferencesDataSourceProvider),
  );
});

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferencesDataSource _sharedPreferencesDataSource;

  SettingsRepositoryImpl({
    required SharedPreferencesDataSource sharedPreferencesDataSource,
  }) : _sharedPreferencesDataSource = sharedPreferencesDataSource;

  @override
  Future<bool> getHasSeenOnboarding() async {
    final hasSeenOnboarding = await _sharedPreferencesDataSource.getHasSeenOnboarding();
    return hasSeenOnboarding ?? false;
  }

  @override
  Future<void> setHasSeenOnboarding(bool hasSeenOnboarding) async {
    await _sharedPreferencesDataSource.setHasSeenOnboarding(hasSeenOnboarding);
  }

  @override
  Future<bool> getHasSeenLanguageSelection() async {
    final hasSeenLanguageSelection =
        await _sharedPreferencesDataSource.getHasSeenLanguageSelection();
    return hasSeenLanguageSelection ?? false;
  }

  @override
  Future<void> setHasSeenLanguageSelection(bool hasSeenLanguageSelection) async {
    await _sharedPreferencesDataSource.setHasSeenLanguageSelection(hasSeenLanguageSelection);
  }

  @override
  Future<Language> getSourceLanguage() async {
    final data = await _sharedPreferencesDataSource.getSourceLanguage();
    if (data == null) {
      return Language.defaultSource();
    }
    final Map<String, dynamic> json = jsonDecode(data);
    return json.toLanguage();
  }

  @override
  Future<void> setSourceLanguage(Language language) async {
    final json = language.toJson();
    final data = jsonEncode(json);
    _sharedPreferencesDataSource.setSourceLanguage(data);
  }

  @override
  Future<Language> getTargetLanguage() async {
    final data = await _sharedPreferencesDataSource.getTargetLanguage();
    if (data == null) {
      return Language.defaultTarget();
    }
    final Map<String, dynamic> json = jsonDecode(data);
    return json.toLanguage();
  }

  @override
  Future<void> setTargetLanguage(Language language) async {
    final json = language.toJson();
    final data = jsonEncode(json);
    _sharedPreferencesDataSource.setTargetLanguage(data);
  }

  @override
  Future<bool> getIsTypeAnswerModeDisabled() async {
    final isTypeAnswerModeDisabled =
        await _sharedPreferencesDataSource.getIsTypeAnswerModeDisabled();
    return isTypeAnswerModeDisabled ?? CommonConstants.isTypeAnswerModeDisabled;
  }

  @override
  Future<void> setIsTypeAnswerModeDisabled(bool isTypeAnswerModeDisabled) async {
    await _sharedPreferencesDataSource.setIsTypeAnswerModeDisabled(isTypeAnswerModeDisabled);
  }

  @override
  Future<bool> getAreCollectionsEnabled() async {
    final areCollectionsEnabled = await _sharedPreferencesDataSource.getAreCollectionsEnabled();
    return areCollectionsEnabled ?? CommonConstants.areCollectionsEnabled;
  }

  @override
  Future<void> setAreCollectionsEnabled(bool areCollectionsEnabled) async {
    await _sharedPreferencesDataSource.setAreCollectionsEnabled(areCollectionsEnabled);
  }

  @override
  Future<bool> getAreImagesDisabled() async {
    final areImagesDisabled = await _sharedPreferencesDataSource.getAreImagesDisabled();
    return areImagesDisabled ?? CommonConstants.areImagesDisabled;
  }

  @override
  Future<void> setAreImagesDisabled(bool areImagesDisabled) async {
    await _sharedPreferencesDataSource.setAreImagesDisabled(areImagesDisabled);
  }

  @override
  Future<int> getInitialInterval() async {
    final initialInterval = await _sharedPreferencesDataSource.getInitialInterval();
    return initialInterval ?? DueAlgorithmConstants.initialInterval;
  }

  @override
  Future<void> setInitialInterval(int initialInterval) async {
    _sharedPreferencesDataSource.setInitialInterval(initialInterval);
  }

  @override
  Future<int> getInitialNoviceInterval() async {
    final initialNoviceInterval = await _sharedPreferencesDataSource.getInitialNoviceInterval();
    return initialNoviceInterval ?? DueAlgorithmConstants.initialNoviceInterval;
  }

  @override
  Future<void> setInitialNoviceInterval(int initialNoviceInterval) async {
    _sharedPreferencesDataSource.setInitialNoviceInterval(initialNoviceInterval);
  }

  @override
  Future<double> getEasyIntervalMultiplicand() async {
    final easyIntervalMultiplicand =
        await _sharedPreferencesDataSource.getEasyIntervalMultiplicand();
    return easyIntervalMultiplicand ?? DueAlgorithmConstants.easyIntervalMultiplicand;
  }

  @override
  Future<void> setEasyIntervalMultiplicand(
    double easyIntervalMultiplicand,
  ) async {
    _sharedPreferencesDataSource.setEasyIntervalMultiplicand(
      easyIntervalMultiplicand,
    );
  }

  @override
  Future<double> getInitialEase() async {
    final initialEase = await _sharedPreferencesDataSource.getInitialEase();
    return initialEase ?? DueAlgorithmConstants.initialEase;
  }

  @override
  Future<void> setInitialEase(double initialEase) async {
    _sharedPreferencesDataSource.setInitialEase(initialEase);
  }

  @override
  Future<double> getEasyEaseSummand() async {
    final easeIncrease = await _sharedPreferencesDataSource.getEasyEaseSummand();
    return easeIncrease ?? DueAlgorithmConstants.easyEaseSummand;
  }

  @override
  Future<void> setEasyEaseSummand(double easyEaseSummand) async {
    _sharedPreferencesDataSource.setEasyEaseSummand(easyEaseSummand);
  }

  @override
  Future<double> getHardEaseSubtrahend() async {
    final easeDecrease = await _sharedPreferencesDataSource.getHardEaseSubtrahend();
    return easeDecrease ?? DueAlgorithmConstants.hardEaseSubrahend;
  }

  @override
  Future<void> setHardEaseSubtrahend(double hardEaseSubtrahend) async {
    _sharedPreferencesDataSource.setHardEaseSubtrahend(hardEaseSubtrahend);
  }

  @override
  Future<double> getEasyLevelSummand() async {
    final easeAnswerBonus = await _sharedPreferencesDataSource.getEasyLevelSummand();
    return easeAnswerBonus ?? DueAlgorithmConstants.easyLevelSummand;
  }

  @override
  Future<void> setEasyLevelSummand(double easyLevelSummand) async {
    _sharedPreferencesDataSource.setEasyLevelSummand(easyLevelSummand);
  }

  @override
  Future<double> getGoodLevelSummand() async {
    final goodAnswerBonus = await _sharedPreferencesDataSource.getGoodLevelSummand();
    return goodAnswerBonus ?? DueAlgorithmConstants.goodLevelSummand;
  }

  @override
  Future<void> setGoodLevelSummand(double goodLevelSummand) async {
    _sharedPreferencesDataSource.setGoodLevelSummand(goodLevelSummand);
  }

  @override
  Future<double> getHardLevelSubtrahend() async {
    final hardAnswerBonus = await _sharedPreferencesDataSource.getHardLevelSubtrahend();
    return hardAnswerBonus ?? DueAlgorithmConstants.hardLevelSubtrahend;
  }

  @override
  Future<void> setHardLevelSubtrahend(double hardLevelSubtrahend) async {
    _sharedPreferencesDataSource.setHardLevelSubtrahend(hardLevelSubtrahend);
  }

  @override
  Future<TimeOfDay> getGatherNotificationTime() async {
    final hour = await _sharedPreferencesDataSource.getGatherNotificationTimeHour();
    final minute = await _sharedPreferencesDataSource.getGatherNotificationTimeMinute();
    if (hour == null) {
      return const TimeOfDay(
        hour: NotificationConstants.gatherNotificationTimeHour,
        minute: NotificationConstants.gatherNotificationTimeMinute,
      );
    }
    if (minute == null) {
      return TimeOfDay(
        hour: hour,
        minute: NotificationConstants.gatherNotificationTimeMinute,
      );
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Future<void> setGatherNotificationTime(TimeOfDay gatherNotificationTime) async {
    _sharedPreferencesDataSource.setGatherNotificationTimeHour(gatherNotificationTime.hour);
    _sharedPreferencesDataSource.setGatherNotificationTimeMinute(gatherNotificationTime.minute);
  }

  @override
  Future<TimeOfDay> getPracticeNotificationTime() async {
    final hour = await _sharedPreferencesDataSource.getPracticeNotificationTimeHour();
    final minute = await _sharedPreferencesDataSource.getPracticeNotificationTimeMinute();
    if (hour == null) {
      return const TimeOfDay(
        hour: NotificationConstants.practiceNotificationTimeHour,
        minute: NotificationConstants.practiceNotificationTimeMinute,
      );
    }
    if (minute == null) {
      return TimeOfDay(
        hour: hour,
        minute: NotificationConstants.practiceNotificationTimeMinute,
      );
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Future<void> setPracticeNotificationTime(TimeOfDay practiceNotificationTime) async {
    _sharedPreferencesDataSource.setPracticeNotificationTimeHour(practiceNotificationTime.hour);
    _sharedPreferencesDataSource.setPracticeNotificationTimeMinute(practiceNotificationTime.minute);
  }

  @override
  Future<void> clearLocalSettings() async {
    await _sharedPreferencesDataSource.clearAllowed();
  }
}
