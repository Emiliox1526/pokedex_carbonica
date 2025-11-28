import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/detail/pokemon_detail.dart';
import '../../../domain/entities/detail/pokemon_ability.dart';
import '../../../domain/entities/detail/pokemon_stat.dart';
import '../../../domain/entities/detail/pokemon_move.dart';
import '../../../domain/entities/detail/pokemon_form_variant.dart';
import '../../../domain/entities/detail/pokemon_evolution.dart';

/// Local data source for caching Pokemon detail data with Hive.
class PokemonDetailLocalDataSource {
  /// Name of the Hive box for Pokemon detail cache.
  static const String _detailBoxName = 'pokemon_detail_cache';

  /// Name of the Hive box for metadata.
  static const String _metadataBoxName = 'pokemon_detail_metadata';

  /// Key for last cache timestamp.
  static const String _lastCacheTimeKey = 'last_cache_time';

  /// Cache duration in hours.
  static const int _cacheDurationHours = 24;

  Box<String>? _detailBox;
  Box<dynamic>? _metadataBox;

  /// Initializes the local data source.
  Future<void> initialize() async {
    if (_detailBox != null && _metadataBox != null) return;

    _detailBox = await Hive.openBox<String>(_detailBoxName);
    _metadataBox = await Hive.openBox<dynamic>(_metadataBoxName);
  }

