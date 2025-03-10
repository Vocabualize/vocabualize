class RdbLanguage {
  final String id;
  final String name;
  final String nameDe;
  final String nameEs;
  final String nameFr;
  final String nameUk;
  final String translatorId;
  final String premiumTranslatorId;
  final String speechToTextId;
  final String textToSpeechId;
  final List<String> articles;
  final bool isNonLatin;
  final String? created;
  final String? updated;

  const RdbLanguage({
    this.id = "",
    this.name = "",
    this.nameDe = "",
    this.nameEs = "",
    this.nameFr = "",
    this.nameUk = "",
    this.translatorId = "",
    this.premiumTranslatorId = "",
    this.speechToTextId = "",
    this.textToSpeechId = "",
    this.articles = const [],
    this.isNonLatin = false,
    this.created = "",
    this.updated = "",
  });
}
