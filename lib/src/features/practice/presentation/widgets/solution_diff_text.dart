import 'package:diacritic/diacritic.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/material.dart';

class SolutionDiffText extends StatelessWidget {
  final String givenAnswerText;
  final String solutionText;
  final TextStyle? style;
  final TextStyle? correctionStyle;
  final TextStyle? mistakeStyle;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;

  const SolutionDiffText({
    required this.givenAnswerText,
    required this.solutionText,
    this.style,
    this.correctionStyle,
    this.mistakeStyle,
    this.textAlign = TextAlign.center,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.headlineMedium ?? const TextStyle();
    final correctionTextStyle = correctionStyle ??
        textStyle.copyWith(
          backgroundColor: Colors.blue,
        );
    final mistakeTextStyle = mistakeStyle ??
        textStyle.copyWith(
          backgroundColor: Colors.red,
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
        );

    final solutionNorm = _normalize(solutionText);
    final givenNorm = _normalize(givenAnswerText);

    DiffMatchPatch diffMatchPatch = DiffMatchPatch();
    List<Diff> differences = diffMatchPatch.diff(givenNorm.normalized, solutionNorm.normalized);
    diffMatchPatch.diffCleanupSemantic(differences);

    final List<TextSpan> textSpans = [];
    int normSolutionPos = 0;
    int normGivenPos = 0;

    for (int i = 0; i < differences.length; i++) {
      final difference = differences[i];
      switch (difference.operation) {
        case DIFF_EQUAL:
          {
            final solutionSegment = _getOriginalSegment(
              normSolutionPos,
              difference.text.length,
              solutionNorm.mapping,
              solutionText,
            );
            textSpans.add(TextSpan(text: solutionSegment, style: textStyle));
            normSolutionPos += difference.text.length;
            normGivenPos += difference.text.length;
          }
          break;
        case DIFF_INSERT:
          {
            final solutionSegment = _getOriginalSegment(
              normSolutionPos,
              difference.text.length,
              solutionNorm.mapping,
              solutionText,
            );
            textSpans.add(TextSpan(text: solutionSegment, style: correctionTextStyle));
            normSolutionPos += difference.text.length;
          }
          break;
        case DIFF_DELETE:
          {
            final givenSegment = _getOriginalSegment(
              normGivenPos,
              difference.text.length,
              givenNorm.mapping,
              givenAnswerText,
            );
            if (i + 1 < differences.length && differences[i + 1].operation == DIFF_INSERT) {
              final nextDiff = differences[i + 1];
              final correctionSegment = _getOriginalSegment(
                normSolutionPos,
                nextDiff.text.length,
                solutionNorm.mapping,
                solutionText,
              );
              textSpans.add(TextSpan(text: " $givenSegment ", style: mistakeTextStyle));
              textSpans.add(TextSpan(text: correctionSegment, style: correctionTextStyle));
              normSolutionPos += nextDiff.text.length;
              i++;
            } else {
              textSpans.add(TextSpan(text: " $givenSegment ", style: mistakeTextStyle));
            }
            normGivenPos += difference.text.length;
          }
          break;
      }
    }

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: textSpans,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }

  _NormalizationResult _normalize(String text) {
    List<int> mapping = [];
    StringBuffer normalized = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      String normalizedChar = removeDiacritics(char).toLowerCase();
      for (int j = 0; j < normalizedChar.length; j++) {
        mapping.add(i);
        if (j == 0) {
          normalized.write(normalizedChar[j]);
        } else {
          normalized.write(normalizedChar[j]);
        }
      }
    }
    return _NormalizationResult(normalized.toString(), mapping);
  }

  String _getOriginalSegment(
      int normPosition, int normLength, List<int> mapping, String originalText) {
    if (normPosition >= mapping.length) return '';
    int endNorm = normPosition + normLength;
    endNorm = endNorm.clamp(0, mapping.length);
    int startOrig = mapping[normPosition];
    int endOrig = endNorm > 0 ? mapping[endNorm - 1] + 1 : 0;
    endOrig = endOrig.clamp(0, originalText.length);
    return originalText.substring(startOrig, endOrig);
  }
}

class _NormalizationResult {
  final String normalized;
  final List<int> mapping;

  _NormalizationResult(this.normalized, this.mapping);
}
