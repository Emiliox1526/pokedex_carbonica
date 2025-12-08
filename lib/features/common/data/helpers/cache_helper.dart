/// Shared helper for common cache validation patterns.
///
/// This class provides reusable methods for cache timestamp validation
/// and key generation across different local data sources.
class CacheHelper {
  /// Default cache duration in hours.
  static const int defaultCacheDurationHours = 24;

  /// Checks if a cache timestamp is still valid.
  ///
  /// [timestampMillis] is the cache timestamp in milliseconds since epoch.
  /// [durationHours] is the cache validity duration (defaults to 24 hours).
  ///
  /// Returns true if the cache is still valid, false if expired or null.
  static bool isCacheValid(int? timestampMillis, {int durationHours = defaultCacheDurationHours}) {
    if (timestampMillis == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    final now = DateTime.now();
    final difference = now.difference(cacheDate);

    return difference.inHours < durationHours;
  }

  /// Gets the current timestamp in milliseconds.
  ///
  /// Useful for storing cache timestamps.
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Builds a cache key from multiple parts.
  ///
  /// [parts] are the components to join with underscores.
  ///
  /// Returns a string cache key.
  static String buildCacheKey(List<String> parts) {
    return parts.where((p) => p.isNotEmpty).join('_');
  }

  /// Sanitizes a string for use in a cache key.
  ///
  /// Removes special characters and converts to lowercase.
  static String sanitizeForKey(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }
}
