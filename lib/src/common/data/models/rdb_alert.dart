class RdbAlert {
  final bool enabled;
  final String id;
  final String type;
  final List<String> positions;
  final String? title;
  final String? titleDe;
  final String message;
  final String? messageDe;
  final String? image;
  final String? buttonLabel;
  final String? buttonUrl;
  final String? appVersion;
  final String start;
  final String end;
  final String? created;
  final String? updated;

  RdbAlert({
    required this.enabled,
    required this.id,
    required this.type,
    required this.positions,
    this.title,
    this.titleDe,
    required this.message,
    this.messageDe,
    this.image,
    this.buttonLabel,
    this.buttonUrl,
    this.appVersion,
    required this.start,
    required this.end,
    this.created,
    this.updated,
  });
}
