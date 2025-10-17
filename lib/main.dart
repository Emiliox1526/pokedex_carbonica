import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';
import 'screens/pokemon_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // Requerido por graphql_flutter
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: initGraphQLClient(),
      child: CacheProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pokédex Carbonica',
          theme: ThemeData(
            colorSchemeSeed: Colors.red,
            useMaterial3: true,
          ),
          home: const PokemonListScreen(),
        ),
      ),
    );
  }
}
