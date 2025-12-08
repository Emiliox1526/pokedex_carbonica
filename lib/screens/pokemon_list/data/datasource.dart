/// Data sources and DTOs for this feature.
///
/// Consolidates all data transfer objects, local and remote data sources.

import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/model.dart';

part 'datasource.g.dart';





/// Data Transfer Object para deserializar respuestas GraphQL de Pokémon.
/// 
/// Esta clase se encarga de mapear los datos crudos de la API GraphQL
/// a objetos utilizables en la aplicación. También está anotada para
/// persistencia con Hive.
@HiveType(typeId: 0)
class PokemonDTO {
  /// Identificador único del Pokémon.
  @HiveField(0)
  final int id;

  /// Nombre del Pokémon.
  @HiveField(1)
  final String name;

  /// Lista de tipos del Pokémon.
  @HiveField(2)
  final List<String> types;

  /// URL de la imagen del Pokémon.
  @HiveField(3)
  final String? imageUrl;

  /// Lista de habilidades del Pokémon.
  @HiveField(4)
  final List<String> abilities;

  /// Constructor del DTO.
  const PokemonDTO({
    required this.id,
    required this.name,
    required this.types,
    this.imageUrl,
    this.abilities = const [],
  });

  /// Crea un DTO a partir de los datos JSON de GraphQL.
  /// 
  /// [json] es el mapa con los datos de un Pokémon de la respuesta GraphQL.
  factory PokemonDTO.fromGraphQL(Map<String, dynamic> json) {
    // Extraer ID y nombre
    final int id = json['id'] as int? ?? 0;
    final String name = json['name'] as String? ?? '';

    // Extraer tipos
    final typesRaw = json['pokemon_v2_pokemontypes'] as List? ?? [];
    final List<String> types = typesRaw
       .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
       .where((e) => e.isNotEmpty)
       .toList();

    // Extraer habilidades
    final abilitiesRaw = json['pokemon_v2_pokemonabilities'] as List? ?? [];
    final List<String> abilities = abilitiesRaw
       .take(2)
       .map((a) => (a['pokemon_v2_ability']?['name'] as String?) ?? '')
       .where((e) => e.isNotEmpty)
       .toList();

    // Extraer URL de imagen
    String? imageUrl;
    final spritesList = json['pokemon_v2_pokemonsprites'] as List?;
    if (spritesList != null && spritesList.isNotEmpty) {
      try {
        final dynamic raw = spritesList.first['sprites'];
        Map<String, dynamic>? map;
        if (raw is String) {
          map = jsonDecode(raw) as Map<String, dynamic>;
        } else if (raw is Map) {
          map = Map<String, dynamic>.from(raw);
        }
        imageUrl =
            (map?['other']?['official-artwork']?['front_default'] as String?) ??
            (map?['front_default'] as String?);
      } catch (_) {
        imageUrl = null;
      }
    }

    return PokemonDTO(
      id: id,
      name: name,
      types: types,
      imageUrl: imageUrl,
      abilities: abilities,
    );
  }

  /// Convierte el DTO a una entidad de dominio.
  Pokemon toEntity() {
    return Pokemon(
      id: id,
      name: name,
      types: types,
      imageUrl: imageUrl,
      abilities: abilities,
    );
  }

