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
      nameFr: nameFr,
      nameUk: nameUk,
      translatorId: translatorId,
      premiumTranslatorId: premiumTranslatorId,
      speechToTextId: speechToTextId,
      textToSpeechId: textToSpeechId,
      articles: articles,
      isNonLatin: isNonLatin,
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
        nameFr: nameFr,
        nameUk: nameUk,
        translatorId: translatorId,
        premiumTranslatorId: premiumTranslatorId,
        speechToTextId: speechToTextId,
        textToSpeechId: textToSpeechId,
        articles: articles,
        isNonLatin: isNonLatin);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameDe': nameDe,
      'nameEs': nameEs,
      'nameFr': nameFr,
      'nameUk': nameUk,
      'translatorId': translatorId,
      'premiumTranslatorId': premiumTranslatorId,
      'speechToTextId': speechToTextId,
      'textToSpeechId': textToSpeechId,
      'articles': articles.join(","),
      'isNonLatin': isNonLatin,
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
      nameFr: this['nameFr'],
      nameUk: this['nameUk'],
      translatorId: this['translatorId'],
      premiumTranslatorId: this['premiumTranslatorId'],
      speechToTextId: this['speechToTextId'],
      textToSpeechId: this['textToSpeechId'],
      articles: (this['articles'] as String?)?.stringList ?? [],
      isNonLatin: this['isNonLatin'] ?? false,
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
      nameFr: getStringValue("nameFr"),
      nameUk: getStringValue("nameUk"),
      translatorId: getStringValue("translatorId"),
      premiumTranslatorId: getStringValue("premiumTranslatorId"),
      speechToTextId: getStringValue("speechToTextId"),
      textToSpeechId: getStringValue("textToSpeechId"),
      articles: getDataValue<String?>("articles", null)?.stringList ?? [],
      isNonLatin: getBoolValue("isNonLatin"),
      created: created,
      updated: updated,
    );
  }
}

extension _StringExtensions on String {
  List<String> get stringList {
    return split(",").nonNulls.where((a) => a.trim() != "").toList();
  }
}
