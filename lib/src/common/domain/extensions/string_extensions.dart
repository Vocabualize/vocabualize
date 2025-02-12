extension NullableStringExtensions on String? {
  bool isNullOrEmpty() {
    return this == null || this?.isEmpty == true;
  }

  bool isNotNullOrEmpty() {
    return !isNullOrEmpty();
  }
}

extension StringExtensions on String {
  String firstToUppercase() {
    if (length <= 1) return toUpperCase();
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
