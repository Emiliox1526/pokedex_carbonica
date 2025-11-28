import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/pokemon.dart';
import 'detail/pokemon_detail_screen_new.dart';
import '../providers/pokemon_list_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/pokemon_card_skeleton.dart';
import '../widgets/search_bar.dart';
import '../widgets/generation_drawer.dart';
import '../widgets/pagination_controls.dart';

/// Función helper para convertir hex a Color.
Color hex(String hex) {
  final buffer = StringBuffer();
  if (hex. length == 6 || hex. length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Pantalla principal de lista de Pokémon con Clean Architecture.
///
/// Esta pantalla utiliza Riverpod para la gestión de estado y sigue
/// los principios de Clean Architecture separando la lógica de
/// negocio de la presentación.
class PokemonListScreenNew extends ConsumerStatefulWidget {
  const PokemonListScreenNew({super.key});

  @override
  ConsumerState<PokemonListScreenNew> createState() => _PokemonListScreenNewState();
}

class _PokemonListScreenNewState extends ConsumerState<PokemonListScreenNew> {
  /// Colores de fondo del gradiente.
  final Color _bg1 = hex('#ff365a');
  final Color _bg2 = hex('#8c0025');

  /// Set de URLs de imágenes ya precargadas.
  final Set<String> _prefetchedImageUrls = {};

  /// ScrollController para controlar el scroll de la lista.
  final ScrollController _scrollController = ScrollController();

  /// Página anterior para detectar cambios de página.
  int _previousPage = 1;

  /// Mapa de colores por tipo de Pokémon.
  static final Map<String, Color> typeColor = {
    'fire': hex('#F57D31'),
    'water': hex('#6493EB'),
    'grass': hex('#74CB48'),
    'electric': hex('#F9CF30'),
    'ice': hex('#9AD6DF'),
    'fighting': hex('#C12239'),
    'poison': hex('#A43E9E'),
    'ground': hex('#DEC16B'),
    'flying': hex('#A891EC'),
    'psychic': hex('#FB5584'),
    'bug': hex('#A7B723'),
    'rock': hex('#B69E31'),
    'ghost': hex('#70559B'),
    'dragon': hex('#7037FF'),
    'dark': hex('#75574C'),
    'steel': hex('#B7B9D0'),
    'fairy': hex('#E69EAC'),
    'normal': hex('#AAA67F'),
  };

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
    // Cargar datos iniciales después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pokemonListProvider.notifier).loadInitial();
    });
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
    final notifier = ref.read(pokemonListProvider.notifier);

    // Detectar cambio de página y hacer scroll hacia arriba
    if (state.currentPage != _previousPage) {
      _previousPage = state.currentPage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTop();
      });
    }

    return Scaffold(
      backgroundColor: hex('#F5F7F9'),
      drawer: GenerationDrawer(
        onSelectGeneration: (int gen) {
          notifier.selectGeneration(gen == 0 ? null : gen);
          Navigator.of(context).maybePop();
        },
        typeColors: typeColor,
        selectedTypes: state.selectedTypes,
        onToggleType: notifier.toggleType,
        iconForType: iconForType,
      ),
      body: Stack(
        children: [
          // Fondo con gradiente estático
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
                // Parte superior: búsqueda y filtros
                Padding(
                  padding: const EdgeInsets. fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Indicador de generación seleccionada
                      if (state.selectedGeneration != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Mostrando: Generación ${state.selectedGeneration}',
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _bg2.withOpacity(0.8),
                        _bg2,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: PaginationControls(
                      currentPage: state.currentPage,
                      totalPages: state.totalPages,
                      hasPreviousPage: state.hasPreviousPage,
                      hasNextPage: state.hasNextPage,
                      isLoading: state.isLoading,
                      onPreviousPage: notifier.previousPage,
                      onNextPage: notifier. nextPage,
                      primaryColor: Colors.white,
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
              label: const Text('Reintentar'),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white70,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron Pokémon',
              style: TextStyle(color: Colors.white),
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