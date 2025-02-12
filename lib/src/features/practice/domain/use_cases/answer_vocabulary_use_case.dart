import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:log/log.dart';
import 'package:vocabualize/constants/due_algorithm_constants.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/answer.dart';
import 'package:vocabualize/src/common/domain/entities/level.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';

final answerVocabularyUseCaseProvider = AutoDisposeProvider((ref) {
  return AnswerVocabularyUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class AnswerVocabularyUseCase {
  final SettingsRepository _settingsRepository;

  const AnswerVocabularyUseCase({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  Future<Vocabulary> call({
    required Vocabulary vocabulary,
    required Answer answer,
  }) async {
    int initialInterval = await _settingsRepository.getInitialInterval();
    int initialNoviceInterval =
        await _settingsRepository.getInitialNoviceInterval();
    double easyIntervalMultiplicand =
        await _settingsRepository.getEasyIntervalMultiplicand();
    double initialEase = await _settingsRepository.getInitialEase();
    double easyEaseSummand = await _settingsRepository.getEasyEaseSummand();
    double hardEaseSubtrahend =
        await _settingsRepository.getHardEaseSubtrahend();

    // * If novice, then double (or half) the summands and subtrahends
    double easyLevelSummand = (vocabulary.isNovice ? 2 : 1) *
        await _settingsRepository.getEasyLevelSummand();
    double goodLevelSummand = (vocabulary.isNovice ? 2 : 1) *
        await _settingsRepository.getGoodLevelSummand();
    double hardLevelSubtrahend = (vocabulary.isNovice ? 0.5 : 1) *
        await _settingsRepository.getHardLevelSubtrahend();

    double levelLimit = DueAlgorithmConstants.levelLimit;

    // * Vocabulary is shown for the first time => initial novice interval
    final currentInterval = vocabulary.isNovice && vocabulary.level.value == 0
        ? initialNoviceInterval
        : vocabulary.interval;

    final double levelValue;
    final bool isNovice;
    final int noviceInterval;
    final int interval;
    final double ease;
    final DateTime nextDate;

    switch (answer) {
      case Answer.forgot:
        return vocabulary.copyWithResetProgress();
      case Answer.hard:
        levelValue = vocabulary.level.value - hardLevelSubtrahend;
        isNovice = vocabulary.isNovice;
        noviceInterval = vocabulary.noviceInterval;
        interval = (currentInterval * vocabulary.ease).toInt();
        ease = vocabulary.ease - hardEaseSubtrahend;
        nextDate = DateTime.now().add(Duration(minutes: currentInterval));
        break;
      case Answer.good:
        levelValue = vocabulary.level.value + goodLevelSummand;
        isNovice = vocabulary.isNovice;
        noviceInterval = vocabulary.noviceInterval;
        interval = (currentInterval * vocabulary.ease).toInt();
        ease = vocabulary.ease;
        nextDate = DateTime.now().add(Duration(minutes: currentInterval));
        break;
      case Answer.easy:
        levelValue = vocabulary.level.value + easyLevelSummand;
        isNovice = vocabulary.isNovice;
        noviceInterval = vocabulary.noviceInterval;
        interval =
            (currentInterval * vocabulary.ease * easyIntervalMultiplicand)
                .toInt();
        ease = vocabulary.ease + easyEaseSummand;
        nextDate = DateTime.now().add(Duration(minutes: currentInterval));
        break;
      default:
        Log.warning("Unknown answer type: $answer. Canceled answering.");
        return vocabulary;
    }

    // * hasJustGraduated means, that its no longer a novice (use initialInterval now)
    final hasJustGraduated = isNovice && levelValue >= (1 - goodLevelSummand);

    return vocabulary.copyWith(
      level: Level(value: clampDouble(levelValue, 0, levelLimit)),
      isNovice: hasJustGraduated ? false : isNovice,
      noviceInterval: noviceInterval,
      interval: hasJustGraduated ? initialInterval : interval,
      ease: isNovice ? initialEase : ease,
      nextDate: nextDate,
    );
  }
}
