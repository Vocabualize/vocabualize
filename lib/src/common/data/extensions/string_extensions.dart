import 'package:log/log.dart';
import 'package:vocabualize/constants/secrets/pocketbase_secrets.dart';

extension StringExtensions on String {
  // TODO: Remove String.toFileUrl() extension and find an alternative using pb.files.getUrl(record, filename)
  String? toFileUrl(String recordId, String collectionName) {
    if (isEmpty) return null;
    return "${PocketbaseSecrets.databaseUrl}/api/files/$collectionName/$recordId/$this";
  }

  String toFileName() {
    return split("/").last;
  }

  Uri toUri({String? fallbackUrl}) {
    try {
      return Uri.parse(this);
    } on FormatException catch (e) {
      if (fallbackUrl != null) {
        Log.warning(
          "Failed to parse URI: '$this'. Using fallback URL: '$fallbackUrl'.",
        );
        return fallbackUrl.toUri();
      }
      Log.error(
        "Failed to parse URI: '$this'. No fallback URL provided.",
        exception: e,
      );
      rethrow;
    }
  }

  Uri toUriWithParameters({
    required Map<String, String> parameters,
    String? fallbackUrl,
  }) {
    String uriWithParameters = this;
    for (int index = 0; index < parameters.length; index++) {
      final String separator = index == 0 ? "?" : "&";
      final String key = parameters.keys.elementAt(index);
      final String value = parameters.values.elementAt(index);
      uriWithParameters += "$separator$key=$value";
    }
    return uriWithParameters.toUri(fallbackUrl: fallbackUrl);
  }

  DateTime? toDateTimeOrNull({bool? convertToLocal = false}) {
    try {
      final parsedDateTime = DateTime.parse(this);
      if (convertToLocal == true) {
        return parsedDateTime.toLocal();
      }
      return parsedDateTime;
    } on FormatException catch (e) {
      Log.warning(
        "Failed to parse date: '$this'. Message: ${e.message}",
      );
      return null;
    }
  }

  (String, DateTime)? decodeTrackingId() {
    if (length != 15) {
      Log.error("Invalid tracking ID: '$this'.");
      return null;
    }

    final beginningUserId = substring(0, 12);

    final epoch = DateTime(2000, 1, 1);
    final dayCode = substring(12);
    final daysSinceEpoch = _fromBase36(dayCode);
    final date = epoch.add(Duration(days: daysSinceEpoch));

    return (beginningUserId, date);
  }

  String? encodeTrackingId({DateTime? date}) {
    if (length != 15) {
      Log.error("Invalid user ID: '$this'.");
      return null;
    }

    final beginningUserId = substring(0, 12);

    final epoch = DateTime(2000, 1, 1);
    final dateTime = date ?? DateTime.now();
    final daysSinceEpoch = dateTime.difference(epoch).inDays;
    final dayCode = _toBase36(daysSinceEpoch);

    return "$beginningUserId$dayCode";
  }
}

String _toBase36(int num, {int length = 3}) {
  const chars = "0123456789abcdefghijklmnopqrstuvwxyz";
  String result = "";
  while (num > 0 || result.length < length) {
    final remainder = num % 36;
    result = chars[remainder] + result;
    num = num ~/ 36;
  }
  return result.padLeft(length, '0');
}

int _fromBase36(String s) {
  const chars = "0123456789abcdefghijklmnopqrstuvwxyz";
  int result = 0;
  for (int i = 0; i < s.length; i++) {
    final char = s[i];
    final value = chars.indexOf(char);
    result = result * 36 + value;
  }
  return result;
}
