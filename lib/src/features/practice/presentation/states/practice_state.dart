import 'package:vocabualize/src/common/domain/entities/level.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';

class PracticeState {
  final Set<String> possibleArticles;
  final (String, String)? currentIdWithAnswer;
  final int initialVocabularyCount;
  final List<Vocabulary> vocabulariesLeft;
  final bool isMultilingual;
  final bool isSolutionShown;
  final bool isTypedAnswerModeDisabled;
  final bool areImagesDisabled;

  const PracticeState({
    required this.possibleArticles,
    required this.currentIdWithAnswer,
    required this.initialVocabularyCount,
    required this.vocabulariesLeft,
    required this.isMultilingual,
    required this.isSolutionShown,
    required this.isTypedAnswerModeDisabled,
    required this.areImagesDisabled,
  });

  int get leftCount => vocabulariesLeft.length;
  int get doneCount => initialVocabularyCount - leftCount;
  bool get isDone => vocabulariesLeft.isEmpty;
  Vocabulary? get currentVocabulary => vocabulariesLeft.firstOrNull;

  bool get shouldAskForTextAnswer {
    final isAboveNovice =
        !(currentVocabulary?.level != null && currentVocabulary?.level is NoviceLevel);
    final isTypedAnswerModeEnabled = !isTypedAnswerModeDisabled;
    return isAboveNovice && isTypedAnswerModeEnabled;
  }

  String? get currentAnswer {
    if (currentIdWithAnswer == null) return null;
    if (currentIdWithAnswer?.$1 != currentVocabulary?.id) return null;
    return currentIdWithAnswer?.$2;
  }

  PracticeState copyWith({
    Set<String>? possibleArticles,
    (String, String)? currentIdWithAnswer,
    int? initialVocabularyCount,
    List<Vocabulary>? vocabulariesLeft,
    bool? isMultilingual,
    bool? isSolutionShown,
    bool? isTypedAnswerModeDisabled,
    bool? areImagesDisabled,
  }) {
    return PracticeState(
      possibleArticles: possibleArticles ?? this.possibleArticles,
      currentIdWithAnswer: currentIdWithAnswer ?? this.currentIdWithAnswer,
      initialVocabularyCount: initialVocabularyCount ?? this.initialVocabularyCount,
      vocabulariesLeft: vocabulariesLeft ?? this.vocabulariesLeft,
      isMultilingual: isMultilingual ?? this.isMultilingual,
      isSolutionShown: isSolutionShown ?? this.isSolutionShown,
      isTypedAnswerModeDisabled: isTypedAnswerModeDisabled ?? this.isTypedAnswerModeDisabled,
      areImagesDisabled: areImagesDisabled ?? this.areImagesDisabled,
    );
  }
}
