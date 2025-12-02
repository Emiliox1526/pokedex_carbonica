import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pokemon_list/data/pokemon_dto.dart';
import '../../pokemon_list/domain/pokemon.dart';

/// Local data source for storing favorite Pokemon data with Hive.
///
/// This class manages the persistence of favorite Pokemon, storing
/// complete Pokemon data (not just IDs) for offline access.
class FavoritesLocalDataSource {
  /// Name of the Hive box for favorite Pokemon.
  static const String _favoritesBoxName = 'favorites_pokemon_cache';

  /// Key for SharedPreferences to store favorite IDs (for compatibility).
  static const String _prefsKeyFavorites = 'favorite_pokemon_ids';

  /// Hive box for storing favorite Pokemon data.
  Box<PokemonDTO>? _favoritesBox;

  /// Initializes the data source.
  ///
  /// Must be called before using any other method.
  Future<void> initialize() async {
    if (_favoritesBox != null) return;

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PokemonDTOAdapter());
    }

    _favoritesBox = await Hive.openBox<PokemonDTO>(_favoritesBoxName);
  }

  /// Adds a Pokemon to favorites.
  ///
  /// Stores both the complete Pokemon data in Hive and the ID in SharedPreferences.
  Future<void> addFavorite(Pokemon pokemon) async {
    await _ensureInitialized();

    // Store complete Pokemon data in Hive
    final dto = PokemonDTO(
      id: pokemon.id,
      name: pokemon.name,
      types: pokemon.types,
      imageUrl: pokemon.imageUrl,
      abilities: pokemon.abilities,
    );
    await _favoritesBox!.put('favorite_${pokemon.id}', dto);

    // Also update SharedPreferences for compatibility
    await _updateSharedPreferences(pokemon.id, add: true);
  }

  /// Removes a Pokemon from favorites.
  Future<void> removeFavorite(int pokemonId) async {
    await _ensureInitialized();

    // Remove from Hive
    await _favoritesBox!.delete('favorite_$pokemonId');

    // Also update SharedPreferences for compatibility
    await _updateSharedPreferences(pokemonId, add: false);
  }

  /// Checks if a Pokemon is a favorite.
  Future<bool> isFavorite(int pokemonId) async {
    await _ensureInitialized();
    return _favoritesBox!.containsKey('favorite_$pokemonId');
  }

  /// Gets all favorite Pokemon.
  Future<List<Pokemon>> getAllFavorites() async {
    await _ensureInitialized();

    final favorites = <Pokemon>[];
    for (final key in _favoritesBox!.keys) {
      final dto = _favoritesBox!.get(key);
      if (dto != null) {
        favorites.add(dto.toEntity());
      }
    }

    // Sort by ID
    favorites.sort((a, b) => a.id.compareTo(b.id));
    return favorites;
  }

  /// Gets the count of favorite Pokemon.
  Future<int> getFavoritesCount() async {
    await _ensureInitialized();
    return _favoritesBox!.length;
  }

  /// Toggles a Pokemon's favorite status.
  ///
  /// Returns true if the Pokemon is now a favorite, false if removed.
  Future<bool> toggleFavorite(Pokemon pokemon) async {
    final isFav = await isFavorite(pokemon.id);
    if (isFav) {
      await removeFavorite(pokemon.id);
      return false;
    } else {
      await addFavorite(pokemon);
      return true;
    }
  }

  /// Gets all favorite IDs (for compatibility with existing code).
  Future<List<int>> getFavoriteIds() async {
    await _ensureInitialized();

    final ids = <int>[];
    for (final key in _favoritesBox!.keys) {
      final dto = _favoritesBox!.get(key);
      if (dto != null) {
        ids.add(dto.id);
      }
    }
    return ids..sort();
  }

  /// Clears all favorites.
  Future<void> clearAllFavorites() async {
    await _ensureInitialized();
    await _favoritesBox!.clear();

    // Also clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyFavorites);
  }

  /// Migrates favorites from SharedPreferences to Hive.
  ///
  /// This is useful for existing users who have favorites stored only in
  /// SharedPreferences. Call this once during app initialization.
  Future<void> migrateFromSharedPreferences() async {
    await _ensureInitialized();

    try {
      final prefs = await SharedPreferences.getInstance();
      final favIds = prefs.getStringList(_prefsKeyFavorites) ?? [];

      // If there are IDs in SharedPreferences but not in Hive, we can't
      // fully migrate without the Pokemon data. The data will be added
      // when the user views the detail screen of each favorite.
      for (final idStr in favIds) {
        final id = int.tryParse(idStr);
        if (id != null && !_favoritesBox!.containsKey('favorite_$id')) {
          // Create a placeholder - will be updated with full data when user
          // views the Pokemon detail screen
          // We don't create placeholders here - favorites will sync when
          // users view Pokemon details
        }
      }
    } catch (_) {
      // Ignore migration errors
    }
  }

  /// Updates SharedPreferences with the favorite ID.
  Future<void> _updateSharedPreferences(int pokemonId, {required bool add}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList(_prefsKeyFavorites) ?? [];

      if (add) {
        if (!favs.contains(pokemonId.toString())) {
          favs.add(pokemonId.toString());
        }
      } else {
        favs.remove(pokemonId.toString());
      }

      await prefs.setStringList(_prefsKeyFavorites, favs);
    } catch (_) {
      // Ignore SharedPreferences errors
    }
  }

  /// Ensures the data source is initialized.
  Future<void> _ensureInitialized() async {
    if (_favoritesBox == null) {
      await initialize();
    }
  }
}
