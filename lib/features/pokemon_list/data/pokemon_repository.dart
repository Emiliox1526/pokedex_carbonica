// Implementación de repositorio y datasources para acceso local y remoto.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'pokemon_data.dart';

// ---------- DataSource Local ----------
class PokemonLocalDataSource {
  static const String _pokemonBoxName = 'pokemon_cache';
  static const String _metadataBoxName = 'pokemon_metadata';
  static const String _lastCacheTimeKey = 'last_cache_time';
  static const String _totalCountKey = 'total_count';
  static const int _cacheDurationHours = 24;

  Box<PokemonDTO>? _pokemonBox;
  Box<dynamic>? _metadataBox;

  Future<void> initialize() async {
    if (_pokemonBox != null && _metadataBox != null) return;
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PokemonDTOAdapter());
    _pokemonBox = await Hive.openBox<PokemonDTO>(_pokemonBoxName);
    _metadataBox = await Hive.openBox<dynamic>(_metadataBoxName);
  }

  Future<void> cachePokemonList(List<PokemonDTO> pokemons, PokemonFilter filter) async {
    await _ensureInitialized();
    final cacheKey = _buildCacheKey(filter);
    for (final pokemon in pokemons) {
      await _pokemonBox!.put('pokemon_${pokemon.id}', pokemon);
    }
    final ids = pokemons.map((p) => p.id).toList();
    await _metadataBox!.put('ids_$cacheKey', ids);
    await _metadataBox!.put(_lastCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<PokemonDTO>?> getCachedPokemonList(PokemonFilter filter) async {
    await _ensureInitialized();
    if (!await isCacheValid()) return null;
    final cacheKey = _buildCacheKey(filter);
    final ids = _metadataBox!.get('ids_$cacheKey') as List<dynamic>?;
    if (ids == null || ids.isEmpty) return null;
    final pokemons = <PokemonDTO>[];
    for (final id in ids) {
      final pokemon = _pokemonBox!.get('pokemon_$id');
      if (pokemon != null) pokemons.add(pokemon);
    }
    return pokemons.isEmpty ? null : pokemons;
  }

  Future<void> cacheTotalCount(int count, PokemonFilter filter) async {
    await _ensureInitialized();
    final key = '${_totalCountKey}_${_buildFilterKey(filter)}';
    await _metadataBox!.put(key, count);
  }

  Future<int?> getCachedTotalCount(PokemonFilter filter) async {
    await _ensureInitialized();
    final key = '${_totalCountKey}_${_buildFilterKey(filter)}';
    return _metadataBox!.get(key) as int?;
  }

  Future<bool> isCacheValid() async {
    await _ensureInitialized();
    final lastCacheTime = _metadataBox!.get(_lastCacheTimeKey) as int?;
    if (lastCacheTime == null) return false;
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(lastCacheTime);
    return DateTime.now().difference(cacheDate).inHours < _cacheDurationHours;
  }

  Future<bool> hasData() async {
    await _ensureInitialized();
    return _pokemonBox!.isNotEmpty;
  }

  Future<void> clearCache() async {
    await _ensureInitialized();
    await _pokemonBox!.clear();
    await _metadataBox!.clear();
  }

  Future<void> _ensureInitialized() async {
    if (_pokemonBox == null || _metadataBox == null) await initialize();
  }

  String _buildCacheKey(PokemonFilter filter) => '${_buildFilterKey(filter)}_page${filter.page}';
  String _buildFilterKey(PokemonFilter filter) {
    final parts = <String>[];
    if (filter.searchText != null && filter.searchText!.isNotEmpty)
      parts.add('search:${filter.searchText}');
    if (filter.generation != null) parts.add('gen:${filter.generation}');
    if (filter.types.isNotEmpty) parts.add('types:${filter.types.toList()..sort()}');
    return parts.isEmpty ? 'all' : parts.join('_');
  }
}

// ---------- DataSource Remoto ----------
const String _paginatedPokemonListQuery = r'''
  query PokemonList($limit: Int!, $offset: Int!, $where: pokemon_v2_pokemon_bool_exp) {
    pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: {id: asc}, where: $where) {
      id
      name
      pokemon_v2_pokemonabilities(limit: 2) { pokemon_v2_ability { name } }
      pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      pokemon_v2_pokemonsprites { sprites }
    }
  }
''';
const String _pokemonCountQuery = r'''
  query PokemonCount($where: pokemon_v2_pokemon_bool_exp) {
    pokemon_v2_pokemon_aggregate(where: $where) { aggregate { count } }
  }
''';
const String _pokemonForGameQuery = r'''
  query PokemonForGame($limit: Int!, $offset: Int!) {
    pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: {id: asc}) {
      id
      name
      pokemon_v2_pokemonabilities(limit: 2) { pokemon_v2_ability { name } }
      pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      pokemon_v2_pokemonsprites { sprites }
    }
  }
''';

class PokemonRemoteDataSource {
  final GraphQLClient _client;
  static const int _queryTimeoutSeconds = 30;
  PokemonRemoteDataSource(this._client);

  Future<List<PokemonDTO>> getPokemonList(PokemonFilter filter) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_paginatedPokemonListQuery),
          variables: {
            'limit': filter.pageSize,
            'offset': filter.offset,
            'where': _buildWhereClause(filter),
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      ).timeout(const Duration(seconds: _queryTimeoutSeconds));
      if (result.hasException) {
        throw PokemonRemoteException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }
      final data = result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [];
      return data.map((e) => PokemonDTO.fromGraphQL(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      if (e is PokemonRemoteException) rethrow;
      throw PokemonRemoteException(
        message: 'Error de conexión: ${e.toString()}',
        type: PokemonRemoteExceptionType.noConnection,
      );
    }
  }

  Future<int> getTotalPokemonCount(PokemonFilter filter) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_pokemonCountQuery),
          variables: {'where': _buildWhereClause(filter)},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      ).timeout(const Duration(seconds: _queryTimeoutSeconds));
      if (result.hasException) {
        throw PokemonRemoteException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }
      return result.data?['pokemon_v2_pokemon_aggregate']?['aggregate']?['count'] as int? ?? 0;
    } catch (e) {
      if (e is PokemonRemoteException) rethrow;
      throw PokemonRemoteException(
        message: 'Error al obtener conteo: ${e.toString()}',
        type: PokemonRemoteExceptionType.noConnection,
      );
    }
  }

  Future<List<PokemonDTO>> getPokemonForGame(int count, {int offset = 0}) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_pokemonForGameQuery),
          variables: {'limit': count, 'offset': offset},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      ).timeout(const Duration(seconds: _queryTimeoutSeconds));
      if (result.hasException) {
        throw PokemonRemoteException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }
      final data = result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [];
      return data.map((e) => PokemonDTO.fromGraphQL(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      if (e is PokemonRemoteException) rethrow;
      throw PokemonRemoteException(
        message: 'Error al obtener Pokémon para el juego: ${e.toString()}',
        type: PokemonRemoteExceptionType.noConnection,
      );
    }
  }

  Map<String, dynamic>? _buildWhereClause(PokemonFilter filter) {
    final List<Map<String, dynamic>> andConditions = [];
    if (filter.searchText != null && filter.searchText!.isNotEmpty) {
      final searchText = filter.searchText!.toLowerCase().trim();
      final parsedId = int.tryParse(searchText);
      final List<Map<String, dynamic>> orConditions = [
        {'name': {'_ilike': '%$searchText%'}}
      ];
      if (parsedId != null) {
        orConditions.add({'id': {'_eq': parsedId}});
      }
      andConditions.add({'_or': orConditions});
    }
    if (filter.generation != null) {
      final start = _startIdForGeneration(filter.generation!);
      final end = _endIdForGeneration(filter.generation!);
      andConditions.add({'id': {'_gte': start, '_lte': end}});
    }
    if (filter.types.isNotEmpty) {
      andConditions.add({
        'pokemon_v2_pokemontypes': {
          'pokemon_v2_type': {
            'name': {'_in': filter.types.toList()},
          },
        },
      });
    }
    if (andConditions.isEmpty) return null;
    if (andConditions.length == 1) return andConditions.first;
    return {'_and': andConditions};
  }

  int _startIdForGeneration(int gen) {
    const startIds = [1, 152, 252, 387, 494, 650, 722, 810, 906];
    return gen >= 1 && gen <= startIds.length ? startIds[gen - 1] : 1;
  }

  int _endIdForGeneration(int gen) {
    const endIds = [151, 251, 386, 493, 649, 721, 809, 905, 1025];
    return gen >= 1 && gen <= endIds.length ? endIds[gen - 1] : 1025;
  }

  String _parseGraphQLException(OperationException exception) {
    if (exception.linkException != null) return 'Error de conexión con el servidor';
    if (exception.graphqlErrors.isNotEmpty) return exception.graphqlErrors.first.message;
    return 'Error desconocido en la consulta';
  }

  PokemonRemoteExceptionType _getExceptionType(OperationException exception) {
    if (exception.linkException != null) return PokemonRemoteExceptionType.noConnection;
    final errorMessage = exception.graphqlErrors.isEmpty ? '' : exception.graphqlErrors.first.message;
    if (errorMessage.contains('rate limit') || errorMessage.contains('too many requests')) {
      return PokemonRemoteExceptionType.rateLimit;
    }
    return PokemonRemoteExceptionType.serverError;
  }
}

