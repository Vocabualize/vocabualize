class RdbPracticeIteration {
  final int practicedCount;
  final int dueCount;
  final DateTime time;

  RdbPracticeIteration({
    required this.practicedCount,
    required this.dueCount,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  bool get isValid {
    return practicedCount > 0 && dueCount > 0 && practicedCount <= dueCount;
  }
}
