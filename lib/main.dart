import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'di/graphql_client.dart';
import 'features/pokemon_list/data/pokemon_dto.dart';
import 'features/game/data/game_score_dto.dart';
import 'features/game/data/game_achievement_dto.dart';
import 'features/pokemon_list/data/pokemon_local_datasource.dart';
import 'features/pokemon_detail/data/pokemon_detail_local_datasource.dart';
import 'features/favorites/data/favorites_local_datasource.dart';
import 'features/game/data/game_local_datasource.dart';
import 'features/pokemon_list/ui/pokemon_list_provider.dart';
import 'features/pokemon_detail/ui/pokemon_detail_provider.dart';
import 'features/favorites/ui/favorites_provider.dart';
import 'features/game/ui/game_provider.dart';

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
  if (!Hive.isAdapterRegistered(GameScoreDTO.hiveTypeId)) {
    Hive.registerAdapter(GameScoreDTOAdapter());
  }
  if (!Hive.isAdapterRegistered(GameAchievementDTO.hiveTypeId)) {
    Hive.registerAdapter(GameAchievementDTOAdapter());
  }

  // Inicializar el data source local
  final localDataSource = PokemonLocalDataSource();
  await localDataSource.initialize();

  // Inicializar el data source local para detalles de Pokémon
  final detailLocalDataSource = PokemonDetailLocalDataSource();
  await detailLocalDataSource.initialize();

  // Inicializar el data source local para favoritos
  final favoritesLocalDataSource = FavoritesLocalDataSource();
  await favoritesLocalDataSource.initialize();

  // Inicializar el data source local para el juego "¿Quién es este Pokémon?"
  final gameLocalDataSource = GameLocalDataSource();
  await gameLocalDataSource.initialize();

  // Inicializar cache de GraphQL
  await initHiveForFlutter();

  // Inicializar el cliente GraphQL aquí, antes del runApp
  final graphQLClientNotifier = initGraphQLClient();
  final graphQLClient = graphQLClientNotifier.value;

  runApp(
    ProviderScope(
      overrides: [
        // Sobrescribir el provider del data source local
        localDataSourceProvider.overrideWithValue(localDataSource),
        // Sobrescribir el provider del data source de detalles
        pokemonDetailLocalDataSourceProvider.overrideWithValue(detailLocalDataSource),
        // Sobrescribir el provider del data source de favoritos
        favoritesLocalDataSourceProvider.overrideWithValue(favoritesLocalDataSource),
        // Sobrescribir el provider del data source del juego
        gameLocalDataSourceProvider.overrideWithValue(gameLocalDataSource),
        // Sobrescribir el provider del cliente GraphQL con el cliente real
        graphQLClientProvider.overrideWithValue(graphQLClient),
      ],
      child: PokedexApp(graphQLClient: graphQLClientNotifier),
    ),
  );
}