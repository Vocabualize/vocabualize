import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

extension VocabularyExtensions on Vocabulary {
  String reappearsIn(BuildContext context) {
    final now = DateTime.now();
    final difference = nextDate.difference(now);

    if (difference.isNegative) {
      return context.s.home_vocabulary_reappears_now;
    }
    if (difference.inMinutes < 1) {
      return context.s.home_vocabulary_reappears_less_minute;
    }
    if (difference.inHours < 1) {
      return context.s.home_vocabulary_reappears_minutes(difference.inMinutes);
    }
    if (difference.inDays < 1) {
      return context.s.home_vocabulary_reappears_hours(difference.inHours);
    }
    if (difference.inDays <= 7) {
      return context.s.home_vocabulary_reappears_days(difference.inDays);
    }
    return DateFormat("dd.MM.yyyy - HH:mm").format(nextDate);
  }
}