  /// Caches Pokemon detail data.
  Future<void> cachePokemonDetail(int id, PokemonDetail detail) async {
    await _ensureInitialized();

    try {
      final jsonString = _serializePokemonDetail(detail);
      await _detailBox!.put('pokemon_$id', jsonString);
      await _metadataBox!.put(
        '${_lastCacheTimeKey}_$id',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error caching Pokemon detail for ID $id: $e');
    }
  }

  /// Gets cached Pokemon detail data.
  Future<PokemonDetail?> getCachedPokemonDetail(int id) async {
    await _ensureInitialized();

    if (!await isCacheValid(id)) return null;

    try {
      final jsonString = _detailBox!.get('pokemon_$id');
      if (jsonString == null) return null;

      return _deserializePokemonDetail(jsonString);
    } catch (e) {
      debugPrint('Error reading cached Pokemon detail for ID $id: $e');
      return null;
    }
  }

  /// Checks if cache is valid for a Pokemon.
  Future<bool> isCacheValid(int id) async {
    await _ensureInitialized();

    final lastCacheTime =
        _metadataBox!.get('${_lastCacheTimeKey}_$id') as int?;
    if (lastCacheTime == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(lastCacheTime);
    final now = DateTime.now();
    final difference = now.difference(cacheDate);

    return difference.inHours < _cacheDurationHours;
  }

  /// Checks if there is any cached data for a Pokemon.
  Future<bool> hasData(int id) async {
    await _ensureInitialized();
    return _detailBox!.containsKey('pokemon_$id');
  }

  /// Clears all cached detail data.
  Future<void> clearCache() async {
    await _ensureInitialized();
    await _detailBox!.clear();
    await _metadataBox!.clear();
  }

  /// Clears cached data for a specific Pokemon.
  Future<void> clearCacheForPokemon(int id) async {
    await _ensureInitialized();
    await _detailBox!.delete('pokemon_$id');
    await _metadataBox!.delete('${_lastCacheTimeKey}_$id');
  }

  Future<void> _ensureInitialized() async {
    if (_detailBox == null || _metadataBox == null) {
      await initialize();
    }
  }

  // Serialization/deserialization methods

  String _serializePokemonDetail(PokemonDetail detail) {
    final map = {
      'id': detail.id,
      'name': detail.name,
      'heightMeters': detail.heightMeters,
      'weightKg': detail.weightKg,
      'baseExperience': detail.baseExperience,
      'types': detail.types,
      'abilities': detail.abilities
          .map((a) => {
                'name': a.name,
                'isHidden': a.isHidden,
                'shortEffect': a.shortEffect,
              })
          .toList(),
      'stats': detail.stats
          .map((s) => {
                'name': s.name,
                'value': s.value,
              })
          .toList(),
      'moves': detail.moves
          .map((m) => {
                'name': m.name,
                'type': m.type,
                'damageClass': m.damageClass,
                'level': m.level,
                'learnMethod': m.learnMethod,
                'tmName': m.tmName,
                'tmNumber': m.tmNumber,
                'tmSpriteUrl': m.tmSpriteUrl,
              })
          .toList(),
      'forms': detail.forms
          .map((f) => {
                'id': f.id,
                'name': f.name,
                'displayName': f.displayName,
                'pokemonId': f.pokemonId,
                'spriteUrl': f.spriteUrl,
                'shinySpriteUrl': f.shinySpriteUrl,
                'types': f.types,
                'isDefault': f.isDefault,
                'category': f.category.index,
              })
          .toList(),
      'evolutionChain': detail.evolutionChain
          .map((e) => {
                'speciesId': e.speciesId,
                'name': e.name,
                'minLevel': e.minLevel,
                'trigger': e.trigger,
                'item': e.item,
                'types': e.types,
              })
          .toList(),
      'defaultSpriteUrl': detail.defaultSpriteUrl,
      'shinySpriteUrl': detail.shinySpriteUrl,
      'eggGroups': detail.eggGroups,
      'speciesId': detail.speciesId,
      'speciesName': detail.speciesName,
    };
    return json.encode(map);
  }

  PokemonDetail _deserializePokemonDetail(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;

    return PokemonDetail(
      id: map['id'] as int,
      name: map['name'] as String,
      heightMeters: (map['heightMeters'] as num).toDouble(),
      weightKg: (map['weightKg'] as num).toDouble(),
      baseExperience: map['baseExperience'] as int,
      types: (map['types'] as List).cast<String>(),
      abilities: (map['abilities'] as List)
          .map((a) => PokemonAbility(
                name: a['name'] as String,
                isHidden: a['isHidden'] as bool,
                shortEffect: a['shortEffect'] as String,
              ))
          .toList(),
      stats: (map['stats'] as List)
          .map((s) => PokemonStat(
                name: s['name'] as String,
                value: s['value'] as int,
              ))
          .toList(),
      moves: (map['moves'] as List)
          .map((m) => PokemonMove(
                name: m['name'] as String,
                type: m['type'] as String,
                damageClass: m['damageClass'] as String,
                level: m['level'] as int?,
                learnMethod: m['learnMethod'] as String,
                tmName: m['tmName'] as String?,
                tmNumber: m['tmNumber'] as int?,
                tmSpriteUrl: m['tmSpriteUrl'] as String?,
              ))
          .toList(),
      forms: (map['forms'] as List)
          .map((f) => PokemonFormVariant(
                id: f['id'] as int,
                name: f['name'] as String,
                displayName: f['displayName'] as String,
                pokemonId: f['pokemonId'] as int,
                spriteUrl: f['spriteUrl'] as String?,
                shinySpriteUrl: f['shinySpriteUrl'] as String?,
                types: (f['types'] as List).cast<String>(),
                isDefault: f['isDefault'] as bool,
                category: PokemonFormCategory.values[f['category'] as int],
              ))
          .toList(),
      evolutionChain: (map['evolutionChain'] as List)
          .map((e) => PokemonEvolution(
                speciesId: e['speciesId'] as int,
                name: e['name'] as String,
                minLevel: e['minLevel'] as int?,
                trigger: e['trigger'] as String?,
                item: e['item'] as String?,
                types: (e['types'] as List).cast<String>(),
              ))
          .toList(),
      defaultSpriteUrl: map['defaultSpriteUrl'] as String?,
      shinySpriteUrl: map['shinySpriteUrl'] as String?,
      eggGroups: (map['eggGroups'] as List?)?.cast<String>() ?? [],
      speciesId: map['speciesId'] as int?,
      speciesName: map['speciesName'] as String?,
    );
  }
}
