import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../queries/get_pokemon_detail.dart';
import '../../models/detail/pokemon_detail_dto.dart';

/// Remote data source for fetching Pokemon detail from PokeAPI GraphQL.
class PokemonDetailRemoteDataSource {
  final GraphQLClient _client;

  /// Timeout for queries in seconds.
  static const int _queryTimeoutSeconds = 30;

  /// Creates a data source with the given GraphQL client.
  PokemonDetailRemoteDataSource(this._client);

  /// Fetches detailed Pokemon information by ID.
  ///
  /// [id] is the Pokemon's ID.
  ///
  /// Returns a [PokemonDetailDTO] with all Pokemon details.
  ///
  /// Throws [PokemonDetailException] on failure.
  Future<PokemonDetailDTO> getPokemonDetail(int id) async {
    try {
      final result = await _client
          .query(
            QueryOptions(
              document: gql(getPokemonDetailQuery),
              variables: {'id': id},
              fetchPolicy: FetchPolicy.cacheFirst,
            ),
          )
          .timeout(const Duration(seconds: _queryTimeoutSeconds));

      if (result.hasException) {
        throw PokemonDetailException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }

      final data = result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;
      if (data == null) {
        throw PokemonDetailException(
          message: 'Pokemon not found',
          type: PokemonDetailExceptionType.notFound,
        );
      }

      return PokemonDetailDTO.fromGraphQL(data);
    } catch (e) {
      if (e is PokemonDetailException) rethrow;
      throw PokemonDetailException(
        message: 'Connection error: ${e.toString()}',
        type: PokemonDetailExceptionType.noConnection,
      );
    }
  }

  /// Fetches detailed information for a specific Pokemon form variant.
  ///
  /// [pokemonId] is the Pokemon ID of the form variant.
  ///
  /// Returns a [PokemonDetailDTO] with the form's specific data.
  Future<PokemonDetailDTO> getFormDetail(int pokemonId) async {
    try {
      final result = await _client
          .query(
            QueryOptions(
              document: gql(getFormDetailQuery),
              variables: {'pokemonId': pokemonId},
              fetchPolicy: FetchPolicy.cacheFirst,
            ),
          )
          .timeout(const Duration(seconds: _queryTimeoutSeconds));

      if (result.hasException) {
        throw PokemonDetailException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }

      final data = result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;
      if (data == null) {
        throw PokemonDetailException(
          message: 'Pokemon form not found',
          type: PokemonDetailExceptionType.notFound,
        );
      }

      return PokemonDetailDTO.fromGraphQL(data);
    } catch (e) {
      if (e is PokemonDetailException) rethrow;
      throw PokemonDetailException(
        message: 'Connection error: ${e.toString()}',
        type: PokemonDetailExceptionType.noConnection,
      );
    }
  }

  String _parseGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      return 'Server connection error';
    }
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    return 'Unknown query error';
  }

  PokemonDetailExceptionType _getExceptionType(OperationException exception) {
    if (exception.linkException != null) {
      return PokemonDetailExceptionType.noConnection;
    }
    final errorMessage =
        exception.graphqlErrors.isEmpty ? '' : exception.graphqlErrors.first.message;
    if (errorMessage.contains('rate limit') ||
        errorMessage.contains('too many requests')) {
      return PokemonDetailExceptionType.rateLimit;
    }
    return PokemonDetailExceptionType.serverError;
  }
}

/// Types of exceptions from the Pokemon detail data source.
enum PokemonDetailExceptionType {
  /// No internet connection.
  noConnection,

  /// Query timeout.
  timeout,

  /// Rate limit exceeded.
  rateLimit,

  /// Server error.
  serverError,

  /// Pokemon not found.
  notFound,
}

/// Exception for Pokemon detail data source errors.
class PokemonDetailException implements Exception {
  /// Descriptive error message.
  final String message;

  /// Exception type.
  final PokemonDetailExceptionType type;

  /// Creates an exception with message and type.
  PokemonDetailException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'PokemonDetailException: $message (type: $type)';
}
