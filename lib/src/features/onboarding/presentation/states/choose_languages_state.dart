import 'package:vocabualize/src/common/domain/entities/language.dart';

class ChooseLanguagesState {
  final bool hasChosenSourceLanguage;
  final bool hasChosenTargetLanguage;
  final Language selectedSourceLanguage;
  final Language selectedTargetLanguage;

  const ChooseLanguagesState({
    required this.hasChosenSourceLanguage,
    required this.hasChosenTargetLanguage,
    required this.selectedSourceLanguage,
    required this.selectedTargetLanguage,
  });

  ChooseLanguagesState copyWith({
    bool? hasChosenSourceLanguage,
    bool? hasChosenTargetLanguage,
    Language? selectedSourceLanguage,
    Language? selectedTargetLanguage,
  }) {
    return ChooseLanguagesState(
      hasChosenSourceLanguage: hasChosenSourceLanguage ?? this.hasChosenSourceLanguage,
      hasChosenTargetLanguage: hasChosenTargetLanguage ?? this.hasChosenTargetLanguage,
      selectedSourceLanguage: selectedSourceLanguage ?? this.selectedSourceLanguage,
      selectedTargetLanguage: selectedTargetLanguage ?? this.selectedTargetLanguage,
    );
  }
}
