import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/language_repository_impl.dart';
import 'package:vocabualize/src/common/data/repositories/text_to_speech_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/repositories/language_repository.dart';
import 'package:vocabualize/src/common/domain/repositories/text_to_speech_repository.dart';

final readOutUseCaseProvider = AutoDisposeProvider((ref) {
  return ReadOutUseCase(
    languageRepository: ref.watch(languageRepositoryProvider),
    textToSpeechRepository: ref.watch(textToSpeechRepositoryProvider),
  );
});

class ReadOutUseCase {
  final LanguageRepository _languageRepository;
  final TextToSpeechRepository _textToSpeechRepository;

  const ReadOutUseCase({
    required LanguageRepository languageRepository,
    required TextToSpeechRepository textToSpeechRepository,
  })  : _textToSpeechRepository = textToSpeechRepository,
        _languageRepository = languageRepository;

  Future<void> call(Vocabulary vocabulary) async {
    final textToSpeechLanguage = await _languageRepository.getLanguageById(
      vocabulary.targetLanguageId,
    );
    return _textToSpeechRepository.readOut(
      vocabulary,
      textToSpeechId: textToSpeechLanguage?.textToSpeechId,
    );
  }
}
