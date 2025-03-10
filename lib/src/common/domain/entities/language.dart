class Language {
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
  final DateTime? created;
  final DateTime? updated;

  const Language({
    this.id = "",
    required this.name,
    required this.nameDe,
    required this.nameEs,
    required this.nameFr,
    required this.nameUk,
    required this.translatorId,
    required this.premiumTranslatorId,
    required this.speechToTextId,
    required this.textToSpeechId,
    required this.articles,
    required this.isNonLatin,
    this.created,
    this.updated,
  });

  /// TODO: apply device language for name (to have the correct language on init)
  /// => Maybe setting this at onboarding will be enough
  factory Language.english() => const Language(
      id: "l4ucqbw6jc5i7bj",
      name: "English",
      nameDe: "Englisch",
      nameEs: "Inglés",
      nameFr: "Anglais",
      nameUk: "Англійська",
      translatorId: "en",
      premiumTranslatorId: "EN-US",
      speechToTextId: "en_US",
      textToSpeechId: "en-US",
      articles: ["a", "an", "the"],
      isNonLatin: false);
  factory Language.spanish() => const Language(
      id: "m6m3nliuhu85xny",
      name: "Spanish",
      nameDe: "Spanisch",
      nameEs: "Español",
      nameFr: "Espagnol",
      nameUk: "Іспанська",
      translatorId: "es",
      premiumTranslatorId: "ES",
      speechToTextId: "es_ES",
      textToSpeechId: "es-ES",
      articles: ["el", "la", "lo", "los", "las", "un", "una", "unos", "unas"],
      isNonLatin: false);
  factory Language.defaultSource() => Language.english();
  factory Language.defaultTarget() => Language.spanish();

  @override
  // ignore: hash_and_equals
  bool operator ==(other) {
    if (other is! Language) return false;
    return name == other.name &&
        translatorId == other.translatorId &&
        speechToTextId == other.speechToTextId &&
        textToSpeechId == other.textToSpeechId;
  }

  @override
  String toString() {
    return "Language(id: $id, name: $name, nameDe: $nameDe, nameEs: $nameEs, "
        "translatorId: $translatorId, premiumTranslatorId: $premiumTranslatorId, "
        "speechToTextId: $speechToTextId, textToSpeechId: $textToSpeechId, "
        "articles: $articles, created: $created, updated: $updated)";
  }
}
