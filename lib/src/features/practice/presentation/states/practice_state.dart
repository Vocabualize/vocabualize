import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';

class PracticeState {
  final int initialVocabularyCount;
  final List<Vocabulary> vocabulariesLeft;
  final bool isMultilingual;
  final bool isSolutionShown;
  final bool areImagesDisabled;

  const PracticeState({
    required this.initialVocabularyCount,
    required this.vocabulariesLeft,
    required this.isMultilingual,
    required this.isSolutionShown,
    required this.areImagesDisabled,
  });

  int get leftCount => vocabulariesLeft.length;
  int get doneCount => initialVocabularyCount - leftCount;
  Vocabulary? get currentVocabulary => vocabulariesLeft.firstOrNull;
  bool get isDone => vocabulariesLeft.isEmpty;

  PracticeState copyWith({
    int? initialVocabularyCount,
    List<Vocabulary>? vocabulariesLeft,
    bool? isMultilingual,
    bool? isSolutionShown,
    bool? areImagesDisabled,
  }) {
    return PracticeState(
      initialVocabularyCount: initialVocabularyCount ?? this.initialVocabularyCount,
      vocabulariesLeft: vocabulariesLeft ?? this.vocabulariesLeft,
      isMultilingual: isMultilingual ?? this.isMultilingual,
      isSolutionShown: isSolutionShown ?? this.isSolutionShown,
      areImagesDisabled: areImagesDisabled ?? this.areImagesDisabled,
    );
  }
}
