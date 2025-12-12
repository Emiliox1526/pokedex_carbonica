/// Mapping between route IDs in the map screen and PokeAPI location area identifiers
///
/// Kanto region routes typically have area identifiers like:
/// - "kanto-route-1-area" for simple routes
/// - "kanto-route-2-south-towards-viridian-city" for routes with sub-areas
///
/// Note: Some routes may have multiple areas or special naming conventions.
/// The actual area identifier should be verified with PokeAPI documentation.
class RouteAreaMapping {
  /// Map route ID to PokeAPI location area identifier
  static const Map<int, String> routeToAreaId = {
    1: 'kanto-route-1-area',
    2: 'kanto-route-2-south-towards-viridian-city',
    3: 'kanto-route-3-area',
    4: 'kanto-route-4-area',
    5: 'kanto-route-5-area',
    6: 'kanto-route-6-area',
    7: 'kanto-route-7-area',
    8: 'kanto-route-8-area',
    9: 'kanto-route-9-area',
    10: 'kanto-route-10-area',
    11: 'kanto-route-11-area',
    12: 'kanto-route-12-area',
    13: 'kanto-route-13-area',
    14: 'kanto-route-14-area',
    15: 'kanto-route-15-area',
    16: 'kanto-route-16-area',
    17: 'kanto-route-17-area',
    18: 'kanto-route-18-area',
    19: 'kanto-sea-route-19-area',
    20: 'kanto-sea-route-20-area',
    21: 'kanto-sea-route-21-area',
    22: 'kanto-route-22-area',
    23: 'kanto-route-23-area',
  };

  /// Get PokeAPI area identifier for a route ID
  static String? getAreaIdentifier(int routeId) {
    return routeToAreaId[routeId];
  }

  /// Alternative area identifiers for routes with multiple areas
  /// This can be expanded if specific routes need fallback options
  static const Map<int, List<String>> alternativeAreas = {
    // Route 2 has multiple areas in some versions
    2: [
      'kanto-route-2-south-towards-viridian-city',
      'kanto-route-2-north-towards-pewter-city',
    ],
    // Route 10 may have different areas
    10: [
      'kanto-route-10-area',
      'kanto-route-10-north-pokemon-tower-rock-tunnel',
    ],
  };

  /// Get all possible area identifiers for a route (primary + alternatives)
  static List<String> getAllAreaIdentifiers(int routeId) {
    final primary = routeToAreaId[routeId];
    final alternatives = alternativeAreas[routeId] ?? [];
    
    if (primary != null) {
      return [primary, ...alternatives.where((a) => a != primary)];
    }
    return alternatives;
  }
}
