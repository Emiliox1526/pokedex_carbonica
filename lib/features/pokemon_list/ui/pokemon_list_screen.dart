import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../l10n/l10n_extension.dart';
import '../data/pokemon_data.dart';
import '../../pokemon_detail/ui/pokemon_detail_screen.dart';
import 'pokemon_list_provider.dart';
import 'widgets/pokemon_card.dart';
import 'widgets/pokemon_card_skeleton.dart';
import 'widgets/search_bar.dart';
import 'widgets/generation_drawer.dart';
import 'widgets/pagination_controls.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

/// Función helper para convertir hex a Color.
Color hex(String hex) {
  final buffer = StringBuffer();
  if (hex. length == 6 || hex. length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Pantalla principal de lista de Pokémon

class PokemonListScreenNew extends ConsumerStatefulWidget {
  const PokemonListScreenNew({super.key});

  @override
  ConsumerState<PokemonListScreenNew> createState() => _PokemonListScreenNewState();
}

class _PokemonListScreenNewState extends ConsumerState<PokemonListScreenNew> {
  /// Colores de fondo del gradiente.

  static const Map<int, String> _generationBackgroundImages = {
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
    // Si no hay generación seleccionada, usa Kanto por defecto
    return _generationBackgroundImages[generation] ?? _generationBackgroundImages[0]!;
  }

  /// Set de URLs de imágenes ya precargadas.
  final Set<String> _prefetchedImageUrls = {};

  /// ScrollController para controlar el scroll de la lista.
  final ScrollController _scrollController = ScrollController();

  /// Página anterior para detectar cambios de página.
  int _previousPage = 1;

  /// Mapa de colores por tipo de Pokémon.
  static final Map<String, Color> typeColor = {
    'normal': hex('#9BA0A8'),
    'fire': hex('#FF6B3D'),
    'water': hex('#4C90FF'),
    'electric': hex('#FFD037'),
    'grass': hex('#6BD64A'),
    'ice': hex('#64DDF8'),
    'fighting': hex('#E34343'),
    'poison': hex('#B24ADD'),
    'ground': hex('#E2B36B'),
    'flying': hex('#A890F7'),
    'psychic': hex('#FF4888'),
    'bug': hex('#88C12F'),
    'rock': hex('#C9B68B'),
    'ghost': hex('#6F65D8'),
    'dragon': hex('#7366FF'),
    'dark': hex('#5A5A5A'),
    'steel': hex('#8AA4C1'),
    'fairy': hex('#FF78D5'),
  };
// Color representativo por generación / región
  static const Map<int, Color> _regionColors = {
    // 1 = Kanto
    1: Color(0xFFEF5350), // rojo Pokéball

    // 2 = Johto
    2: Color(0xFFFFCA28), // dorado

    // 3 = Hoenn
    3: Color(0xFF26A69A), // teal

    // 4 = Sinnoh
    4: Color(0xFF42A5F5), // azul

    // 5 = Unova
    5: Color(0xFF7E57C2), // púrpura

    // 6 = Kalos
    6: Color(0xFFEC407A), // rosa fuerte

    // 7 = Alola
    7: Color(0xFF26C6DA), // turquesa

    // 8 = Galar
    8: Color(0xFFD81B60), // magenta

    // 9 = Paldea
    9: Color(0xFFFF7043), // naranja
  };

  Color _regionColorForGeneration(int? generation) {
    // Color por defecto si no hay generación seleccionada
    return _regionColors[generation] ?? const Color(0xFFEF5350);
  }

  /// Retorna el icono correspondiente a un tipo de Pokémon.
  IconData iconForType(String type) {
    switch (type) {
      case 'fire':
        return Icons. local_fire_department;
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pokemonListProvider.notifier).loadInitial();
      _precacheDrawerImages(context); // <- Aquí haces el precache
    });
  }

  void _precacheDrawerImages(BuildContext ctx) {
    // Lista de banners usados en el drawer
    final List<String> drawerImages = [
      "lib/assets/AllGenerations.png",
      "lib/assets/kanto.png",
      "lib/assets/johto.png",
      "lib/assets/hoenn.png",
      "lib/assets/sinnoh.png",
      "lib/assets/unova.png",
      "lib/assets/kalos.png",
      "lib/assets/alola.png",
      "lib/assets/galar.png",
      "lib/assets/paldea.png",
    ];
    for (final img in drawerImages) {
      precacheImage(AssetImage(img), ctx);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Hace scroll suave hacia arriba de la lista.
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonListProvider);
    final Color _bg1 =
    _regionColorForGeneration(state.selectedGeneration).withOpacity(0.85);

    final Color _bg2 =
    _regionColorForGeneration(state.selectedGeneration).withOpacity(0.55);
    final notifier = ref.read(pokemonListProvider.notifier);

    // Detectar cambio de página y hacer scroll hacia arriba
    if (state.currentPage != _previousPage) {
      _previousPage = state.currentPage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTop();
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: GenerationDrawer(
        onSelectGeneration: (int gen) {
          notifier.selectGeneration(gen == 0 ? null : gen);
          Navigator.of(context).maybePop();
        },
        typeColors: typeColor,
        selectedTypes: state.selectedTypes,
        onToggleType: notifier.toggleType,
        iconForType: iconForType,
        selectedGeneration: state.selectedGeneration,
      ),
      body: Stack(
        children: [
          // Fondo con imagen de región + blur
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Opacity(
                opacity: 0.55, // intensidad de la foto de fondo
                child: Image.asset(
                  _assetForGeneration(state.selectedGeneration),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

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
                // Parte superior: búsqueda y filtros
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Indicador de generación seleccionada
                      if (state.selectedGeneration != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            context.l10n.showingGeneration(state.selectedGeneration.toString()),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Barra de búsqueda
                      PokemonSearchBar(
                        onChanged: notifier.updateSearch,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Contenido principal (lista de Pokémon)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildContent(state, notifier),
                  ),
                ),

                // Controles de paginación en la parte inferior
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                  child: SafeArea(
                    top: false,
                    child: PaginationControls(
                      currentPage: state.currentPage,
                      totalPages: state.totalPages,
                      hasPreviousPage: state.hasPreviousPage,
                      hasNextPage: state.hasNextPage,
                      isLoading: state.isLoading,
                      onPreviousPage: notifier.previousPage,
                      onNextPage: notifier.nextPage,
                      primaryColor: _regionColorForGeneration(state.selectedGeneration),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );


  }

  /// Construye el contenido principal según el estado actual.
  Widget _buildContent(PokemonListState state, PokemonListNotifier notifier) {
    // Estado de carga inicial - mostrar skeletons animados
    if (state.isInitialLoading) {
      return ListView.builder(
        itemCount: 5,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets. only(bottom: 24),
        itemBuilder: (context, index) {
          return const PokemonCardSkeleton();
        },
      );
    }

    // Estado de error
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors. white70,
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
              onPressed: () => notifier.loadInitial(),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: hex('#9e1932'),
              ),
            ),
          ],
        ),
      );
    }

    // Lista vacía
    if (state.pokemons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              color: Colors.white70,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noPokemonFound,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Lista de Pokémon optimizada
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: state.pokemons.length,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          cacheExtent: 500,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            final pokemon = state.pokemons[index];

            // Prefetch de imágenes para los próximos 5 Pokémon
            _prefetchUpcomingImages(context, state.pokemons, index);

            return PokemonCard(
              pokemon: pokemon,
              typeColors: typeColor,
              iconForType: iconForType,
              onTap: () => _navigateToDetail(pokemon),
            );
          },
        ),

        // Indicador de carga sobre la lista
        if (state.isLoading && !state.isInitialLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  /// Precarga las imágenes de los próximos Pokémon para mejorar el rendimiento.
  /// Silencia errores de red ya que el prefetching es una optimización no crítica.
  void _prefetchUpcomingImages(BuildContext context, List<Pokemon> pokemons, int currentIndex) {
    const prefetchCount = 5;
    final endIndex = (currentIndex + prefetchCount).clamp(0, pokemons.length);

    for (int i = currentIndex + 1; i < endIndex; i++) {
      final imageUrl = pokemons[i].imageUrl;
      if (imageUrl != null && !_prefetchedImageUrls.contains(imageUrl)) {
        _prefetchedImageUrls.add(imageUrl);
        // Ignorar errores de prefetch ya que no afectan la funcionalidad principal
        precacheImage(
          CachedNetworkImageProvider(imageUrl),
          context,
        ).catchError((_) {});
      }
    }
  }

  /// Navega a la pantalla de detalle del Pokémon.
  void _navigateToDetail(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreenNew(
          pokemonId: pokemon. id,
          heroTag: pokemon.heroTag,
          initialPokemon: _pokemonToMap(pokemon),
        ),
      ),
    );
  }

  /// Convierte una entidad Pokemon a un Map para compatibilidad con la pantalla de detalle.
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
                'front_default': pokemon. imageUrl,
              }
            },
            'front_default': pokemon.imageUrl,
          }
        }
      ],
      'pokemon_v2_pokemonabilities': pokemon.abilities
          . map((a) => {
        'pokemon_v2_ability': {'name': a}
      })
          .toList(),
    };
  }
}