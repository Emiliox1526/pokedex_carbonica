import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_dto.dart';
import '../../domain/repositories/pokemon_repository.dart';

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
    final errorMessage = exception.graphqlErrors.firstOrNull?.message ?? '';
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
