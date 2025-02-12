import 'package:collection/collection.dart';

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HomeState &&
        other.streak == streak &&
        other.isStreakActive == isStreakActive &&
        const DeepCollectionEquality().equals(other.alerts, alerts) &&
        const DeepCollectionEquality().equals(other.vocabularies, vocabularies) &&
        const DeepCollectionEquality().equals(other.newVocabularies, newVocabularies) &&
        const DeepCollectionEquality().equals(other.tags, tags) &&
        areCollectionsEnabled == other.areCollectionsEnabled &&
        areImagesDisabled == other.areImagesDisabled;
  }

  @override
  int get hashCode => Object.hashAll([
        streak,
        isStreakActive,
        const DeepCollectionEquality().hash(alerts),
        const DeepCollectionEquality().hash(vocabularies),
        const DeepCollectionEquality().hash(newVocabularies),
        const DeepCollectionEquality().hash(tags),
        areCollectionsEnabled,
        areImagesDisabled
      ]);
}
