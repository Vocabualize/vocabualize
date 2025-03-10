import 'package:diacritic/diacritic.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/domain/entities/answer.dart';
import 'package:vocabualize/src/features/practice/domain/extensions/string_extensions.dart';

final getDifficultyFromTextAnswerProvider = Provider((ref) {
  return GetDifficultyFromTextAnswerUseCase();
});

class GetDifficultyFromTextAnswerUseCase {
  Answer? call(
    String? givenAnswerText,
    String solutionText, {
    Set<String> possibleArticles = const {},
  }) {
    if (givenAnswerText == null) {
      return null;
    }
    final article = givenAnswerText.findFirstArticle(possibleArticles);
    final givenAnswerWithoutArticle = givenAnswerText.replaceAll(article ?? "", "");
    if (givenAnswerWithoutArticle.trim().isEmpty) {
      return Answer.forgot;
    }

    final differences = diff(
      removeDiacritics(givenAnswerText).toLowerCase(),
      removeDiacritics(solutionText).toLowerCase(),
    );
    int mistakes = _calculateMistakes(differences);

    return switch (mistakes) {
      0 => Answer.easy,
      1 => Answer.good,
      2 => Answer.good,
      _ => Answer.hard,
    };
  }

  // * Calculate the mistakes by grouping deletions and insertions.
  int _calculateMistakes(List<Diff> differences) {
    int mistakes = 0;
    int i = 0;
    while (i < differences.length) {
      if (differences[i].operation == DIFF_EQUAL) {
        i++;
        continue;
      }
      int groupDeletion = 0;
      int groupInsertion = 0;
      while (i < differences.length && differences[i].operation != DIFF_EQUAL) {
        if (differences[i].operation == DIFF_DELETE) {
          groupDeletion += differences[i].text.length;
        } else if (differences[i].operation == DIFF_INSERT) {
          groupInsertion += differences[i].text.length;
        }
        i++;
      }
      mistakes += groupDeletion > groupInsertion ? groupDeletion : groupInsertion;
    }
    return mistakes;
  }
}