  /// Convierte el DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      'imageUrl': imageUrl,
      'abilities': abilities,
    };
  }

  /// Crea un DTO a partir de un mapa JSON (para cache local).
  factory PokemonDTO.fromJson(Map<String, dynamic> json) {
    return PokemonDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      types: (json['types'] as List).cast<String>(),
      imageUrl: json['imageUrl'] as String?,
      abilities: (json['abilities'] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  String toString() => 'PokemonDTO(id: $id, name: $name, types: $types)';
}



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



/// Consulta GraphQL optimizada para obtener lista de Pokémon con paginación.
/// 
/// Utiliza paginación basada en offset con límite de 20 Pokémon por página.
const String _paginatedPokemonListQuery = r'''
  query PokemonList($limit: Int!, $offset: Int!, $where: pokemon_v2_pokemon_bool_exp) {
    pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: {id: asc}, where: $where) {
      id
      name
      pokemon_v2_pokemonabilities(limit: 2) {
        pokemon_v2_ability { name }
      }
      pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      pokemon_v2_pokemonsprites { sprites }
    }
  }
''';

/// Consulta GraphQL para obtener el conteo total de Pokémon.
const String _pokemonCountQuery = r'''
  query PokemonCount($where: pokemon_v2_pokemon_bool_exp) {
    pokemon_v2_pokemon_aggregate(where: $where) {
      aggregate {
        count
      }
    }
  }
''';

/// Consulta GraphQL para obtener Pokémon para el juego.
/// Obtiene un rango amplio de Pokémon ordenados por ID.
const String _pokemonForGameQuery = r'''
  query PokemonForGame($limit: Int!, $offset: Int!) {
    pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: {id: asc}) {
      id
      name
      pokemon_v2_pokemonabilities(limit: 2) {
        pokemon_v2_ability { name }
      }
      pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      pokemon_v2_pokemonsprites { sprites }
    }
  }
''';

/// Data source remoto para obtener datos de Pokémon desde PokeAPI GraphQL.
/// 
/// Esta clase maneja la comunicación con la API GraphQL de PokeAPI,
/// incluyendo el manejo de errores, timeouts y rate limits.
class PokemonRemoteDataSource {
  /// Cliente GraphQL para realizar las consultas.
  final GraphQLClient _client;

  /// Timeout para las consultas en segundos.
  static const int _queryTimeoutSeconds = 30;

  /// Constructor que inyecta el cliente GraphQL.
  PokemonRemoteDataSource(this._client);

  /// Obtiene una lista de Pokémon desde la API GraphQL.
  /// 
  /// [filter] contiene los parámetros de filtrado y paginación.
  /// 
  /// Retorna una lista de [PokemonDTO].
  /// 
  /// Puede lanzar [PokemonRemoteException] en caso de error.
  Future<List<PokemonDTO>> getPokemonList(PokemonFilter filter) async {
    try {
      final result = await _client
         .query(
            QueryOptions(
              document: gql(_paginatedPokemonListQuery),
              variables: {
                'limit': filter.pageSize,
                'offset': filter.offset,
                'where': _buildWhereClause(filter),
              },
              fetchPolicy: FetchPolicy.networkOnly,
            ),
          )
         .timeout(const Duration(seconds: _queryTimeoutSeconds));

      if (result.hasException) {
        throw PokemonRemoteException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }

      final data = result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [];
      return data
         .map((e) => PokemonDTO.fromGraphQL(Map<String, dynamic>.from(e as Map)))
         .toList();
    } catch (e) {
      if (e is PokemonRemoteException) rethrow;
      throw PokemonRemoteException(
        message: 'Error de conexión: ${e.toString()}',
        type: PokemonRemoteExceptionType.noConnection,
      );
    }
  }

  /// Obtiene el conteo total de Pokémon que coinciden con el filtro.
  /// 
  /// Útil para calcular el número total de páginas.
  Future<int> getTotalPokemonCount(PokemonFilter filter) async {
    try {
      final result = await _client
         .query(
            QueryOptions(
              document: gql(_pokemonCountQuery),
              variables: {
                'where': _buildWhereClause(filter),
              },
              fetchPolicy: FetchPolicy.networkOnly,
            ),
          )
         .timeout(const Duration(seconds: _queryTimeoutSeconds));

      if (result.hasException) {
        throw PokemonRemoteException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }

      return result.data?['pokemon_v2_pokemon_aggregate']?['aggregate']?['count']
              as int? ??
          0;
    } catch (e) {
      if (e is PokemonRemoteException) rethrow;
      throw PokemonRemoteException(
        message: 'Error al obtener conteo: ${e.toString()}',
        type: PokemonRemoteExceptionType.noConnection,
      );
    }
  }

  /// Obtiene una lista de Pokémon para el juego.
  /// 
  /// [count] es la cantidad de Pokémon a obtener.
  /// [offset] es el offset opcional para la consulta (por defecto 0).
  /// 
  /// Retorna una lista de [PokemonDTO].
  Future<List<PokemonDTO>> getPokemonForGame(int count, {int offset = 0}) async {
    try {
      final result = await _client
         .query(
            QueryOptions(
              document: gql(_pokemonForGameQuery),
              variables: {
                'limit': count,
                'offset': offset,
              },
              fetchPolicy: FetchPolicy.networkOnly,
            ),
          )
         .timeout(const Duration(seconds: _queryTimeoutSeconds));

      if (result.hasException) {
        throw PokemonRemoteException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }

      final data = result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [];
      return data
         .map((e) => PokemonDTO.fromGraphQL(Map<String, dynamic>.from(e as Map)))
         .toList();
    } catch (e) {
      if (e is PokemonRemoteException) rethrow;
      throw PokemonRemoteException(
        message: 'Error al obtener Pokémon para el juego: ${e.toString()}',
        type: PokemonRemoteExceptionType.noConnection,
      );
    }
  }

  /// Construye la cláusula WHERE para las consultas GraphQL.
  Map<String, dynamic>? _buildWhereClause(PokemonFilter filter) {
    final List<Map<String, dynamic>> andConditions = [];

    // Filtro por búsqueda (nombre o ID)
    if (filter.searchText != null && filter.searchText!.isNotEmpty) {
      final searchText = filter.searchText!.toLowerCase().trim();
      final parsedId = int.tryParse(searchText);
      final List<Map<String, dynamic>> orConditions = [
        {
          'name': {'_ilike': '%$searchText%'}
        },
      ];
      if (parsedId != null) {
        orConditions.add({
          'id': {'_eq': parsedId}
        });
      }
      andConditions.add({'_or': orConditions});
    }

    // Filtro por generación
    if (filter.generation != null) {
      final start = _startIdForGeneration(filter.generation!);
      final end = _endIdForGeneration(filter.generation!);
      andConditions.add({
        'id': {
          '_gte': start,
          '_lte': end,
        }
      });
    }

    // Filtro por tipos
    if (filter.types.isNotEmpty) {
      andConditions.add({
        'pokemon_v2_pokemontypes': {
          'pokemon_v2_type': {
            'name': {
              '_in': filter.types.toList(),
            },
          },
        },
      });
    }

    if (andConditions.isEmpty) return null;
    if (andConditions.length == 1) return andConditions.first;

    return {'_and': andConditions};
  }

  /// Retorna el ID inicial de una generación.
  int _startIdForGeneration(int gen) {
    const startIds = [1, 152, 252, 387, 494, 650, 722, 810, 906];
    return gen >= 1 && gen <= startIds.length ? startIds[gen - 1] : 1;
  }

  /// Retorna el ID final de una generación.
  int _endIdForGeneration(int gen) {
    const endIds = [151, 251, 386, 493, 649, 721, 809, 905, 1025];
    return gen >= 1 && gen <= endIds.length ? endIds[gen - 1] : 1025;
  }

  /// Parsea las excepciones de GraphQL a mensajes legibles.
  String _parseGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      return 'Error de conexión con el servidor';
    }
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    return 'Error desconocido en la consulta';
  }

  /// Determina el tipo de excepción basado en el error de GraphQL.
  PokemonRemoteExceptionType _getExceptionType(OperationException exception) {
    if (exception.linkException != null) {
      return PokemonRemoteExceptionType.noConnection;
    }
    final errorMessage = exception.graphqlErrors.isEmpty 
        ? '' 
        : exception.graphqlErrors.first.message;
    if (errorMessage.contains('rate limit') ||
        errorMessage.contains('too many requests')) {
      return PokemonRemoteExceptionType.rateLimit;
    }
    return PokemonRemoteExceptionType.serverError;
  }
}

/// Tipos de excepciones del data source remoto.
enum PokemonRemoteExceptionType {
  /// Error de conexión o sin internet.
  noConnection,
  
  /// Timeout en la consulta.
  timeout,
  
  /// Rate limit excedido.
  rateLimit,
  
  /// Error del servidor.
  serverError,
}

/// Excepción personalizada para errores del data source remoto.
class PokemonRemoteException implements Exception {
  /// Mensaje descriptivo del error.
  final String message;
  
  /// Tipo de excepción.
  final PokemonRemoteExceptionType type;

  /// Constructor de la excepción.
  PokemonRemoteException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'PokemonRemoteException: $message (type: $type)';
}

