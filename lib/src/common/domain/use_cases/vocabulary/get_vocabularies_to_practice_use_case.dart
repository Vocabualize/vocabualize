import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/vocabulary_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';

final getVocabulariesToPracticeUseCaseProvider = AutoDisposeProvider.family((ref, Tag? tag) {
  return GetVocabulariesToPracticeUseCase(
    vocabularies: ref.watch(vocabularyProvider).value ?? [],
  ).call(tag);
});

class GetVocabulariesToPracticeUseCase {
  final List<Vocabulary> _vocabularies;

  const GetVocabulariesToPracticeUseCase({
    required List<Vocabulary> vocabularies,
  }) : _vocabularies = vocabularies;

  List<Vocabulary> call(Tag? tag) {
    return _vocabularies.where((vocabulary) {
      final containsTag = tag?.id == null || vocabulary.tagIds.contains(tag?.id);
      return vocabulary.isDue && containsTag;
    }).toList();
  }
}
