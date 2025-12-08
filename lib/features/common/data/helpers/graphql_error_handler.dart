import 'package:graphql_flutter/graphql_flutter.dart';

/// Shared helper for parsing and handling GraphQL errors.
///
/// This class centralizes GraphQL error handling logic to avoid
/// duplication across different remote data sources.
class GraphQLErrorHandler {
  /// Parses a GraphQL exception into a user-friendly error message.
  ///
  /// [exception] is the GraphQL operation exception.
  ///
  /// Returns a localized error message string.
  static String parseException(OperationException exception) {
    if (exception.linkException != null) {
      return 'Error de conexión con el servidor';
    }
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    return 'Error desconocido en la consulta';
  }

  /// Determines the type of error from a GraphQL exception.
  ///
  /// [exception] is the GraphQL operation exception.
  ///
  /// Returns the corresponding error type for handling.
  static RemoteExceptionType getExceptionType(OperationException exception) {
    if (exception.linkException != null) {
      return RemoteExceptionType.noConnection;
    }
    final errorMessage = exception.graphqlErrors.isEmpty
        ? ''
        : exception.graphqlErrors.first.message;
    if (errorMessage.contains('rate limit') ||
        errorMessage.contains('too many requests')) {
      return RemoteExceptionType.rateLimit;
    }
    return RemoteExceptionType.serverError;
  }
}

/// Common exception types for remote data sources.
enum RemoteExceptionType {
  /// Error de conexión o sin internet.
  noConnection,

  /// Timeout en la consulta.
  timeout,

  /// Rate limit excedido.
  rateLimit,

  /// Error del servidor.
  serverError,

  /// Recurso no encontrado.
  notFound,
}
