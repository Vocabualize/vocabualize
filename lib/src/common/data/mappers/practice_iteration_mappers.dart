import 'package:vocabualize/src/common/data/models/rdb_practice_iteration.dart';

extension RdbPracticeIterationMappers on RdbPracticeIteration {
  Map<String, dynamic> toJson() {
    return {
      "practicedCount": practicedCount,
      "dueCount": dueCount,
      "time": time.toIso8601String(),
    };
  }
}

extension RdbPracticeIterationJsonMappers on Map<String, dynamic> {
  RdbPracticeIteration toRdbPracticeIteration() {
    return RdbPracticeIteration(
      practicedCount: this["practicedCount"],
      dueCount: this["dueCount"],
      time: DateTime.tryParse(this["time"] ?? ""),
    );
  }
}

extension RdbPracticeIterationListMappers on List {
  List<Map<String, dynamic>> toJsonList() {
    return cast<Map<String, dynamic>>();
  }
}
