class VersionComparator {
  /// Returns true if [v1] is strictly less than [v2].
  static bool isVersionLower(String v1, String v2) {
    try {
      final v1Parts = v1.split('.').map(int.parse).toList();
      final v2Parts = v2.split('.').map(int.parse).toList();
      
      for (var i = 0; i < 3; i++) {
        final p1 = i < v1Parts.length ? v1Parts[i] : 0;
        final p2 = i < v2Parts.length ? v2Parts[i] : 0;
        if (p1 < p2) return true;
        if (p1 > p2) return false;
      }
      return false;
    } on Exception catch (_) {
      // If version string is malformed, assume it's up to date
      return false;
    }
  }
}
