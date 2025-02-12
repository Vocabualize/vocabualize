import 'package:pocketbase/pocketbase.dart';
import 'package:vocabualize/src/common/data/extensions/string_extensions.dart';
import 'package:vocabualize/src/common/data/models/rdb_alert.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';

extension RecordModelAlertMappers on RecordModel {
  RdbAlert toRdbAlert() {
    return RdbAlert(
      enabled: getBoolValue("enabled", false),
      id: id,
      type: getDataValue<String>("type", ""),
      positions: getListValue<String>("positions", []),
      title: getDataValue<String?>("title", null),
      titleDe: getDataValue<String?>("title_de", null),
      message: getDataValue<String>("message", ""),
      messageDe: getDataValue<String?>("message_de", null),
      image: getDataValue<String?>("image", "")?.toFileUrl(id, collectionName),
      buttonLabel: getDataValue<String?>("button_label", null),
      buttonUrl: getDataValue<String?>("button_url", null),
      appVersion: getDataValue<String?>("app_version", null),
      start: getDataValue("start", ""),
      end: getDataValue("end", ""),
      created: created,
      updated: updated,
    );
  }
}

extension RdbAlertMappers on RdbAlert {
  Alert? toAlert() {
    final AlertType? parsedType = switch (type) {
      "critical" => AlertType.critical,
      "warning" => AlertType.warning,
      "info" => AlertType.info,
      "hint" => AlertType.hint,
      _ => null,
    };
    final List<AlertPosition> parsedPositions = positions
        .map((it) => switch (it) {
              "blocking" => AlertPosition.blocking,
              "welcome" => AlertPosition.welcome,
              "home" => AlertPosition.home,
              _ => null,
            })
        .nonNulls
        .toList();
    final DateTime? parsedStart = start.toDateTimeOrNull();
    final DateTime? parsedEnd = end.toDateTimeOrNull();
    if (parsedType == null || parsedPositions.isEmpty || parsedStart == null || parsedEnd == null) {
      return null;
    }
    return Alert(
      enabled: enabled,
      id: id,
      type: parsedType,
      positions: parsedPositions,
      title: title?.takeUnless((it) => it.isEmpty),
      titleDe: titleDe?.takeUnless((it) => it.isEmpty),
      message: message,
      messageDe: messageDe?.takeUnless((it) => it.isEmpty),
      imageUrl: image?.takeUnless((it) => it.isEmpty)?.let((it) => Uri.tryParse(it)),
      buttonLabel: buttonLabel?.takeUnless((it) => it.isEmpty),
      buttonUrl: buttonUrl?.takeUnless((it) => it.isEmpty)?.let((it) => Uri.tryParse(it)),
      appVersion: appVersion?.takeUnless((it) => it.isEmpty),
      start: parsedStart,
      end: parsedEnd,
      created: created?.toDateTimeOrNull(),
      updated: updated?.toDateTimeOrNull(),
    );
  }
}
