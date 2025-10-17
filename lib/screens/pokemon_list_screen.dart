import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../queries/get_pokemon_list.dart';

class PokemonListScreen extends StatelessWidget {
  const PokemonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex Carbonica – Gen 1')),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonListQuery),
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          final List pokemons = result.data?['pokemon_v2_pokemon'] ?? [];

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
            ),
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final p = pokemons[index];
              final name = p['name'];
              final types = (p['pokemon_v2_pokemontypes'] as List)
                  .map((t) => t['pokemon_v2_type']['name'])
                  .join(', ');

              return Card(
                margin: const EdgeInsets.all(8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '#${p['id']} ${name.toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(types),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
