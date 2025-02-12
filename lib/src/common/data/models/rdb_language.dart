class RdbLanguage {
  final String id;
  final String name;
  final String nameDe;
  final String nameEs;
  final String translatorId;
  final String premiumTranslatorId;
  final String speechToTextId;
  final String textToSpeechId;
  final String? created;
  final String? updated;

  const RdbLanguage({
    this.id = "",
    this.name = "",
    this.nameDe = "",
    this.nameEs = "",
    this.translatorId = "",
    this.premiumTranslatorId = "",
    this.speechToTextId = "",
    this.textToSpeechId = "",
    this.created = "",
    this.updated = "",
  });
}
