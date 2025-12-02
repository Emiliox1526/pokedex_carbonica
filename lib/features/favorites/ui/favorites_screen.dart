import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/type_utils.dart';
import '../../pokemon_list/domain/pokemon.dart';
import '../../pokemon_detail/ui/pokemon_detail_screen.dart';
import 'favorites_provider.dart';
import '../../../common/widgets/pokemon_card.dart';
import '../../../common/widgets/pokemon_card_skeleton.dart';
import 'widgets/favorites_empty_state.dart';

/// Converts a hex string to a Color.
Color _hex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Pantalla Favoritos
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final Color _bg1 = _hex('#ff365a');
  final Color _bg2 = _hex('#8c0025');

  @override
  void initState() {
    super.initState();
    // Load favorites after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_bg1, _bg2],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, state),

                // Content
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// FavoriteHeader
  Widget _buildHeader(BuildContext context, FavoritesState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title row
          Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              // Title with heart icon
              const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mis Favoritos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Favorites count
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Text(
              state.isLoading
                  ? 'Cargando...'
                  : '${state.count} Pokémon${state.count == 1 ? '' : 's'} favorito${state.count == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds the main content based on state.
  Widget _buildContent(FavoritesState state) {
    // Loading state
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: 3,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemBuilder: (context, index) => const PokemonCardSkeleton(),
        ),
      );
    }

    // Error state
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white70,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).loadFavorites(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _hex('#9e1932'),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return const FavoritesEmptyState();
    }

    // List of favorites
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: state.favorites.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemBuilder: (context, index) {
          final pokemon = state.favorites[index];
          return PokemonCard(
            pokemon: pokemon,
            typeColors: typeColor,
            iconForType: iconForType,
            onTap: () => _navigateToDetail(pokemon),
          );
        },
      ),
    );
  }

  /// Navigates to the Pokemon detail screen.
  void _navigateToDetail(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreenNew(
          pokemonId: pokemon.id,
          heroTag: pokemon.heroTag,
          initialPokemon: _pokemonToMap(pokemon),
        ),
      ),
    ).then((_) {
      // Reload favorites when returning from detail screen
      // in case the favorite status was changed
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  /// Converts a Pokemon entity to a Map for the detail screen.
  Map<String, dynamic> _pokemonToMap(Pokemon pokemon) {
    return {
      'id': pokemon.id,
      'name': pokemon.name,
      'pokemon_v2_pokemontypes': pokemon.types
          .map((t) => {
                'pokemon_v2_type': {'name': t}
              })
          .toList(),
      'pokemon_v2_pokemonsprites': [
        {
          'sprites': {
            'other': {
              'official-artwork': {
                'front_default': pokemon.imageUrl,
              }
            },
            'front_default': pokemon.imageUrl,
          }
        }
      ],
      'pokemon_v2_pokemonabilities': pokemon.abilities
          .map((a) => {
                'pokemon_v2_ability': {'name': a}
              })
          .toList(),
    };
  }
}
