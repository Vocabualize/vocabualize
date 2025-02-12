import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';

abstract interface class SettingsRepository {
  Future<bool> getHasSeenOnboarding();
  Future<void> setHasSeenOnboarding(bool hasSeenOnboarding);

  Future<bool> getHasSeenLanguageSelection();
  Future<void> setHasSeenLanguageSelection(bool hasSeenLanguageSelection);

  Future<Language> getSourceLanguage();
  Future<void> setSourceLanguage(Language language);

  Future<Language> getTargetLanguage();
  Future<void> setTargetLanguage(Language language);

  Future<bool> getAreCollectionsEnabled();
  Future<void> setAreCollectionsEnabled(bool areCollectionsEnabled);

  Future<bool> getAreImagesDisabled();
  Future<void> setAreImagesDisabled(bool areImagesDisabled);

  Future<bool> getUsePremiumTranslator();
  Future<void> setUsePremiumTranslator(bool usePremiumTranslator);

  Future<int> getInitialInterval();
  Future<void> setInitialInterval(int initialInterval);

  Future<int> getInitialNoviceInterval();
  Future<void> setInitialNoviceInterval(int initialNoviceInterval);

  Future<double> getEasyIntervalMultiplicand();
  Future<void> setEasyIntervalMultiplicand(double easyIntervalMultiplicand);

  Future<double> getInitialEase();
  Future<void> setInitialEase(double initialEase);

  Future<double> getEasyEaseSummand();
  Future<void> setEasyEaseSummand(double easyEaseSummand);

  Future<double> getHardEaseSubtrahend();
  Future<void> setHardEaseSubtrahend(double hardEaseSubtrahend);

  Future<double> getEasyLevelSummand();
  Future<void> setEasyLevelSummand(double easyLevelSummand);

  Future<double> getGoodLevelSummand();
  Future<void> setGoodLevelSummand(double goodLevelSummand);

  Future<double> getHardLevelSubtrahend();
  Future<void> setHardLevelSubtrahend(double hardLevelSubtrahend);

  Future<TimeOfDay> getGatherNotificationTime();
  Future<void> setGatherNotificationTime(TimeOfDay gatherNotificationTime);

  Future<TimeOfDay> getPracticeNotificationTime();
  Future<void> setPracticeNotificationTime(TimeOfDay practiceNotificationTime);

  Future<void> clearLocalSettings();
}
