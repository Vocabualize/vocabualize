enum AlertType {
  critical,
  warning,
  info,
  hint,
}

enum AlertPosition {
  blocking,
  welcome,
  home,
}

class Alert {
  final bool enabled;
  final String id;
  final AlertType type;
  final List<AlertPosition> positions;
  final String? title;
  final String? titleDe;
  final String message;
  final String? messageDe;
  final Uri? imageUrl;
  final String? buttonLabel;
  final Uri? buttonUrl;
  final String? appVersion;
  final DateTime start;
  final DateTime end;
  final DateTime? created;
  final DateTime? updated;

  Alert({
    required this.enabled,
    required this.id,
    required this.type,
    required this.positions,
    this.title,
    this.titleDe,
    required this.message,
    this.messageDe,
    this.imageUrl,
    this.buttonLabel,
    this.buttonUrl,
    this.appVersion,
    required this.start,
    required this.end,
    this.created,
    this.updated,
  });
}
