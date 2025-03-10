import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';

class RecordState {
  final List<Vocabulary> existingVocabularies;
  final CameraController cameraController;
  final double zoomLevel;
  final double maxZoomLevel;
  final Uint8List? imageBytes;
  final Set<String>? suggestions;
  final Language? sourceLanguage;
  final Language? targetLanguage;

  const RecordState({
    required this.existingVocabularies,
    required this.cameraController,
    this.zoomLevel = 1.0,
    this.maxZoomLevel = 1.0,
    this.imageBytes,
    this.suggestions,
    this.sourceLanguage,
    this.targetLanguage,
  });

  bool containsSource(String source) {
    return existingVocabularies.any((vocabulary) => vocabulary.source == source);
  }

  RecordState copyWith({
    CameraController? cameraController,
    double? zoomLevel,
    double? maxZoomLevel,
    Uint8List? Function()? imageBytes,
    Set<String>? Function()? suggestions,
    Language? sourceLanguage,
    Language? targetLanguage,
  }) {
    return RecordState(
      existingVocabularies: existingVocabularies,
      cameraController: cameraController ?? this.cameraController,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      imageBytes: imageBytes != null ? imageBytes() : this.imageBytes,
      suggestions: suggestions != null ? suggestions() : this.suggestions,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}
