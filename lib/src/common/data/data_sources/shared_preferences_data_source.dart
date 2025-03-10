import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _sharedPreferencesProvider = Provider((ref) => SharedPreferencesAsync());

final sharedPreferencesDataSourceProvider = Provider((ref) {
  return SharedPreferencesDataSource(
    sharedPreferences: ref.watch(_sharedPreferencesProvider),
  );
});

class SharedPreferencesDataSource {
  final SharedPreferencesAsync _sharedPreferences;

  const SharedPreferencesDataSource({
    required SharedPreferencesAsync sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final String _hasSeenOnboardingKey = "key.has.seen.onboarding";
  final String _hasSeenLanguageSelectionKey = "key.has.seen.language.selection";
  final String _sourceLanguageCodeKey = "key.source.language.code";
  final String _targetLanguageCodeKey = "key.target.language.code";
  final String _isTypeAnswerModeDisabledKey = "key.is.type.answer.mode.disabled";
  final String _areCollectionsEnabledKey = "key.are.collections.enabled";
  final String _areImagesDisabledKey = "key.are.images.disabled";
  final String _initialIntervalKey = "key.initial.interval";
  final String _initialNoviceIntervalKey = "key.initial.novice.interval";
  final String _initialEaseKey = "key.initial.ease";
  final String _easyEaseSummandKey = "key.easy.ease.summand";
  final String _hardEaseSubtrahendKey = "key.hard.ease.subtrahend";
  final String _easyIntervalMultiplicand = "key.easy.interval.multiplicand";
  final String _easyLevelSummandKey = "key.easy.level.summand";
  final String _goodLevelSummandKey = "key.good.level.summand";
  final String _hardLevelSubtrahendKey = "key.hard.level.subtrahend";
  final String _gatherNotificationTimeHourKey = "key.gather.notification.time.hour";
  final String _gatherNotificationTimeMinuteKey = "key.gather.notification.time.minute";
  final String _practiceNotificationTimeHourKey = "key.practice.notification.time.hour";
  final String _practiceNotificationTimeMinuteKey = "key.practice.notification.time.minute";

  Future<bool?> getHasSeenOnboarding() async {
    return await _sharedPreferences.getBool(_hasSeenOnboardingKey);
  }

  Future<void> setHasSeenOnboarding(bool hasSeenOnboarding) async {
    return await _sharedPreferences.setBool(
      _hasSeenOnboardingKey,
      hasSeenOnboarding,
    );
  }

  Future<bool?> getHasSeenLanguageSelection() async {
    return await _sharedPreferences.getBool(_hasSeenLanguageSelectionKey);
  }

  Future<void> setHasSeenLanguageSelection(bool hasSeenLanguageSelection) async {
    return await _sharedPreferences.setBool(
      _hasSeenLanguageSelectionKey,
      hasSeenLanguageSelection,
    );
  }

  Future<String?> getSourceLanguage() {
    return _sharedPreferences.getString(_sourceLanguageCodeKey);
  }

  Future<void> setSourceLanguage(String sourceLanguageCode) {
    return _sharedPreferences.setString(
      _sourceLanguageCodeKey,
      sourceLanguageCode,
    );
  }

  Future<String?> getTargetLanguage() {
    return _sharedPreferences.getString(_targetLanguageCodeKey);
  }

  Future<void> setTargetLanguage(String targetLanguageCode) {
    return _sharedPreferences.setString(
      _targetLanguageCodeKey,
      targetLanguageCode,
    );
  }

  Future<bool?> getIsTypeAnswerModeDisabled() async {
    return await _sharedPreferences.getBool(_isTypeAnswerModeDisabledKey);
  }

  Future<void> setIsTypeAnswerModeDisabled(bool isTypeAnswerModeDisabled) async {
    return await _sharedPreferences.setBool(
      _isTypeAnswerModeDisabledKey,
      isTypeAnswerModeDisabled,
    );
  }

  Future<bool?> getAreCollectionsEnabled() async {
    return await _sharedPreferences.getBool(_areCollectionsEnabledKey);
  }

  Future<void> setAreCollectionsEnabled(bool areCollectionsEnabled) async {
    return await _sharedPreferences.setBool(
      _areCollectionsEnabledKey,
      areCollectionsEnabled,
    );
  }

  Future<bool?> getAreImagesDisabled() async {
    return await _sharedPreferences.getBool(_areImagesDisabledKey);
  }

  Future<void> setAreImagesDisabled(bool areImagesDisabled) async {
    return await _sharedPreferences.setBool(
      _areImagesDisabledKey,
      areImagesDisabled,
    );
  }

  Future<int?> getInitialInterval() {
    return _sharedPreferences.getInt(_initialIntervalKey);
  }

  Future<void> setInitialInterval(int initialInterval) {
    return _sharedPreferences.setInt(
      _initialIntervalKey,
      initialInterval,
    );
  }

  Future<int?> getInitialNoviceInterval() {
    return _sharedPreferences.getInt(_initialNoviceIntervalKey);
  }

  Future<void> setInitialNoviceInterval(int initialNoviceInterval) {
    return _sharedPreferences.setInt(
      _initialNoviceIntervalKey,
      initialNoviceInterval,
    );
  }

  Future<double?> getEasyIntervalMultiplicand() {
    return _sharedPreferences.getDouble(_easyIntervalMultiplicand);
  }

  Future<void> setEasyIntervalMultiplicand(double easyIntervalMultiplicand) {
    return _sharedPreferences.setDouble(
      _easyIntervalMultiplicand,
      easyIntervalMultiplicand,
    );
  }

  Future<double?> getInitialEase() {
    return _sharedPreferences.getDouble(_initialEaseKey);
  }

  Future<void> setInitialEase(double initialEase) {
    return _sharedPreferences.setDouble(
      _initialEaseKey,
      initialEase,
    );
  }

  Future<double?> getEasyEaseSummand() {
    return _sharedPreferences.getDouble(_easyEaseSummandKey);
  }

  Future<void> setEasyEaseSummand(double easyEaseSummand) {
    return _sharedPreferences.setDouble(
      _easyEaseSummandKey,
      easyEaseSummand,
    );
  }

  Future<double?> getHardEaseSubtrahend() {
    return _sharedPreferences.getDouble(_hardEaseSubtrahendKey);
  }

  Future<void> setHardEaseSubtrahend(double hardEaseSubtrahend) {
    return _sharedPreferences.setDouble(
      _hardEaseSubtrahendKey,
      hardEaseSubtrahend,
    );
  }

  Future<double?> getEasyLevelSummand() {
    return _sharedPreferences.getDouble(_easyLevelSummandKey);
  }

  Future<void> setEasyLevelSummand(double easyLevelSummand) {
    return _sharedPreferences.setDouble(
      _easyLevelSummandKey,
      easyLevelSummand,
    );
  }

  Future<double?> getGoodLevelSummand() {
    return _sharedPreferences.getDouble(_goodLevelSummandKey);
  }

  Future<void> setGoodLevelSummand(double goodLevelSummand) {
    return _sharedPreferences.setDouble(
      _goodLevelSummandKey,
      goodLevelSummand,
    );
  }

  Future<double?> getHardLevelSubtrahend() {
    return _sharedPreferences.getDouble(_hardLevelSubtrahendKey);
  }

  Future<void> setHardLevelSubtrahend(double setHardLevelSubtrahend) {
    return _sharedPreferences.setDouble(
      _hardLevelSubtrahendKey,
      setHardLevelSubtrahend,
    );
  }

  Future<int?> getGatherNotificationTimeHour() {
    return _sharedPreferences.getInt(_gatherNotificationTimeHourKey);
  }

  Future<void> setGatherNotificationTimeHour(int gatherNotificationTimeHour) {
    return _sharedPreferences.setInt(
      _gatherNotificationTimeHourKey,
      gatherNotificationTimeHour,
    );
  }

  Future<int?> getGatherNotificationTimeMinute() {
    return _sharedPreferences.getInt(_gatherNotificationTimeMinuteKey);
  }

  Future<void> setGatherNotificationTimeMinute(int gatherNotificationTimeMinute) {
    return _sharedPreferences.setInt(
      _gatherNotificationTimeMinuteKey,
      gatherNotificationTimeMinute,
    );
  }

  Future<int?> getPracticeNotificationTimeHour() {
    return _sharedPreferences.getInt(_practiceNotificationTimeHourKey);
  }

  Future<void> setPracticeNotificationTimeHour(int practiceNotificationTimeHour) {
    return _sharedPreferences.setInt(
      _practiceNotificationTimeHourKey,
      practiceNotificationTimeHour,
    );
  }

  Future<int?> getPracticeNotificationTimeMinute() {
    return _sharedPreferences.getInt(_practiceNotificationTimeMinuteKey);
  }

  Future<void> setPracticeNotificationTimeMinute(int practiceNotificationTimeMinute) {
    return _sharedPreferences.setInt(
      _practiceNotificationTimeMinuteKey,
      practiceNotificationTimeMinute,
    );
  }

  Future<void> clearAllowed() async {
    final allowList = {
      // * _hasSeenOnboardingKey,
      _hasSeenLanguageSelectionKey,
      _sourceLanguageCodeKey,
      _isTypeAnswerModeDisabledKey,
      _targetLanguageCodeKey,
      _areCollectionsEnabledKey,
      _areImagesDisabledKey,
      _initialIntervalKey,
      _initialNoviceIntervalKey,
      _initialEaseKey,
      _easyEaseSummandKey,
      _hardEaseSubtrahendKey,
      _easyIntervalMultiplicand,
      _easyLevelSummandKey,
      _goodLevelSummandKey,
      _hardLevelSubtrahendKey,
      // * _gatherNotificationTimeHourKey,
      // * _gatherNotificationTimeMinuteKey,
      // * _practiceNotificationTimeHourKey,
      // * _practiceNotificationTimeMinuteKey,
    };
    await _sharedPreferences.clear(allowList: allowList);
  }
}
