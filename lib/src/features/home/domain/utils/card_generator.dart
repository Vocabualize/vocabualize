import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class CardGenerator {
  static bool _hasBeenCreatedToday(Vocabulary vocabulary) {
    DateTime todayRaw = DateTime.now();
    DateTime today = DateTime(todayRaw.year, todayRaw.month, todayRaw.day);
    DateTime creationDayRaw = vocabulary.created;
    DateTime creationDay = DateTime(creationDayRaw.year, creationDayRaw.month, creationDayRaw.day);
    if (creationDay.isAtSameMomentAs(today)) return true;
    return false;
  }

  static String generateMessage(
    BuildContext context,
    List<Vocabulary>? vocabularyList,
  ) {
    if (vocabularyList == null) return "";

    List<Vocabulary> createdToday = vocabularyList.where((vocabulary) {
      return _hasBeenCreatedToday(vocabulary);
    }).toList();

    List<String> possibleInfos = [];

    if (vocabularyList.length == 1 && _hasBeenCreatedToday(vocabularyList.first)) {
      return context.s.home_statusCard_firstWord;
    }
    if (vocabularyList.isEmpty) {
      possibleInfos.add(context.s.home_statusCard_isEmpty);
    }
    if (createdToday.length >= 3) {
      possibleInfos.add(context.s.home_statusCard_addedToday(createdToday.length));
    }
    if (vocabularyList.length >= 10) {
      possibleInfos.add(context.s.home_statusCard_addedManyInTotal(vocabularyList.length));
    }
    if (vocabularyList.length == 1) {
      possibleInfos.add(context.s.home_statusCard_onlyOneWord(vocabularyList.length));
    }
    possibleInfos.add(context.s.home_statusCard_default(vocabularyList.length));

    return possibleInfos.elementAt(Random().nextInt(possibleInfos.length));
  }
}
