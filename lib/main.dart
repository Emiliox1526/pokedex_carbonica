import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/pokemon_list/data/pokemon_repository.dart';
import 'features/pokemon_list/ui/widgets/splash_interactive.dart';

import 'graphql_client.dart';
import 'features/pokemon_list/data/pokemon_data.dart';
import 'features/game/data/game_score_dto.dart';
import 'features/game/data/game_achievement_dto.dart';

import 'features/pokemon_detail/data/pokemon_detail_data_repository.dart';
import 'features/favorites/data/favorites_local_datasource.dart';
import 'features/game/data/game_local_datasource.dart';
import 'features/pokemon_list/ui/pokemon_list_provider.dart';
import 'features/pokemon_detail/ui/pokemon_detail_provider.dart';
import 'features/favorites/ui/favorites_provider.dart';
import 'features/game/ui/game_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PokemonDTOAdapter());
  }
  if (!Hive.isAdapterRegistered(GameScoreDTO.hiveTypeId)) {
    Hive.registerAdapter(GameScoreDTOAdapter());
  }
  if (!Hive.isAdapterRegistered(GameAchievementDTO.hiveTypeId)) {
    Hive.registerAdapter(GameAchievementDTOAdapter());
  }

  final localDataSource = PokemonLocalDataSource();
  await localDataSource.initialize();

  final detailLocalDataSource = PokemonDetailLocalDataSource();
  await detailLocalDataSource.initialize();

  final favoritesLocalDataSource = FavoritesLocalDataSource();
  await favoritesLocalDataSource.initialize();

  final gameLocalDataSource = GameLocalDataSource();
  await gameLocalDataSource.initialize();

  await initHiveForFlutter();

  final graphQLClientNotifier = initGraphQLClient();
  final graphQLClient = graphQLClientNotifier.value;

  runApp(
    ProviderScope(
      overrides: [
        localDataSourceProvider.overrideWithValue(localDataSource),
        pokemonDetailLocalDataSourceProvider.overrideWithValue(detailLocalDataSource),
        favoritesLocalDataSourceProvider.overrideWithValue(favoritesLocalDataSource),
        gameLocalDataSourceProvider.overrideWithValue(gameLocalDataSource),
        graphQLClientProvider.overrideWithValue(graphQLClient),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashInteractive(
          nextScreen: PokedexApp(
            graphQLClient: graphQLClientNotifier,
          ),
        ),
      ),
    ),
  );
}
