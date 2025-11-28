import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/pokemon.dart';
import '../detail/pokemon_detail_screen.dart';
import '../../providers/favorites/favorites_provider.dart';
import '../../widgets/pokemon_card.dart';
import '../../widgets/pokemon_card_skeleton.dart';
import '../../widgets/favorites/favorites_empty_state.dart';

/// Converts a hex string to a Color.
Color _hex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Screen that displays the user's favorite Pokemon.
///
/// Shows a list of favorited Pokemon with the same visual style
/// as the main Pokemon list screen.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  /// Background gradient colors (same as pokemon_list_screen).
  final Color _bg1 = _hex('#ff365a');
  final Color _bg2 = _hex('#8c0025');

  /// Map of Pokemon type colors.
  static final Map<String, Color> _typeColor = {
    'normal': _hex('#9BA0A8'),
    'fire': _hex('#FF6B3D'),
    'water': _hex('#4C90FF'),
    'electric': _hex('#FFD037'),
    'grass': _hex('#6BD64A'),
    'ice': _hex('#64DDF8'),
    'fighting': _hex('#E34343'),
    'poison': _hex('#B24ADD'),
    'ground': _hex('#E2B36B'),
    'flying': _hex('#A890F7'),
    'psychic': _hex('#FF4888'),
    'bug': _hex('#88C12F'),
    'rock': _hex('#C9B68B'),
    'ghost': _hex('#6F65D8'),
    'dragon': _hex('#7366FF'),
    'dark': _hex('#5A5A5A'),
    'steel': _hex('#8AA4C1'),
    'fairy': _hex('#FF78D5'),
  };

  @override
  void initState() {
    super.initState();
    // Load favorites after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  /// Returns the icon for a Pokemon type.
  IconData _iconForType(String type) {
    switch (type) {
      case 'fire':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'grass':
        return Icons.eco;
      case 'electric':
        return Icons.bolt;
      case 'ice':
        return Icons.ac_unit;
      case 'fighting':
        return Icons.sports_mma;
      case 'poison':
        return Icons.coronavirus;
      case 'ground':
        return Icons.landscape;
      case 'flying':
        return Icons.air;
      case 'psychic':
        return Icons.psychology;
      case 'bug':
        return Icons.pest_control_rodent;
      case 'rock':
        return Icons.terrain;
      case 'ghost':
        return Icons.auto_awesome;
      case 'dragon':
        return Icons.adb;
      case 'dark':
        return Icons.dark_mode;
      case 'steel':
        return Icons.build;
      case 'fairy':
        return Icons.auto_fix_high;
      default:
        return Icons.blur_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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

  /// Builds the header with title and favorite count.
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
            typeColors: _typeColor,
            iconForType: _iconForType,
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
