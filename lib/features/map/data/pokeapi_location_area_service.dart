import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/location_area_models.dart';

/// Service for fetching location area data from PokeAPI
///
/// Implements simple in-memory caching and retry logic for PokeAPI REST calls.
class PokeApiLocationAreaService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const Duration _timeout = Duration(seconds: 30);

  // In-memory cache: area name/id -> response
  final Map<String, LocationAreaResponse> _cache = {};

  /// Fetch location area data with caching
  ///
  /// [areaIdentifier] can be area id (int) or area name (string)
  /// Returns cached data if available, otherwise fetches from API
  /// Throws exceptions on network/parse errors
  Future<LocationAreaResponse> fetchLocationArea(String areaIdentifier) async {
    // Check cache first
    if (_cache.containsKey(areaIdentifier)) {
      return _cache[areaIdentifier]!;
    }

    // Fetch from API with retry logic
    LocationAreaResponse response;
    try {
      response = await _fetchWithRetry(areaIdentifier);
    } catch (e) {
      rethrow;
    }

    // Cache the response
    _cache[areaIdentifier] = response;
    return response;
  }

  /// Fetch from API with one retry on transient errors
  Future<LocationAreaResponse> _fetchWithRetry(
    String areaIdentifier, {
    int retries = 1,
  }) async {
    Exception? lastException;

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        return await _fetchFromApi(areaIdentifier);
      } on http.ClientException catch (e) {
        lastException = e;
        if (attempt < retries) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
      } on TimeoutException catch (e) {
        lastException = e;
        if (attempt < retries) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
      }
    }

    throw lastException ?? Exception('Failed to fetch location area data');
  }

  /// Fetch data from PokeAPI
  Future<LocationAreaResponse> _fetchFromApi(String areaIdentifier) async {
    final url = Uri.parse('$_baseUrl/location-area/$areaIdentifier');

    final response = await http.get(url).timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return LocationAreaResponse.fromJson(json);
    } else if (response.statusCode == 404) {
      throw AreaNotFoundException('Location area not found: $areaIdentifier');
    } else {
      throw ApiException(
        'API error: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  /// Clear the cache (useful for testing or memory management)
  void clearCache() {
    _cache.clear();
  }

  /// Get cache size
  int get cacheSize => _cache.length;
}

/// Exception thrown when area is not found
class AreaNotFoundException implements Exception {
  final String message;
  AreaNotFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown on API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
