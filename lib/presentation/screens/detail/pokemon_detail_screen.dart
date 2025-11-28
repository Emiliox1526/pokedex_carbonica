import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/type_utils.dart';
import '../../../core/utils/sprite_utils.dart';
import '../../../domain/entities/pokemon.dart';
import '../../../domain/entities/detail/pokemon_form_variant.dart';
import '../../providers/detail/pokemon_detail_provider.dart';
import '../../providers/favorites/favorites_provider.dart';
import '../../widgets/detail/detail_header.dart';
import '../../widgets/detail/detail_image_section.dart';
import '../../widgets/detail/detail_tab_bar.dart';
import '../../widgets/detail/detail_card.dart';
import '../../widgets/detail/about_tab.dart';
import '../../widgets/detail/evolution_tab.dart';
import '../../widgets/detail/moves_tab.dart';
import '../../widgets/detail/pokemon_options_modal.dart';

/// Pokemon detail screen with Clean Architecture.
///
/// This screen displays detailed information about a Pokemon, including
/// its stats, moves, evolution chain, and form variants.
class PokemonDetailScreenNew extends ConsumerStatefulWidget {
  /// The Pokemon's ID.
  final int pokemonId;

  /// The Hero tag for animations.
  final String heroTag;

  /// Initial Pokemon data for immediate display.
  final Map<String, dynamic>? initialPokemon;

  const PokemonDetailScreenNew({
    super.key,
    required this.pokemonId,
    required this.heroTag,
    this.initialPokemon,
  });

  @override
  ConsumerState<PokemonDetailScreenNew> createState() =>
      _PokemonDetailScreenNewState();
}

