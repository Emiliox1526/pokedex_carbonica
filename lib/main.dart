import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'graphql_client.dart';
import 'data/models/pokemon_dto.dart';
import 'data/datasources/pokemon_local_datasource.dart';
import 'presentation/providers/pokemon_list_provider.dart';
import 'presentation/screens/pokemon_list_screen.dart';

/// Punto de entrada de la aplicación Pokédex.
/// 
/// Inicializa Flutter, Hive para persistencia local, y GraphQL para
/// las consultas a la API. Utiliza Riverpod para la gestión de estado.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para cache local
  await Hive.initFlutter();
  
  // Registrar adaptadores de Hive
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PokemonDTOAdapter());
  }
  
  // Inicializar el data source local
  final localDataSource = PokemonLocalDataSource();
  await localDataSource.initialize();
  
  // Inicializar cache de GraphQL
  await initHiveForFlutter();
  
  runApp(
    ProviderScope(
      overrides: [
        // Sobrescribir el provider del data source local
        localDataSourceProvider.overrideWithValue(localDataSource),
      ],
      child: const PokedexApp(),
    ),
  );
}

/// Widget principal de la aplicación Pokédex.
/// 
/// Configura los providers de GraphQL y Riverpod necesarios
/// para el funcionamiento de la aplicación.
class PokedexApp extends ConsumerWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar el cliente GraphQL
    final graphQLClient = initGraphQLClient();
    
    return GraphQLProvider(
      client: graphQLClient,
      child: CacheProvider(
        child: ProviderScope(
          overrides: [
            // Sobrescribir el provider del cliente GraphQL con el cliente real
            graphQLClientProvider.overrideWithValue(graphQLClient.value),
          ],
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
      ),
    );
  }
}
