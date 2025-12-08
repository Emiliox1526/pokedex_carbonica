import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// Initializes and returns a GraphQL client for the PokeAPI.
///
/// Creates a configured GraphQL client with the beta GraphQL endpoint
/// and an in-memory cache.
ValueNotifier<GraphQLClient> initGraphQLClient() {
  final HttpLink httpLink = HttpLink('https://beta.pokeapi.co/graphql/v1beta');

  return ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );
}
