import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../data/pokemon_detail_data.dart' as data;
import '../domain/pokemon_detail_repository.dart';



// ------------ LOCAL DATA SOURCE --------------

class PokemonDetailLocalDataSource {
  static const String _detailBoxName = 'pokemon_detail_cache';
  static const String _metadataBoxName = 'pokemon_detail_metadata';
  static const String _lastCacheTimeKey = 'last_cache_time';
  static const int _cacheDurationHours = 24;

  Box<String>? _detailBox;
  Box<dynamic>? _metadataBox;

  Future<void> initialize() async {
    if (_detailBox != null && _metadataBox != null) return;
    _detailBox = await Hive.openBox<String>(_detailBoxName);
    _metadataBox = await Hive.openBox<dynamic>(_metadataBoxName);
  }

  Future<void> cachePokemonDetail(int id, data.PokemonDetail detail) async {
    await _ensureInitialized();
    try {
      final jsonString = _serializePokemonDetail(detail);
      await _detailBox!.put('pokemon_$id', jsonString);
      await _metadataBox!.put('${_lastCacheTimeKey}_$id', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error caching Pokemon detail for ID $id: $e');
    }
  }

  Future<data.PokemonDetail?> getCachedPokemonDetail(int id) async {
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

  Future<bool> hasData(int id) async {
    await _ensureInitialized();
    return _detailBox!.containsKey('pokemon_$id');
  }

  Future<void> clearCache() async {
    await _ensureInitialized();
    await _detailBox!.clear();
    await _metadataBox!.clear();
  }

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

  String _serializePokemonDetail(data.PokemonDetail detail) {
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

  data.PokemonDetail _deserializePokemonDetail(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return data.PokemonDetail(
      id: map['id'] as int,
      name: map['name'] as String,
      heightMeters: (map['heightMeters'] as num).toDouble(),
      weightKg: (map['weightKg'] as num).toDouble(),
      baseExperience: map['baseExperience'] as int,
      types: (map['types'] as List).cast<String>(),
      abilities: (map['abilities'] as List)
          .map((a) => data.PokemonAbility(
        name: a['name'] as String,
        isHidden: a['isHidden'] as bool,
        shortEffect: a['shortEffect'] as String,
      ))
          .toList(),
      stats: (map['stats'] as List)
          .map((s) => data.PokemonStat(
        name: s['name'] as String,
        value: s['value'] as int,
      ))
          .toList(),
      moves: (map['moves'] as List)
          .map((m) => data.PokemonMove(
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
          .map((f) => data.PokemonFormVariant(
        id: f['id'] as int,
        name: f['name'] as String,
        displayName: f['displayName'] as String,
        pokemonId: f['pokemonId'] as int,
        spriteUrl: f['spriteUrl'] as String?,
        shinySpriteUrl: f['shinySpriteUrl'] as String?,
        types: (f['types'] as List).cast<String>(),
        isDefault: f['isDefault'] as bool,
        category: data.PokemonFormCategory.values[f['category'] as int],
      ))
          .toList(),
      evolutionChain: (map['evolutionChain'] as List)
          .map((e) => data.PokemonEvolution(
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

// ------------ REMOTE DATA SOURCE --------------

const String _pokemonDetailQuery = r'''
query PokemonDetail($id: Int!) {
  pokemon_v2_pokemon_by_pk(id: $id) {
    id
    name
    height
    weight
    base_experience
    pokemon_v2_pokemonsprites { sprites }
    pokemon_v2_pokemonforms {
      id
      name        
      form_name
      is_default
      form_order
      is_battle_only
      is_mega
      pokemon_id
      pokemon_v2_pokemonformtypes { pokemon_v2_type { name } }
      pokemon_v2_pokemonformsprites { sprites }
    }
    pokemon_v2_pokemonabilities {
      is_hidden
      pokemon_v2_ability {
        id
        name
        pokemon_v2_abilityeffecttexts {
          short_effect
          pokemon_v2_language { name }
        }
      }
    }
    pokemon_v2_pokemontypes { pokemon_v2_type { name } }
    pokemon_v2_pokemonstats(order_by: {pokemon_v2_stat: {id: asc}}) {
      base_stat
      pokemon_v2_stat { name }
    }
    pokemon_v2_pokemonmoves(order_by: {pokemon_v2_move: {name: asc}}) {
      level
      pokemon_v2_move {
        name
        pokemon_v2_type { name }
        pokemon_v2_movedamageclass { name }
        pokemon_v2_machines {
          machine_number
          pokemon_v2_item {
            id
            name
            pokemon_v2_itemsprites { sprites }
          }
          pokemon_v2_versiongroup { name generation_id }
        }
      }
      pokemon_v2_movelearnmethod { name }
      version_group_id
    }
    pokemon_v2_pokemonspecy {
      id
      name
      pokemon_v2_pokemonegggroups {
        pokemon_v2_egggroup { name }
      }
      pokemon_v2_pokemons {
        id
        name
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemonforms {
          id
          name
          form_name
          is_default
          is_mega
          pokemon_v2_pokemonformtypes { pokemon_v2_type { name } }
          pokemon_v2_pokemonformsprites { sprites }
        }
      }
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemonevolutions {
            min_level
            pokemon_v2_evolutiontrigger { name }
            pokemon_v2_item { name }
          }
          pokemon_v2_pokemons(limit: 1) {
            pokemon_v2_pokemontypes { pokemon_v2_type { name } }
          }
        }
      }
    }
  }
}
''';

const String _formDetailQuery = r'''
query FormDetail($pokemonId: Int!) {
  pokemon_v2_pokemon_by_pk(id: $pokemonId) {
    id
    name
    height
    weight
    base_experience
    pokemon_v2_pokemonsprites { sprites }
    pokemon_v2_pokemonabilities {
      is_hidden
      pokemon_v2_ability {
        id
        name
        pokemon_v2_abilityeffecttexts {
          short_effect
          pokemon_v2_language { name }
        }
      }
    }
    pokemon_v2_pokemontypes { pokemon_v2_type { name } }
    pokemon_v2_pokemonstats(order_by: {pokemon_v2_stat: {id: asc}}) {
      base_stat
      pokemon_v2_stat { name }
    }
    pokemon_v2_pokemonmoves(order_by: {pokemon_v2_move: {name: asc}}) {
      level
      pokemon_v2_move {
        name
        pokemon_v2_type { name }
        pokemon_v2_movedamageclass { name }
        pokemon_v2_machines {
          machine_number
          pokemon_v2_item {
            id
            name
            pokemon_v2_itemsprites { sprites }
          }
          pokemon_v2_versiongroup { name generation_id }
        }
      }
      pokemon_v2_movelearnmethod { name }
      version_group_id
    }
    pokemon_v2_pokemonforms {
      id
      name
      form_name
      is_default
      is_mega
      pokemon_v2_pokemonformtypes { pokemon_v2_type { name } }
      pokemon_v2_pokemonformsprites { sprites }
    }
    pokemon_v2_pokemonspecy {
      id
      name
      pokemon_v2_pokemonegggroups { pokemon_v2_egggroup { name } }
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemonevolutions {
            min_level
            pokemon_v2_evolutiontrigger { name }
            pokemon_v2_item { name }
          }
          pokemon_v2_pokemons(limit: 1) {
            pokemon_v2_pokemontypes { pokemon_v2_type { name } }
          }
        }
      }
    }
  }
}
''';

class PokemonDetailRemoteDataSource {
  final GraphQLClient _client;
  static const int _queryTimeoutSeconds = 30;
  PokemonDetailRemoteDataSource(this._client);

  Future<data.PokemonDetailDTO> getPokemonDetail(int id) async {
    try {
      final result = await _client
          .query(
        QueryOptions(
          document: gql(_pokemonDetailQuery),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.cacheFirst,
        ),
      )
          .timeout(const Duration(seconds: _queryTimeoutSeconds));
      if (result.hasException) {
        throw data.PokemonDetailException(
          message: _parseGraphQLException(result.exception!),
          type: data.PokemonDetailExceptionType.notFound,
        );
      }
      final resData = result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;
      if (resData == null) {
        throw data.PokemonDetailException(
          message: 'Pokemon not found',
          type: data.PokemonDetailExceptionType.notFound,
        );
      }
      return data.PokemonDetailDTO.fromGraphQL(resData);
    } catch (e) {
      if (e is data.PokemonDetailException) rethrow;
      throw data.PokemonDetailException(
        message: 'Connection error: ${e.toString()}',
        type: data.PokemonDetailExceptionType.noConnection,
      );
    }
  }

  Future<data.PokemonDetailDTO> getFormDetail(int pokemonId) async {
    try {
      final result = await _client
          .query(
        QueryOptions(
          document: gql(_formDetailQuery),
          variables: {'pokemonId': pokemonId},
          fetchPolicy: FetchPolicy.cacheFirst,
        ),
      )
          .timeout(const Duration(seconds: _queryTimeoutSeconds));
      if (result.hasException) {
        throw data.PokemonDetailException(
          message: _parseGraphQLException(result.exception!),
          type: data.PokemonDetailExceptionType.notFound,
        );
      }
      final resData = result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;
      if (resData == null) {
        throw data.PokemonDetailException(
          message: 'Pokemon form not found',
          type: data.PokemonDetailExceptionType.notFound,
        );
      }
      return data.PokemonDetailDTO.fromGraphQL(resData);
    } catch (e) {
      if (e is data.PokemonDetailException) rethrow;
      throw data.PokemonDetailException(
        message: 'Connection error: ${e.toString()}',
        type: data.PokemonDetailExceptionType.noConnection,
      );
    }
  }

  String _parseGraphQLException(OperationException exception) {
    if (exception.linkException != null) return 'Server connection error';
    if (exception.graphqlErrors.isNotEmpty) return exception.graphqlErrors.first.message;
    return 'Unknown query error';
  }

  data.PokemonDetailExceptionType _getExceptionType(OperationException exception) {
    if (exception.linkException != null) return data.PokemonDetailExceptionType.noConnection;
    final errorMessage =
    exception.graphqlErrors.isEmpty ? '' : exception.graphqlErrors.first.message;
    if (errorMessage.contains('rate limit') ||
        errorMessage.contains('too many requests')) {
      return data.PokemonDetailExceptionType.rateLimit;
    }
    return data.PokemonDetailExceptionType.serverError;
  }
}

// ---------------- REPOSITORY ------------------

class PokemonDetailRepositoryImpl implements PokemonDetailRepository {
  final PokemonDetailRemoteDataSource _remoteDataSource;
  final PokemonDetailLocalDataSource _localDataSource;

  PokemonDetailRepositoryImpl({
    required PokemonDetailRemoteDataSource remoteDataSource,
    required PokemonDetailLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<data.PokemonDetail> getPokemonDetail(int id) async {
    try {
      final dto = await _remoteDataSource.getPokemonDetail(id);
      final entity = dto.toEntity() as data.PokemonDetail;
      await _localDataSource.cachePokemonDetail(id, entity);
      return entity;
    } on data.PokemonDetailException catch (e) {
      if (e.type == data.PokemonDetailExceptionType.noConnection ||
          e.type == data.PokemonDetailExceptionType.timeout) {
        final cached = await _localDataSource.getCachedPokemonDetail(id);
        if (cached != null) {
          return cached;
        }
      }
      rethrow;
    }
  }

  @override
  Future<data.PokemonDetail> getFormDetail(int pokemonId) async {
    try {
      final dto = await _remoteDataSource.getFormDetail(pokemonId);
      final entity = dto.toEntity() as data.PokemonDetail;
      await _localDataSource.cachePokemonDetail(pokemonId, entity);
      return entity;
    } on data.PokemonDetailException catch (e) {
      if (e.type == data.PokemonDetailExceptionType.noConnection ||
          e.type == data.PokemonDetailExceptionType.timeout) {
        final cached = await _localDataSource.getCachedPokemonDetail(pokemonId);
        if (cached != null) {
          return cached;
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  @override
  Future<bool> hasCachedData(int id) async {
    return await _localDataSource.hasData(id);
  }

  @override
  Future<data.PokemonDetail?> getCachedDetail(int id) async {
    return await _localDataSource.getCachedPokemonDetail(id);
  }
}