class _PokemonDetailScreenNewState
    extends ConsumerState<PokemonDetailScreenNew> {
  @override
  void initState() {
    super.initState();
    // Load favorite status and Pokemon detail
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load favorite status from FavoritesLocalDataSource
    try {
      final favoritesDataSource = ref.read(favoritesLocalDataSourceProvider);
      final isFavorite = await favoritesDataSource.isFavorite(widget.pokemonId);
      ref.read(pokemonDetailProvider(widget.pokemonId).notifier).setFavorite(isFavorite);
    } catch (_) {
      // Ignore errors
    }

    // Load Pokemon detail
    ref.read(pokemonDetailProvider(widget.pokemonId).notifier).loadDetail();
  }

  Future<void> _toggleFavorite() async {
    final notifier = ref.read(pokemonDetailProvider(widget.pokemonId).notifier);
    final state = ref.read(pokemonDetailProvider(widget.pokemonId));
    final favoritesDataSource = ref.read(favoritesLocalDataSourceProvider);

    try {
      // Get Pokemon data from detail or initial data
      final detail = state.detail;
      Pokemon pokemon;
      
      if (detail != null) {
        pokemon = Pokemon(
          id: detail.id,
          name: detail.name,
          types: detail.types,
          imageUrl: detail.defaultSpriteUrl,
          abilities: detail.abilities.map((a) => a.name).toList(),
        );
      } else if (widget.initialPokemon != null) {
        // Fall back to initial Pokemon data
        final data = widget.initialPokemon!;
        final typesRaw = data['pokemon_v2_pokemontypes'] as List? ?? [];
        final types = typesRaw
            .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
            .toList();
        
        String? imageUrl;
        final spritesList = data['pokemon_v2_pokemonsprites'] as List?;
        if (spritesList != null && spritesList.isNotEmpty) {
          final sprites = spritesList.first['sprites'];
          if (sprites is Map) {
            imageUrl = sprites['other']?['official-artwork']?['front_default'] as String? ??
                       sprites['front_default'] as String?;
          }
        }
        
        final abilitiesRaw = data['pokemon_v2_pokemonabilities'] as List? ?? [];
        final abilities = abilitiesRaw
            .map((a) => (a['pokemon_v2_ability']?['name'] as String?) ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
        
        pokemon = Pokemon(
          id: data['id'] as int,
          name: data['name'] as String,
          types: types,
          imageUrl: imageUrl,
          abilities: abilities,
        );
      } else {
        // Create minimal Pokemon object
        pokemon = Pokemon(
          id: widget.pokemonId,
          name: 'Pokemon #${widget.pokemonId}',
          types: ['normal'],
        );
      }

      if (state.isFavorite) {
        await favoritesDataSource.removeFavorite(widget.pokemonId);
      } else {
        await favoritesDataSource.addFavorite(pokemon);
      }

      notifier.toggleFavorite();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !state.isFavorite ? 'Agregado a favoritos' : 'Eliminado de favoritos',
            ),
          ),
        );
      }
    } catch (_) {
      // Ignore errors
    }
  }

  void _openOptionsModal(Color baseColor, Color secondaryColor, String pokemonName) {
    final state = ref.read(pokemonDetailProvider(widget.pokemonId));
    final notifier = ref.read(pokemonDetailProvider(widget.pokemonId).notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: state.hasMultipleForms ? 0.65 : 0.50,
        child: PokemonOptionsModal(
          baseColor: baseColor,
          secondaryColor: secondaryColor,
          initialShowShiny: state.showShiny,
          initialIsFavorite: state.isFavorite,
          onlyLevelUp: state.movesMethodFilter == 'level-up',
          movesMethod: state.movesMethodFilter,
          movesSort: state.movesSort,
          onToggleShiny: () => notifier.toggleShiny(),
          onToggleFavorite: _toggleFavorite,
          onChangeMovesMethod: (m) {
            notifier.setMovesMethod(m);
          },
          onChangeMovesSort: (s) {
            notifier.setMovesSort(s);
          },
          onToggleOnlyLevelUp: () {
            final isLevelUp = state.movesMethodFilter == 'level-up';
            notifier.setMovesMethod(isLevelUp ? '' : 'level-up');
          },
          availableForms: state.availableForms,
          selectedFormId: state.selectedFormId,
          onFormSelected: (form) => notifier.selectForm(form),
          pokemonName: pokemonName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonDetailProvider(widget.pokemonId));
    final notifier = ref.read(pokemonDetailProvider(widget.pokemonId).notifier);

    // Loading state
    if (state.isLoading && state.detail == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey.shade400, Colors.grey.shade300],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Error state
    if (state.errorMessage != null && state.detail == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ErrorBanner(
              message: 'Error loading Pokémon details:\n${state.errorMessage}',
              onRetry: () => notifier.loadDetail(forceRefresh: true),
            ),
          ),
        ),
      );
    }

    final detail = state.activeDetail;
    if (detail == null) {
      return const Scaffold(
        body: Center(child: Text('Pokémon not found')),
      );
    }

    // Determine colors based on types
    final primaryType = detail.primaryType;
    final secondaryTypeName = detail.secondaryType;
    final baseColor = typeColor[primaryType] ?? typeColor['normal']!;
    final secondaryColor =
        typeColor[secondaryTypeName] ?? Color.lerp(baseColor, Colors.white, .35)!;

    // Get sprite URLs - prefer form sprites if a form is selected
    String? displayedDefaultUrl;
    String? displayedShinyUrl;

    final selectedForm = state.selectedForm;
    if (selectedForm != null) {
      displayedDefaultUrl = selectedForm.spriteUrl ?? detail.defaultSpriteUrl;
      displayedShinyUrl = selectedForm.shinySpriteUrl ?? detail.shinySpriteUrl;
    } else {
      displayedDefaultUrl = detail.defaultSpriteUrl;
      displayedShinyUrl = detail.shinySpriteUrl;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [baseColor, secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background pokeball icon
              Positioned.fill(
                child: Opacity(
                  opacity: 0.08,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32.0, right: 16),
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 220,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      DetailHeader(
                        pokemonName: detail.displayName,
                        idLabel: detail.formattedId,
                        isFavorite: state.isFavorite,
                        onBack: () => Navigator.of(context).maybePop(),
                        onToggleFavorite: _toggleFavorite,
                        imageUrl: displayedDefaultUrl ?? artworkUrlForId(detail.id),
                      ),
                      const SizedBox(height: 18),

                      // Pokemon image with types
                      DetailImageSection(
                        pokemonId: detail.id,
                        defaultImageUrl: displayedDefaultUrl,
                        shinyImageUrl: displayedShinyUrl,
                        showShiny: state.showShiny,
                        primaryType: primaryType,
                        secondaryType: secondaryTypeName,
                        primaryColor: baseColor,
                        secondaryColor: secondaryColor,
                        heroTag: widget.heroTag,
                      ),
                      const SizedBox(height: 20),

                      // Tab bar
                      DetailTabBar(
                        selectedIndex: state.selectedTab,
                        primaryColor: baseColor,
                        secondaryColor: secondaryColor,
                        onChanged: (index) => notifier.selectTab(index),
                        onOptionsPressed: () =>
                            _openOptionsModal(baseColor, secondaryColor, detail.displayName),
                      ),
                      const SizedBox(height: 18),

                      // Tab content
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _buildTabContent(
                          key: ValueKey(state.selectedTab),
                          tabIndex: state.selectedTab,
                          detail: detail,
                          state: state,
                          notifier: notifier,
                          baseColor: baseColor,
                          secondaryColor: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form loading overlay
              if (state.isLoadingForm)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(baseColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Loading form data...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required Key key,
    required int tabIndex,
    required dynamic detail,
    required PokemonDetailState state,
    required PokemonDetailNotifier notifier,
    required Color baseColor,
    required Color secondaryColor,
  }) {
    switch (tabIndex) {
      case 0:
        return AboutTab(
          key: key,
          detail: detail,
          baseColor: baseColor,
          secondaryColor: secondaryColor,
        );
      case 1:
        return EvolutionTab(
          key: key,
          evolutionChain: detail.evolutionChain,
          speciesName: detail.speciesName ?? detail.name,
        );
      case 2:
        return MovesTab(
          key: key,
          moves: detail.moves,
          baseColor: baseColor,
          methodFilter: state.movesMethodFilter,
          sortOrder: state.movesSort,
          currentPage: state.movesCurrentPage,
          perPage: state.movesPerPage,
          onChangeMethod: (m) => notifier.setMovesMethod(m),
          onChangeSort: (s) => notifier.setMovesSort(s),
          onPageChange: (p) => notifier.setMovesPage(p),
          onPerPageChange: (pp) => notifier.setMovesPerPage(pp),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
