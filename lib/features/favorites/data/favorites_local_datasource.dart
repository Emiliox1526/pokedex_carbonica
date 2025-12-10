import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pokemon_list/data/pokemon_data.dart'; // <-- IMPORT correcto

class FavoritesLocalDataSource {
  static const String _favoritesBoxName = 'favorites_pokemon_cache';
  static const String _prefsKeyFavorites = 'favorite_pokemon_ids';

  Box<PokemonDTO>? _favoritesBox;

  Future<void> initialize() async {
    if (_favoritesBox != null) return;
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PokemonDTOAdapter());
    }
    _favoritesBox = await Hive.openBox<PokemonDTO>(_favoritesBoxName);
  }

  Future<void> addFavorite(Pokemon pokemon) async {
    await _ensureInitialized();
    final dto = PokemonDTO(
      id: pokemon.id,
      name: pokemon.name,
      types: pokemon.types,
      imageUrl: pokemon.imageUrl,
      abilities: pokemon.abilities,
    );
    await _favoritesBox!.put('favorite_${pokemon.id}', dto);
    await _updateSharedPreferences(pokemon.id, add: true);
  }

  Future<void> removeFavorite(int pokemonId) async {
    await _ensureInitialized();
    await _favoritesBox!.delete('favorite_$pokemonId');
    await _updateSharedPreferences(pokemonId, add: false);
  }

  Future<bool> isFavorite(int pokemonId) async {
    await _ensureInitialized();
    return _favoritesBox!.containsKey('favorite_$pokemonId');
  }

  Future<List<Pokemon>> getAllFavorites() async {
    await _ensureInitialized();
    final favorites = <Pokemon>[];
    for (final key in _favoritesBox!.keys) {
      final dto = _favoritesBox!.get(key);
      if (dto != null) {
        favorites.add(dto.toEntity());
      }
    }
    favorites.sort((a, b) => a.id.compareTo(b.id));
    return favorites;
  }

  Future<int> getFavoritesCount() async {
    await _ensureInitialized();
    return _favoritesBox!.length;
  }

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

  Future<void> clearAllFavorites() async {
    await _ensureInitialized();
    await _favoritesBox!.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyFavorites);
  }

  Future<void> migrateFromSharedPreferences() async {
    await _ensureInitialized();
    try {
      final prefs = await SharedPreferences.getInstance();
      final favIds = prefs.getStringList(_prefsKeyFavorites) ?? [];
      for (final idStr in favIds) {
        final id = int.tryParse(idStr);
        if (id != null && !_favoritesBox!.containsKey('favorite_$id')) {
          // Placeholder para migración: no crear entradas sin info.
        }
      }
    } catch (_) {
      // Ignorar errores de migración
    }
  }

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
      // Ignorar errores de SharedPreferences
    }
  }

  Future<void> _ensureInitialized() async {
    if (_favoritesBox == null) {
      await initialize();
    }
  }
}