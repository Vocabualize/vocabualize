import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/domain/entities/answer.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/language/get_language_by_id_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/language/read_out_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_is_type_answer_mode_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/add_or_update_vocabulary_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/practice/domain/use_cases/answer_vocabulary_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_vocabularies_to_practice_use_case.dart';
import 'package:vocabualize/src/features/practice/domain/use_cases/is_collection_multilingual_use_case.dart';
import 'package:vocabualize/src/features/practice/presentation/states/practice_state.dart';

final practiceControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<PracticeController, PracticeState, Tag?>(() {
  return PracticeController();
});

class PracticeController extends AutoDisposeFamilyAsyncNotifier<PracticeState, Tag?> {
  @override
  Future<PracticeState> build(Tag? arg) async {
    final tag = arg;
    List<Vocabulary> vocabulariesToPractice = ref.read(
      getVocabulariesToPracticeUseCaseProvider(tag),
    );
    final targetLanguageIds = vocabulariesToPractice.map((v) => v.targetLanguageId).toSet();
    final targetLangues = await Future.wait(
      targetLanguageIds.map((id) => ref.read(getLanguageByIdUseCaseProvider)(id)),
    );
    final possibleArticles = targetLangues.nonNulls.map((l) => l.articles).expand((e) => e).toSet();
    return PracticeState(
      possibleArticles: possibleArticles,
      currentIdWithAnswer: null,
      initialVocabularyCount: vocabulariesToPractice.length,
      vocabulariesLeft: vocabulariesToPractice,
      isMultilingual: await ref.read(isCollectionMultilingualUseCaseProvider(tag)),
      isSolutionShown: false,
      isTypedAnswerModeDisabled: await ref.read(getIsTypeAnswerModeDisabledUseCaseProvider.future),
      areImagesDisabled: await ref.read(getAreImagesDisabledUseCaseProvider.future),
    );
  }

  void close(BuildContext context) {
    context.pop();
  }

  Future<String> getMultilingualLabel() async {
    final currentVocabulary = state.value?.currentVocabulary;
    if (currentVocabulary == null) return "";
    final getLanguageById = ref.read(getLanguageByIdUseCaseProvider);
    final currentSourceLanguage = await getLanguageById(
      currentVocabulary.sourceLanguageId,
    );
    final currentTargetLanguage = await getLanguageById(
      currentVocabulary.targetLanguageId,
    );
    return "${currentSourceLanguage?.name}  ►  ${currentTargetLanguage?.name}";
  }

  void readOutCurrent() {
    state.value?.let((value) {
      final readOut = ref.read(readOutUseCaseProvider);
      final currentVocabulary = value.currentVocabulary;
      if (currentVocabulary == null) return;
      readOut(currentVocabulary);
    });
  }

  void showSolution(String? answerText) {
    update((previous) {
      final currentVocabularyId = previous.currentVocabulary?.id;
      final currentIdWithAnswer = currentVocabularyId != null && answerText != null
          ? (currentVocabularyId, answerText)
          : null;
      return previous.copyWith(
        currentIdWithAnswer: currentIdWithAnswer,
        isSolutionShown: true,
      );
    });
  }

  Future<void> answerCurrent(Answer answer) async {
    update((previous) async {
      final currentVocabulary = previous.currentVocabulary;
      if (currentVocabulary == null) return previous;
      final answerVocabulary = ref.read(answerVocabularyUseCaseProvider);
      final updatedVocabulary = await answerVocabulary(
        vocabulary: currentVocabulary,
        answer: answer,
      );
      await ref.read(addOrUpdateVocabularyUseCaseProvider(updatedVocabulary));
      return previous.copyWith(
        currentIdWithAnswer: null,
        vocabulariesLeft: previous.vocabulariesLeft.sublist(1),
        isSolutionShown: false,
      );
    });
  }
}
