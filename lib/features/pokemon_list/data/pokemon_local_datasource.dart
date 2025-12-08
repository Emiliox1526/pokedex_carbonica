import 'package:hive_flutter/hive_flutter.dart';

import 'pokemon_dto.dart';
import '../domain/pokemon_repository.dart';

/// Data source local para persistencia de Pokémon con Hive.
/// 
/// Esta clase maneja el almacenamiento y recuperación de datos de Pokémon
/// en el dispositivo local, permitiendo acceso offline y mejorando el
/// rendimiento mediante cache.
class PokemonLocalDataSource {
  /// Nombre de la caja de Hive para Pokémon.
  static const String _pokemonBoxName = 'pokemon_cache';
  
  /// Nombre de la caja de Hive para metadatos.
  static const String _metadataBoxName = 'pokemon_metadata';
  
  /// Clave para almacenar el timestamp del último cache.
  static const String _lastCacheTimeKey = 'last_cache_time';
  
  /// Clave para almacenar el conteo total de Pokémon.
  static const String _totalCountKey = 'total_count';

  /// Duración del cache en horas.
  static const int _cacheDurationHours = 24;

  /// Caja de Hive para Pokémon.
  Box<PokemonDTO>? _pokemonBox;
  
  /// Caja de Hive para metadatos.
  Box<dynamic>? _metadataBox;

  /// Inicializa el data source local.
  /// 
  /// Debe llamarse antes de usar cualquier método del data source.
  Future<void> initialize() async {
    if (_pokemonBox != null && _metadataBox != null) return;
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PokemonDTOAdapter());
    }
    
    _pokemonBox = await Hive.openBox<PokemonDTO>(_pokemonBoxName);
    _metadataBox = await Hive.openBox<dynamic>(_metadataBoxName);
  }

  /// Guarda una lista de Pokémon en el cache local.
  /// 
  /// [pokemons] lista de Pokémon a guardar.
  /// [filter] filtro usado para identificar la cache.
  Future<void> cachePokemonList(
    List<PokemonDTO> pokemons,
    PokemonFilter filter,
  ) async {
    await _ensureInitialized();
    
    final cacheKey = _buildCacheKey(filter);
    
    // Guardar cada Pokémon individualmente
    for (final pokemon in pokemons) {
      await _pokemonBox!.put('pokemon_${pokemon.id}', pokemon);
    }
    
    // Guardar la lista de IDs para este filtro/página
    final ids = pokemons.map((p) => p.id).toList();
    await _metadataBox!.put('ids_$cacheKey', ids);
    
    // Actualizar timestamp del cache
    await _metadataBox!.put(
      _lastCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Obtiene la lista de Pokémon del cache local.
  /// 
  /// [filter] filtro usado para identificar la cache.
  /// 
  /// Retorna null si no hay datos en cache o si el cache ha expirado.
  Future<List<PokemonDTO>?> getCachedPokemonList(PokemonFilter filter) async {
    await _ensureInitialized();
    
    if (!await isCacheValid()) return null;
    
    final cacheKey = _buildCacheKey(filter);
    final ids = _metadataBox!.get('ids_$cacheKey') as List<dynamic>?;
    
    if (ids == null || ids.isEmpty) return null;
    
    final pokemons = <PokemonDTO>[];
    for (final id in ids) {
      final pokemon = _pokemonBox!.get('pokemon_$id');
      if (pokemon != null) {
        pokemons.add(pokemon);
      }
    }
    
    return pokemons.isEmpty ? null : pokemons;
  }

  /// Guarda el conteo total de Pokémon para un filtro.
  Future<void> cacheTotalCount(int count, PokemonFilter filter) async {
    await _ensureInitialized();
    final key = '${_totalCountKey}_${_buildFilterKey(filter)}';
    await _metadataBox!.put(key, count);
  }

  /// Obtiene el conteo total de Pokémon del cache.
  Future<int?> getCachedTotalCount(PokemonFilter filter) async {
    await _ensureInitialized();
    final key = '${_totalCountKey}_${_buildFilterKey(filter)}';
    return _metadataBox!.get(key) as int?;
  }

  /// Verifica si el cache es válido (no ha expirado).
  Future<bool> isCacheValid() async {
    await _ensureInitialized();
    
    final lastCacheTime = _metadataBox!.get(_lastCacheTimeKey) as int?;
    if (lastCacheTime == null) return false;
    
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(lastCacheTime);
    final now = DateTime.now();
    final difference = now.difference(cacheDate);
    
    return difference.inHours < _cacheDurationHours;
  }

  /// Verifica si hay datos en el cache.
  Future<bool> hasData() async {
    await _ensureInitialized();
    return _pokemonBox!.isNotEmpty;
  }

  /// Limpia todo el cache local.
  Future<void> clearCache() async {
    await _ensureInitialized();
    await _pokemonBox!.clear();
    await _metadataBox!.clear();
  }

  /// Asegura que el data source esté inicializado.
  Future<void> _ensureInitialized() async {
    if (_pokemonBox == null || _metadataBox == null) {
      await initialize();
    }
  }

  /// Construye una clave de cache única para el filtro y página.
  String _buildCacheKey(PokemonFilter filter) {
    return '${_buildFilterKey(filter)}_page${filter.page}';
  }

  /// Construye una clave única para el filtro (sin página).
  String _buildFilterKey(PokemonFilter filter) {
    final parts = <String>[];
    
    if (filter.searchText != null && filter.searchText!.isNotEmpty) {
      parts.add('search:${filter.searchText}');
    }
    if (filter.generation != null) {
      parts.add('gen:${filter.generation}');
    }
    if (filter.types.isNotEmpty) {
      parts.add('types:${filter.types.toList()..sort()}');
    }
    
    return parts.isEmpty ? 'all' : parts.join('_');
  }
}
