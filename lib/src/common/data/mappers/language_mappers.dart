import 'package:pocketbase/pocketbase.dart';
import 'package:vocabualize/src/common/data/models/rdb_language.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';

extension RdbLanguageMappers on RdbLanguage {
  Language toLanguage() {
    return Language(
      id: id,
      name: name,
      nameDe: nameDe,
      nameEs: nameEs,
      translatorId: translatorId,
      premiumTranslatorId: premiumTranslatorId,
      speechToTextId: speechToTextId,
      textToSpeechId: textToSpeechId,
    );
  }
}

extension LanguageMappers on Language {
  RdbLanguage toRdbLanguage() {
    return RdbLanguage(
      id: id,
      name: name,
      nameDe: nameDe,
      nameEs: nameEs,
      translatorId: translatorId,
      premiumTranslatorId: premiumTranslatorId,
      speechToTextId: speechToTextId,
      textToSpeechId: textToSpeechId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameDe': nameDe,
      'nameEs': nameEs,
      'translatorId': translatorId,
      'premiumTranslatorId': premiumTranslatorId,
      'speechToTextId': speechToTextId,
      'textToSpeechId': textToSpeechId,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }
}

extension LanguageJsonMappers on Map<String, dynamic> {
  Language toLanguage() {
    return Language(
      id: this['id'] ?? "empty_id",
      name: this['name'],
      nameDe: this['nameDe'],
      nameEs: this['nameEs'],
      translatorId: this['translatorId'],
      premiumTranslatorId: this['premiumTranslatorId'],
      speechToTextId: this['speechToTextId'],
      textToSpeechId: this['textToSpeechId'],
      created: this['created'] != null ? DateTime.parse(this['created']) : null,
      updated: this['updated'] != null ? DateTime.parse(this['updated']) : null,
    );
  }
}

extension RecordModelLanguageMappers on RecordModel {
  RdbLanguage toRdbLanguage() {
    return RdbLanguage(
      id: id,
      name: getStringValue("name"),
      nameDe: getStringValue("nameDe"),
      nameEs: getStringValue("nameEs"),
      translatorId: getStringValue("translatorId"),
      premiumTranslatorId: getStringValue("premiumTranslatorId"),
      speechToTextId: getStringValue("speechToTextId"),
      textToSpeechId: getStringValue("textToSpeechId"),
      created: created,
      updated: updated,
    );
  }
}
