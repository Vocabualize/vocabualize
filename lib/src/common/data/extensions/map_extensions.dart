extension MapExtensions on Map {
  T? get<T>(String key, [T? fallback]) {
    if (containsKey(key)) {
      return this[key];
    }
    return fallback;
  }
}
