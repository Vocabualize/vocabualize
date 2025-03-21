import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galli_text_to_speech/text_to_speech.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';

final textToSpeechDataSourceProvider =
    Provider((ref) => TextToSpeechDataSource());

class TextToSpeechDataSource {
  final TextToSpeech _tts = TextToSpeech();

  String? _currentLanguage;

  Future<List<String>> getLanguages() async {
    return await _tts.getLanguages();
  }

  Future<void> setLanguage(String textToSpeedId) async {
    await _tts.setLanguage(textToSpeedId);
    _currentLanguage = textToSpeedId;
  }

  Future<void> speak(Vocabulary vocabulary, {String? textToSpeechId}) async {
    if (textToSpeechId != null && _currentLanguage != textToSpeechId) {
      await setLanguage(textToSpeechId);
    }
    await _tts.speak(vocabulary.target);
  }

  void stop() {
    _tts.stop();
  }
}
