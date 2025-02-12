import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';

class RecordState {
  final CameraController cameraController;
  final Uint8List? imageBytes;
  final Set<String>? suggestions;
  final Language? sourceLanguage;
  final Language? targetLanguage;

  const RecordState({
    required this.cameraController,
    this.imageBytes,
    this.suggestions,
    this.sourceLanguage,
    this.targetLanguage,
  });

  RecordState copyWith({
    CameraController? cameraController,
    Uint8List? Function()? imageBytes,
    Set<String>? Function()? suggestions,
    Language? sourceLanguage,
    Language? targetLanguage,
  }) {
    return RecordState(
      cameraController: cameraController ?? this.cameraController,
      imageBytes: imageBytes != null ? imageBytes() : this.imageBytes,
      suggestions: suggestions != null ? suggestions() : this.suggestions,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}
