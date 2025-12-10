import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/type_utils.dart';
import '../../../l10n/l10n_extension.dart';
import '../../pokemon_list/data/pokemon_data.dart';
import '../../pokemon_detail/ui/pokemon_detail_screen.dart';
import 'favorites_provider.dart';
import '../../pokemon_list/ui/widgets/pokemon_card.dart';
import '../../pokemon_list/ui/widgets/pokemon_card_skeleton.dart';
import 'widgets/favorites_empty_state.dart';

// --- Configuración de assets e imagenes por generación (igual que lista principal) ---
const Map<int, String> _generationBackgroundImages = {
  0: 'lib/assets/AllGenerations.png',
  1: 'lib/assets/kanto.png',
  2: 'lib/assets/johto.png',
  3: 'lib/assets/hoenn.png',
  4: 'lib/assets/sinnoh.png',
  5: 'lib/assets/unova.png',
  6: 'lib/assets/kalos.png',
  7: 'lib/assets/alola.png',
  8: 'lib/assets/galar.png',
  9: 'lib/assets/paldea.png',
};
String _assetForGeneration(int? generation) {
  return _generationBackgroundImages[generation] ?? _generationBackgroundImages[0]!;
}

const Map<int, Color> _regionColors = {
  1: Color(0xFFEF5350),
  2: Color(0xFFFFCA28),
  3: Color(0xFF26A69A),
  4: Color(0xFF42A5F5),
  5: Color(0xFF7E57C2),
  6: Color(0xFFEC407A),
  7: Color(0xFF26C6DA),
  8: Color(0xFFD81B60),
  9: Color(0xFFFF7043),
};
Color _regionColorForGeneration(int? generation) {
  return _regionColors[generation] ?? const Color(0xFFEF5350);
}

Color _hex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// --- Pantalla Favoritos ---
class FavoritesScreen extends ConsumerStatefulWidget {
  final int? selectedGeneration;
  const FavoritesScreen({super.key, this.selectedGeneration});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesProvider);
    final int? selectedGeneration = widget.selectedGeneration ?? 0;

    // --- Fondo en el orden exacto del pokemon_list_screen ---
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo con imagen de región + blur
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Opacity(
                opacity: 0.55, // intensidad de la foto de fondo
                child: Image.asset(
                  _assetForGeneration(selectedGeneration),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // --- 2) Decorativos detrás (círculo + rectángulo diagonal) ---
          // Diseños decorativos detrás del contenido
          IgnorePointer(
            child: Stack(
              children: [
                // Círculo grande tipo Pokébola arriba a la izquierda
                Positioned(
                  top: -120,
                  left: -40,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 18,
                      ),
                    ),
                  ),
                ),



                // Rectángulo diagonal suave en el centro
                Positioned(
                  top: 600,
                  right: -150,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Container(
                      width: 260,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.white.withOpacity(0.02),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Capa oscura ligera para mejorar contraste del contenido
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),


          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(child: _buildContent(state)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FavoritesState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.17),
                  Colors.white.withOpacity(0.07),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.09),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.9), size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 19,
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.myFavorites,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              )
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.isLoading
                              ? context.l10n.loading
                              : context.l10n.pokemonCount(
                            state.count.toString(),
                            state.count == 1 ? '' : 's',
                          ),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black12,
                                blurRadius: 1.5,
                                offset: Offset(1, 1),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(FavoritesState state) {
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
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 64),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(favoritesProvider.notifier).loadFavorites(),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _hex('#9e1932'),
              ),
            ),
          ],
        ),
      );
    }
    if (state.isEmpty) {
      return const FavoritesEmptyState();
    }
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
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  Map<String, dynamic> _pokemonToMap(Pokemon pokemon) {
    return {
      'id': pokemon.id,
      'name': pokemon.name,
      'pokemon_v2_pokemontypes': pokemon.types
          .map((t) => {'pokemon_v2_type': {'name': t}})
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
          .map((a) => {'pokemon_v2_ability': {'name': a}})
          .toList(),
    };
  }
}