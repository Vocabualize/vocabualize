import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';

class HomeState {
  final int streak;
  final bool isStreakActive;
  final List<Alert> alerts;
  final List<Vocabulary> vocabularies;
  final List<Vocabulary> newVocabularies;
  final List<Tag> tags;
  final bool areCollectionsEnabled;
  final bool areImagesDisabled;

  const HomeState({
    required this.streak,
    required this.isStreakActive,
    required this.alerts,
    required this.vocabularies,
    required this.newVocabularies,
    required this.tags,
    required this.areCollectionsEnabled,
    required this.areImagesDisabled,
  });

  bool containsSource(String source) {
    return vocabularies.any((v) => v.source == source);
  }

  HomeState copyWith({
    int? streak,
    bool? isStreakActive,
    List<Vocabulary>? vocabularies,
    List<Vocabulary>? newVocabularies,
    List<Tag>? tags,
    bool? areCollectionsEnabled,
    bool? areImagesDisabled,
  }) {
    return HomeState(
      streak: streak ?? this.streak,
      isStreakActive: isStreakActive ?? this.isStreakActive,
      alerts: alerts,
      vocabularies: vocabularies ?? this.vocabularies,
      newVocabularies: newVocabularies ?? this.newVocabularies,
      tags: tags ?? this.tags,
      areCollectionsEnabled: areCollectionsEnabled ?? this.areCollectionsEnabled,
      areImagesDisabled: areImagesDisabled ?? this.areImagesDisabled,
    );
  }
}