// ---------- Repositorio ----------
class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource _remoteDataSource;
  final PokemonLocalDataSource _localDataSource;
  final Connectivity _connectivity;
  static const int pageSize = 20;

  PokemonRepositoryImpl({
    required PokemonRemoteDataSource remoteDataSource,
    required PokemonLocalDataSource localDataSource,
    Connectivity? connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity ?? Connectivity();

  @override
  Future<PaginatedPokemonList> getPokemonList(PokemonFilter filter) async {
    final normalizedFilter = filter.copyWith(pageSize: pageSize);
    final connectivityResult = await _connectivity.checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;

    if (hasConnection) {
      try {
        final remotePokemon = await _remoteDataSource.getPokemonList(normalizedFilter);
        final totalCount = await _remoteDataSource.getTotalPokemonCount(normalizedFilter);
        await _localDataSource.cachePokemonList(remotePokemon, normalizedFilter);
        await _localDataSource.cacheTotalCount(totalCount, normalizedFilter);
        return _buildPaginatedList(remotePokemon, normalizedFilter, totalCount);
      } on PokemonRemoteException catch (e) {
        return _tryLocalFallback(normalizedFilter, e);
      }
    } else {
      return _getFromCache(normalizedFilter);
    }
  }

  @override
  Future<int> getTotalPokemonCount(PokemonFilter filter) async {
    final normalizedFilter = filter.copyWith(pageSize: pageSize);
    final connectivityResult = await _connectivity.checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;
    if (hasConnection) {
      try {
        return await _remoteDataSource.getTotalPokemonCount(normalizedFilter);
      } on PokemonRemoteException {
        final cachedCount = await _localDataSource.getCachedTotalCount(normalizedFilter);
        return cachedCount ?? 0;
      }
    } else {
      final cachedCount = await _localDataSource.getCachedTotalCount(normalizedFilter);
      return cachedCount ?? 0;
    }
  }

  @override
  Future<void> clearCache() async => _localDataSource.clearCache();

  @override
  Future<bool> hasCachedData() async => _localDataSource.hasData();

  @override
  Future<List<Pokemon>> getRandomPokemonsForGame(int count) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;
    if (hasConnection) {
      try {
        final remotePokemon = await _remoteDataSource.getPokemonForGame(count);
        return remotePokemon.map((dto) => dto.toEntity()).toList();
      } on PokemonRemoteException {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<PaginatedPokemonList> _tryLocalFallback(
      PokemonFilter filter, PokemonRemoteException originalError) async {
    final cached = await _localDataSource.getCachedPokemonList(filter);
    final cachedCount = await _localDataSource.getCachedTotalCount(filter);
    if (cached != null && cached.isNotEmpty) {
      return _buildPaginatedList(cached, filter, cachedCount ?? cached.length);
    }
    throw originalError;
  }

  Future<PaginatedPokemonList> _getFromCache(PokemonFilter filter) async {
    final cached = await _localDataSource.getCachedPokemonList(filter);
    final cachedCount = await _localDataSource.getCachedTotalCount(filter);
    if (cached != null && cached.isNotEmpty) {
      return _buildPaginatedList(cached, filter, cachedCount ?? cached.length);
    }
    throw PokemonRemoteException(
      message: 'Sin conexión a internet y no hay datos en cache',
      type: PokemonRemoteExceptionType.noConnection,
    );
  }

  PaginatedPokemonList _buildPaginatedList(
      List<PokemonDTO> pokemons,
      PokemonFilter filter,
      int totalCount,
      ) {
    final totalPages = (totalCount / filter.pageSize).ceil();
    return PaginatedPokemonList(
      pokemons: pokemons.map((dto) => dto.toEntity()).toList(),
      currentPage: filter.page,
      totalPages: totalPages,
      totalCount: totalCount,
      hasNextPage: filter.page < totalPages,
      hasPreviousPage: filter.page > 1,
    );
  }
}