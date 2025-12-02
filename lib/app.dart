import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'features/pokemon_list/ui/pokemon_list_screen.dart';

/// Widget principal de la aplicación Pokédex.
///
/// Configura los providers de GraphQL y Riverpod necesarios
/// para el funcionamiento de la aplicación.
class PokedexApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> graphQLClient;

  const PokedexApp({super.key, required this.graphQLClient});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: graphQLClient,
      child: CacheProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pokédex Carbonica',
          theme: ThemeData(
            colorSchemeSeed: Colors.red,
            useMaterial3: true,
          ),
          // Usar la nueva pantalla con Clean Architecture
          home: const PokemonListScreenNew(),
        ),
      ),
    );
  }
}
