
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../queries/get_pokemon_detail.dart';
import '../widgets/pokemon_options_modal.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({
    super.key,
    required this.pokemonId,
    required this.heroTag,
    this.initialPokemon,
  });

  final int pokemonId;
  final String heroTag;
  final Map<String, dynamic>? initialPokemon;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  int _selectedTab = 0;

  // UI state
  bool _isFavorite = false;
  bool _showShiny = false;

  // Moves filters/pagination
  String _movesMethodFilter = 'level-up'; // default
  int _movesLimit = 20;
  String _movesSort = 'level'; // or 'name'
  bool _onlyLevelUp = true;

  // Selected form index
  int _selectedFormIndex = 0;

  // SharedPreferences key
  static const _prefsKeyFavorites = 'favorite_pokemon_ids';

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList(_prefsKeyFavorites) ?? [];
      setState(() {
        _isFavorite = favs.contains(widget.pokemonId.toString());
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_prefsKeyFavorites) ?? [];
    setState(() {
      if (_isFavorite) {
        favs.remove(widget.pokemonId.toString());
        _isFavorite = false;
      } else {
        favs.add(widget.pokemonId.toString());
        _isFavorite = true;
      }
    });
    await prefs.setStringList(_prefsKeyFavorites, favs);
    // small feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites')),
    );
  }

  void _openOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.62,
        child: PokemonOptionsModal(
          initialShowShiny: _showShiny,
          initialIsFavorite: _isFavorite,
          onlyLevelUp: _onlyLevelUp,
          movesMethod: _movesMethodFilter,
          movesSort: _movesSort,
          onToggleShiny: () => setState(() => _showShiny = !_showShiny),
          onToggleFavorite: _toggleFavorite,
          onChangeMovesMethod: (m) => setState(() {
            _movesMethodFilter = m;
            _movesLimit = 20;
          }),
          onChangeMovesSort: (s) => setState(() => _movesSort = s),
          onToggleOnlyLevelUp: () => setState(() => _onlyLevelUp = !_onlyLevelUp),
        ),
      ),
    );
  }

  static const Map<String, Color> _typeColor = {
    "normal": Color(0xFF9BA0A8), // más limpio
    "fire": Color(0xFFFF6B3D), // más vivo
    "water": Color(0xFF4C90FF), // más brillante
    "electric": Color(0xFFFFD037), // más saturado
    "grass": Color(0xFF6BD64A), // verde Pokémon clásico
    "ice": Color(0xFF64DDF8), // celeste brillante
    "fighting": Color(0xFFE34343), // rojo fuerte
    "poison": Color(0xFFB24ADD), // morado más vivo
    "ground": Color(0xFFE2B36B), // arena vibrante
    "flying": Color(0xFFA890F7), // lavanda brillante
    "psychic": Color(0xFFFF4888), // rosa fuerte
    "bug": Color(0xFF88C12F), // verde más saturado
    "rock": Color(0xFFC9B68B), // beige cálido
    "ghost": Color(0xFF6F65D8), // púrpura fuerte
    "dragon": Color(0xFF7366FF), // azul-púrpura intenso
    "dark": Color(0xFF5A5A5A), // gris más profundo (no negro)
    "steel": Color(0xFF8AA4C1), // metálico vivo
    "fairy": Color(0xFFFF78D5), // rosado brillante
  };

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
        return Icons.circle;
    }
  }

  String formatStatName(String raw) {
    switch (raw) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Attack';
      case 'special-defense':
        return 'Sp. Defense';
      case 'speed':
        return 'Speed';
      default:
        return raw;
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  // Helper para construir URL oficial de artwork por id (fallback si no hay sprite en DB)
  String _artworkUrlForId(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  // Extrae urls default + shiny desde pokemon object (si posible)
  Map<String, String?> _extractSpriteUrls(Map<String, dynamic> pokemon) {
    final spriteList = pokemon['pokemon_v2_pokemonsprites'] as List?;
    if (spriteList == null || spriteList.isEmpty) return {'default': null, 'shiny': null};
    final raw = spriteList.first['sprites'];
    if (raw == null) return {'default': null, 'shiny': null};
    Map<String, dynamic> decoded;
    if (raw is String) {
      try {
        decoded = json.decode(raw) as Map<String, dynamic>;
      } catch (_) {
        return {'default': null, 'shiny': null};
      }
    } else if (raw is Map<String, dynamic>) {
      decoded = raw;
    } else {
      return {'default': null, 'shiny': null};
    }
    final defaultUrl =
        decoded['other']?['official-artwork']?['front_default'] ??
            decoded['other']?['home']?['front_default'] ??
            decoded['front_default'] ??
            decoded['front_shiny'] ??
            decoded['front_female'] ??
            decoded['back_default'];
    final shinyUrl =
        decoded['other']?['official-artwork']?['front_shiny'] ??
            decoded['other']?['home']?['front_shiny'] ??
            decoded['front_shiny'];
    return {'default': defaultUrl as String?, 'shiny': shinyUrl as String?};
  }

  // Capitalize helper
  String _capitalize(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.replaceAll('-', ' ').split(' ');
    return parts.map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w).join(' ');
  }

  // Simple full type effectiveness chart (attacker -> defender -> multiplier).
  // Source: standard Pokémon type chart. This covers all types used in repo.
  static const Map<String, Map<String, double>> _typeChart = {
    "normal": {
      "rock": 0.5, "ghost": 0.0, "steel": 0.5
    },
    "fire": {
      "fire": 0.5, "water": 0.5, "grass": 2.0, "ice": 2.0, "bug": 2.0, "rock": 0.5, "dragon": 0.5, "steel": 2.0
    },
    "water": {
      "fire": 2.0, "water": 0.5, "grass": 0.5, "ground": 2.0, "rock": 2.0, "dragon": 0.5
    },
    "electric": {
      "water": 2.0, "electric": 0.5, "grass": 0.5, "ground": 0.0, "flying": 2.0, "dragon": 0.5
    },
    "grass": {
      "fire": 0.5, "water": 2.0, "grass": 0.5, "poison": 0.5, "ground": 2.0, "flying": 0.5, "bug": 0.5, "rock": 2.0, "dragon": 0.5, "steel": 0.5
    },
    "ice": {
      "fire": 0.5, "water": 0.5, "grass": 2.0, "ice": 0.5, "ground": 2.0, "flying": 2.0, "dragon": 2.0, "steel": 0.5
    },
    "fighting": {
      "normal": 2.0, "ice": 2.0, "poison": 0.5, "flying": 0.5, "psychic": 0.5, "bug": 0.5, "rock": 2.0, "ghost": 0.0, "dark": 2.0, "steel": 2.0, "fairy": 0.5
    },
    "poison": {
      "grass": 2.0, "poison": 0.5, "ground": 0.5, "rock": 0.5, "ghost": 0.5, "steel": 0.0, "fairy": 2.0
    },
    "ground": {
      "fire": 2.0, "electric": 2.0, "grass": 0.5, "poison": 2.0, "flying": 0.0, "bug": 0.5, "rock": 2.0, "steel": 2.0
    },
    "flying": {
      "electric": 0.5, "grass": 2.0, "fighting": 2.0, "bug": 2.0, "rock": 0.5, "steel": 0.5
    },
    "psychic": {
      "fighting": 2.0, "poison": 2.0, "psychic": 0.5, "dark": 0.0, "steel": 0.5
    },
    "bug": {
      "fire": 0.5, "grass": 2.0, "fighting": 0.5, "poison": 0.5, "flying": 0.5, "psychic": 2.0, "ghost": 0.5, "dark": 2.0, "steel": 0.5, "fairy": 0.5
    },
    "rock": {
      "fire": 2.0, "ice": 2.0, "fighting": 0.5, "ground": 0.5, "flying": 2.0, "bug": 2.0, "steel": 0.5
    },
    "ghost": {
      "normal": 0.0, "psychic": 2.0, "ghost": 2.0, "dark": 0.5
    },
    "dragon": {
      "dragon": 2.0, "steel": 0.5, "fairy": 0.0
    },
    "dark": {
      "fighting": 0.5, "psychic": 2.0, "ghost": 2.0, "dark": 0.5, "fairy": 0.5
    },
    "steel": {
      "fire": 0.5, "water": 0.5, "electric": 0.5, "ice": 2.0, "rock": 2.0, "fairy": 2.0, "steel": 0.5
    },
    "fairy": {
      "fire": 0.5, "fighting": 2.0, "poison": 0.5, "dragon": 2.0, "dark": 2.0, "steel": 0.5
    },
  };

  // Compute total multiplier of an attacking type vs target types.
  double _typeMultiplierAgainst(List<String> defenderTypes, String attacker) {
    var m = 1.0;
    for (final def in defenderTypes) {
      final row = _typeChart[attacker];
      if (row != null && row.containsKey(def)) {
        m *= row[def]!;
      } else {
        m *= 1.0;
      }
    }
    return m;
  }

  // Determine weaknesses/resistances for this Pokémon types.
  Map<String, double> _computeMatchups(List<String> defenderTypes) {
    final Map<String, double> results = {};
    for (final attacker in _typeChart.keys) {
      results[attacker] = _typeMultiplierAgainst(defenderTypes, attacker);
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetailQuery),
          variables: {'id': widget.pokemonId},
          fetchPolicy:
          widget.initialPokemon != null ? FetchPolicy.cacheAndNetwork : FetchPolicy.cacheFirst,
        ),
        builder: (result, {fetchMore, refetch}) {
          // 1. Loading: si no hay datos todavía, muestra el loader
          if (result.isLoading && result.data == null && widget.initialPokemon == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Manejo de error
          if (result.hasException) {
            // Si NO tienes initialPokemon, muestra el banner de error como antes
            if (widget.initialPokemon == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _ErrorBanner(
                    message: 'Error loading Pokémon details:\n${result.exception}',
                    onRetry: refetch,
                  ),
                ),
              );
            } else {
              // Si SÍ tienes initialPokemon, avisa en consola al menos
              debugPrint('Error loading Pokémon details: ${result.exception}');
              // seguimos usando initialPokemon como fallback visual
            }
          }

          // 3. Tomar primero lo que venga de la query; si falla, usar initialPokemon
          final pokemonFromQuery =
          result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;
          final pokemon = pokemonFromQuery ?? widget.initialPokemon;

          if (pokemon == null) {
            return const Center(child: Text('Pokémon not found'));
          }

          // --- Identity
          final pokemonName = (pokemon['name'] as String? ?? 'Unknown')
              .replaceAll('-', ' ')
              .split(' ')
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' ');
          final idLabel = '#${pokemon['id'].toString().padLeft(3, '0')}';

          // Types
          final types = ((pokemon['pokemon_v2_pokemontypes'] as List?) ?? [])
              .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
              .where((t) => t.isNotEmpty)
              .cast<String>()
              .toList();
          final primaryType = types.isNotEmpty ? types.first : 'normal';
          final secondaryTypeName = types.length > 1 ? types[1] : primaryType;

          // Colors
          final baseColor = _typeColor[primaryType] ?? _typeColor['normal']!;
          final secondaryColor = _typeColor[secondaryTypeName] ?? Color.lerp(baseColor, Colors.white, .35)!;

          // Sprites
          final spriteUrls = _extractSpriteUrls(pokemon);
          final defaultImageUrl = spriteUrls['default'];
          final shinyImageUrl = spriteUrls['shiny'];
          final displayedImageUrl = _showShiny ? (shinyImageUrl ?? defaultImageUrl) : (defaultImageUrl ?? shinyImageUrl);

          // Forms (variants)
          final forms = ((pokemon['pokemon_v2_pokemonforms'] as List?) ?? [])
              .map((f) {
            return {
              'form_name': f['form_name'] as String?,
              'form_identifier': f['form_identifier'] as String?,
              'is_default': f['is_default'] as bool? ?? false,
            };
          })
              .toList(growable: false);

          // Abilities: include name, is_hidden, short_effect (english)
          final abilities = ((pokemon['pokemon_v2_pokemonabilities'] as List?) ?? []).map((a) {
            final ability = a['pokemon_v2_ability'] as Map<String, dynamic>?;
            final effectList = (ability?['pokemon_v2_abilityeffecttexts'] as List?) ?? [];
            String shortEffect = '';
            for (final ef in effectList) {
              final lang = ef['language']?['name'] as String? ?? '';
              if (lang == 'en') {
                shortEffect = (ef['short_effect'] as String? ?? '').replaceAll('\n', ' ').trim();
                break;
              }
            }
            if (shortEffect.length > 160) shortEffect = shortEffect.substring(0, 157) + '...';
            return {
              'name': ability?['name'] as String? ?? '',
              'is_hidden': a['is_hidden'] as bool? ?? false,
              'short_effect': shortEffect,
            };
          }).toList();

          // Stats - Extract base stats from pokemon_v2_pokemonstats
          final rawStats = (pokemon['pokemon_v2_pokemonstats'] as List?) ?? [];
          final List<Map<String, dynamic>> stats = [];
          for (final s in rawStats) {
            final statObj = s['pokemon_v2_stat'];
            final statName = statObj?['name'] as String? ?? '';
            final baseStat = s['base_stat'] as int? ?? 0;
            if (statName.isNotEmpty) {
              stats.add({
                'name': formatStatName(statName),
                'value': baseStat,
              });
            }
          }
          final totalStats = stats.fold<int>(0, (prev, s) => prev + (s['value'] as int));
          // Moves: include learn method, type, damage_class, version group id, level
          final rawMoves = ((pokemon['pokemon_v2_pokemonmoves'] as List?) ?? []).map((m) {
            final mv = m['pokemon_v2_move'] as Map<String, dynamic>?;
            return {
              'name': mv?['name'] as String? ?? '',
              'type': mv?['pokemon_v2_type']?['name'] as String? ?? '',
              'damage_class': mv?['pokemon_v2_movedamageclass']?['name'] as String? ?? '',
              'level': m['level'] as int?,
              'method': m['pokemon_v2_movelearnmethod']?['name'] as String? ?? '',
              'version_group_id': m['version_group_id'] as int?,
            };
          }).where((m) => (m['name'] as String).isNotEmpty).toList();

          // Use rawMoves directly to preserve all move variants (different learn methods)
          // This ensures filters by method (level-up, machine, egg, tutor) work correctly
          final movesList = rawMoves.map((e) => Map<String, dynamic>.from(e)).toList();

          // Height / Weight / baseExp
          // Note: height is in decimeters (dm), weight is in hectograms (hg)
          // Convert to meters and kg by dividing by 10
          final heightDm = (pokemon['height'] as int?) ?? 0; // decimeters
          final weightHg = (pokemon['weight'] as int?) ?? 0; // hectograms
          final heightMeters = heightDm / 10.0; // convert dm to meters
          final weightKg = weightHg / 10.0; // convert hg to kg
          final baseExperience = (pokemon['base_experience'] as int?) ?? 0;
          
          // Debug logging for height/weight validation (only in debug mode)
          if (kDebugMode) {
            debugPrint('Pokemon ${pokemon['name']}: height=$heightDm dm (${heightMeters}m), weight=$weightHg hg (${weightKg}kg)');
          }

          // Evolution species (from initial query)
          final speciesObj = pokemon['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
          final evolutionSpeciesRaw =
              (speciesObj?['pokemon_v2_evolutionchain']?['pokemon_v2_pokemonspecies'] as List?) ?? [];
          final evolutionSpecies = evolutionSpeciesRaw.cast<Map<String, dynamic>>();

          // Build the UI
          return Container(
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
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with back, name, id, favorite button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _CircleButton(
                                icon: Icons.arrow_back,
                                onTap: () => Navigator.of(context).maybePop(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pokemonName,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(1, 2), blurRadius: 4),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleFavorite,
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: _isFavorite
                                      ? const Icon(Icons.favorite, color: Colors.red, key: ValueKey('fav_on'))
                                      : const Icon(Icons.favorite_border, color: Colors.white, key: ValueKey('fav_off')),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // share: copy to clipboard
                                  final txt = '$pokemonName $idLabel\n${displayedImageUrl ?? _artworkUrlForId(pokemon['id'] as int)}';
                                  Clipboard.setData(ClipboardData(text: txt));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied Pokémon info to clipboard')));
                                },
                                icon: const Icon(Icons.share, color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                idLabel,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Center image with type chips (responsive as before)
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                LayoutBuilder(builder: (context, constraints) {
                                  final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
                                      ? constraints.maxWidth
                                      : MediaQuery.of(context).size.width - 32; // fallback
                                  final imageDiameter = math.max(100.0, math.min(360.0, availableWidth * 0.48));
                                  final scale = imageDiameter / 220.0;
                                  final chipOffset = imageDiameter * 0.45;

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      Hero(
                                        tag: widget.heroTag,
                                        child: Container(
                                          width: imageDiameter,
                                          height: imageDiameter,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.25),
                                                blurRadius: 24,
                                                offset: const Offset(0, 12),
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: AnimatedCrossFade(
                                              duration: const Duration(milliseconds: 300),
                                              crossFadeState: _showShiny ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                              firstChild: Image.network(
                                                defaultImageUrl ?? _artworkUrlForId(pokemon['id'] as int),
                                                fit: BoxFit.contain,
                                                errorBuilder: (c, e, s) => Image.network(_artworkUrlForId(pokemon['id'] as int), fit: BoxFit.contain),
                                              ),
                                              secondChild: Image.network(
                                                shinyImageUrl ?? defaultImageUrl ?? _artworkUrlForId(pokemon['id'] as int),
                                                fit: BoxFit.contain,
                                                errorBuilder: (c, e, s) => Image.network(_artworkUrlForId(pokemon['id'] as int), fit: BoxFit.contain),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: -chipOffset,
                                        child: _TypeColumn(
                                          icon: _iconForType(primaryType),
                                          color: baseColor,
                                          label: primaryType,
                                          scale: scale,
                                        ),
                                      ),
                                      if (secondaryTypeName != null)
                                        Positioned(
                                          right: -chipOffset,
                                          child: _TypeColumn(
                                            icon: _iconForType(secondaryTypeName),
                                            color: secondaryColor,
                                            label: secondaryTypeName!,
                                            scale: scale,
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tabs
                          _TabsCard(
                            selectedIndex: _selectedTab,
                            primaryColor: baseColor,
                            secondaryColor: secondaryColor,
                            onChanged: _onTabSelected,
                            onOptionsPressed: _openOptionsModal,
                          ),
                          const SizedBox(height: 18),

                          // Tab content (pass many params and callbacks)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: _buildTabBody(
                              key: ValueKey(_selectedTab),
                              tabIndex: _selectedTab,
                              baseColor: baseColor,
                              secondaryColor: secondaryColor,
                              baseExperience: baseExperience,
                              abilities: abilities,
                              stats: stats,
                              totalStats: totalStats,
                              uniqueMoves: movesList,
                              evolutionSpecies: evolutionSpecies,
                              speciesName: (pokemon['name'] as String?) ?? '',
                              isFavorite: _isFavorite,
                              onToggleFavorite: _toggleFavorite,
                              showShiny: _showShiny,
                              onToggleShiny: () => setState(() => _showShiny = !_showShiny),
                              forms: forms,
                              selectedFormIndex: _selectedFormIndex,
                              onSelectForm: (i) => setState(() => _selectedFormIndex = i),
                              movesMethodFilter: _movesMethodFilter,
                              onChangeMovesMethod: (m) => setState(() {
                                _movesMethodFilter = m;
                                _movesLimit = 20;
                              }),
                              movesSort: _movesSort,
                              onChangeMovesSort: (s) => setState(() => _movesSort = s),
                              movesLimit: _movesLimit,
                              onLoadMoreMoves: () => setState(() => _movesLimit += 20),
                              onlyLevelUp: _onlyLevelUp,
                              onToggleOnlyLevelUp: () => setState(() => _onlyLevelUp = !_onlyLevelUp),
                              movesList: movesList,
                              pokemonName: pokemonName,
                              pokemonId: pokemon['id'] as int,
                              computeMatchups: (types) => _computeMatchups(types),
                              // Height in meters, weight in kg (converted from dm and hg)
                              heightMeters: heightMeters,
                              weightKg: weightKg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- Tab Body (top-level helper) -----------------
// Stats bar background color (pink/magenta)
const Color _kStatBarBackgroundColor = Color(0xFFF5B5C8);

// Maximum number of abilities to display in the About tab
const int _kMaxAbilitiesToShow = 2;

// This function receives the data and UI callbacks from the State and renders each tab.
Widget _buildTabBody({
  Key? key,
  required int tabIndex,
  required Color baseColor,
  required Color secondaryColor,
  required int baseExperience,
  required List<Map<String, dynamic>> abilities,
  required List<Map<String, dynamic>> stats,
  required int totalStats,
  required List<Map<String, dynamic>> uniqueMoves,
  required List<Map<String, dynamic>> evolutionSpecies,
  required String speciesName,
  required bool isFavorite,
  required VoidCallback onToggleFavorite,
  required bool showShiny,
  required VoidCallback onToggleShiny,
  required List<Map<String, dynamic>> forms,
  required int selectedFormIndex,
  required ValueChanged<int> onSelectForm,
  required String movesMethodFilter,
  required ValueChanged<String> onChangeMovesMethod,
  required String movesSort,
  required ValueChanged<String> onChangeMovesSort,
  required int movesLimit,
  required VoidCallback onLoadMoreMoves,
  required bool onlyLevelUp,
  required VoidCallback onToggleOnlyLevelUp,
  required List<Map<String, dynamic>> movesList,
  required String pokemonName,
  required int pokemonId,
  required Map<String, double> Function(List<String>) computeMatchups,
  required double heightMeters,
  required double weightKg,
  String? description,
}) {
  switch (tabIndex) {
    case 0:
    // ABOUT - Redesigned to match reference design
    // Helper to get abbreviated stat name
      String getAbbreviatedStatName(String name) {
        switch (name) {
          case 'HP':
            return 'HP';
          case 'Attack':
            return 'ATK';
          case 'Defense':
            return 'DEF';
          case 'Sp. Attack':
            return 'SATK';
          case 'Sp. Defense':
            return 'SDEF';
          case 'Speed':
            return 'SPD';
          default:
            return name;
        }
      }

      // Get abilities names for display
      final abilityNames = abilities
          .where((ab) => !(ab['is_hidden'] as bool))
          .map((ab) => _capitalizeLocal(ab['name'] as String))
          .toList();

      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title "About" centered
            Center(
              child: Text(
                'About',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main info row: Weight | Height | Abilities (separated by vertical lines)
            IntrinsicHeight(
              child: Row(
                children: [
                  // Weight column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.balance, size: 18, color: Colors.grey. shade700),
                            const SizedBox(width: 6),
                            Text(
                              '${weightKg.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Weight',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vertical divider
                  Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  // Height column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.straighten, size: 18, color: Colors.grey.shade700),
                            const SizedBox(width: 6),
                            Text(
                              '${heightMeters.toStringAsFixed(1)} m',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey. shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Height',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vertical divider
                  Container(
                    width: 1,
                    color: Colors.grey. shade300,
                  ),
                  // Abilities column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            for (final name in abilityNames. take(_kMaxAbilitiesToShow))
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Abilities',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description section (shown if description is provided)
            if (description != null && description. isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
                child: Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors. grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),

            // Base Stats section
            Center(
              child: Text(
                'Base Stats',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Radar Chart for stats
            if (stats.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'No stats available',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 280,
                  child: _RadarChart(
                    data: stats.map((s) => (s['value'] as int).toDouble()).toList(),
                    labels: stats.map((s) => getAbbreviatedStatName(s['name'] as String)).toList(),
                    maxValue: 255,
                    baseColor: baseColor,
                    secondaryColor: secondaryColor,
                  ),
                ),
              ),

            const SizedBox(height: 12),
          ],
        ),
      );

    case 1:
    // EVOLUTION
      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Evolution Chart',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 12),
            if (evolutionSpecies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                child: Column(
                  children: [
                    for (var i = 0; i < evolutionSpecies.length; i++) ...[
                      _EvolutionNode(
                        id: (evolutionSpecies[i]['id'] as int?) ?? 0,
                        name: (evolutionSpecies[i]['name'] as String?) ?? '',
                      ),
                      if (i < evolutionSpecies.length - 1) ...[
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))
                                ],
                              ),
                              child: const Center(
                                child: Text('Lv. -', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Icon(Icons.arrow_downward, size: 36, color: Colors.redAccent),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ]
                    ],
                  ],
                ),
              )
            else
            // fallback query by species name is done at runtime inside the widget tree
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                child: Query(
                  options: QueryOptions(
                    document: gql(r'''
                      query GetEvolutionBySpeciesName($name: String!) {
                        pokemon_v2_pokemonspecies(where: {name: {_eq: $name}}) {
                          id
                          name
                          pokemon_v2_evolutionchain {
                            id
                            pokemon_v2_pokemonspecies(order_by: {id: asc}) {
                              id
                              name
                            }
                          }
                        }
                      }
                    '''),
                    variables: {'name': speciesName.toLowerCase()},
                    fetchPolicy: FetchPolicy.networkOnly,
                  ),
                  builder: (res, {fetchMore, refetch}) {
                    if (res.isLoading) return const Center(child: CircularProgressIndicator());
                    if (res.hasException) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: Text('Error loading evolution data', style: TextStyle(color: Colors.grey.shade700))),
                      );
                    }
                    final speciesList = (res.data?['pokemon_v2_pokemonspecies'] as List?) ?? [];
                    if (speciesList.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 64.0),
                        child: Center(child: Text('No evolution data available')),
                      );
                    }
                    final chain = (speciesList.first['pokemon_v2_evolutionchain']?['pokemon_v2_pokemonspecies'] as List?) ?? [];
                    final chainItems = chain.cast<Map<String, dynamic>>();
                    if (chainItems.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 64.0),
                        child: Center(child: Text('No evolution data available')),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < chainItems.length; i++) ...[
                          _EvolutionNode(
                            id: (chainItems[i]['id'] as int?) ?? 0,
                            name: (chainItems[i]['name'] as String?) ?? '',
                          ),
                          if (i < chainItems.length - 1) ...[
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text('Lv. -', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Icon(Icons.arrow_downward, size: 36, color: Colors.redAccent),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ]
                        ],
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );

    case 2:
    // MOVES
    // Apply filters (method and onlyLevelUp)
      List<Map<String, dynamic>> filtered = List.from(movesList);
      if (onlyLevelUp) {
        filtered = filtered.where((m) => (m['method'] as String?) == 'level-up').toList();
      } else if (movesMethodFilter.isNotEmpty) {
        filtered = filtered.where((m) => (m['method'] as String?) == movesMethodFilter).toList();
      }
      if (movesSort == 'level') {
        filtered.sort((a, b) {
          final int la = (a['level'] as int?) ?? 9999;
          final int lb = (b['level'] as int?) ?? 9999;
          if (la != lb) return la.compareTo(lb);
          return (a['name'] as String).compareTo(b['name'] as String);
        });
      } else {
        filtered.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
      }
      final visible = filtered.take(movesLimit).toList();

      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Moves', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87))),
            const SizedBox(height: 12),
            // Filters row
            Row(
              children: [
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: movesMethodFilter,
                  items: const [
                    DropdownMenuItem(value: 'level-up', child: Text('Level-up')),
                    DropdownMenuItem(value: 'machine', child: Text('Machine (TM/HM)')),
                    DropdownMenuItem(value: 'tutor', child: Text('Tutor')),
                    DropdownMenuItem(value: 'egg', child: Text('Egg')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => onChangeMovesMethod(v ?? 'level-up'),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: movesSort,
                  items: const [
                    DropdownMenuItem(value: 'level', child: Text('Sort: Level')),
                    DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
                  ],
                  onChanged: (v) => onChangeMovesSort(v ?? 'level'),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text('Only level-up'),
                    Switch(value: onlyLevelUp, onChanged: (_) => onToggleOnlyLevelUp()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (visible.isEmpty)
              const Center(child: Text('No moves found with current filters', style: TextStyle(color: Colors.grey)))
            else
              Column(
                children: [
                  for (final mv in visible)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              _capitalizeLocal(mv['name'] as String),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              (mv['type'] as String).isNotEmpty ? (mv['type'] as String).toUpperCase() : '—',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              (mv['damage_class'] as String).isNotEmpty ? _capitalizeLocal(mv['damage_class'] as String) : '—',
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                (mv['level'] as int?)?.toString() ?? '—',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (filtered.length > movesLimit)
                    TextButton(onPressed: onLoadMoreMoves, child: const Text('Load more')),
                ],
              ),
          ],
        ),
      );

    default:
      return const SizedBox.shrink();
  }
}

// ---------- Small helper widgets and classes ----------

class _AboutInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _AboutInfoCard({required this.title, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))
      ]),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(content, style: const TextStyle(fontWeight: FontWeight.w700)),
          ])
        ],
      ),
    );
  }
}

// Enhanced radar chart implementation with gradients (custom painter)
class _RadarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final double maxValue;
  final Color baseColor;
  final Color secondaryColor;

  const _RadarChart({
    required this.data,
    required this.labels,
    required this.maxValue,
    required this.baseColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarPainter(
        data: data,
        labels: labels,
        maxValue: maxValue,
        baseColor: baseColor,
        secondaryColor: secondaryColor,
      ),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double maxValue;
  final Color baseColor;
  final Color secondaryColor;

  _RadarPainter({
    required this.data,
    required this.labels,
    required this.maxValue,
    required this.baseColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) * 0.65;

    final n = math.max(3, data.length);

    // Paint for concentric ring guides (gray background lines)
    final paintGrid = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Paint for radial lines from center to vertices
    final paintRadialLines = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw radial lines from center to each vertex
    for (var i = 0; i < n; i++) {
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      canvas.drawLine(Offset(cx, cy), Offset(x, y), paintRadialLines);
    }

    // Draw concentric hexagonal/polygonal ring guides
    const rings = 4;
    for (var r = 1; r <= rings; r++) {
      final rr = radius * (r / rings);
      final path = Path();
      for (var i = 0; i < n; i++) {
        final angle = (math.pi * 2 / n) * i - math.pi / 2;
        final x = cx + rr * math.cos(angle);
        final y = cy + rr * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paintGrid);
    }

    // Build the data polygon path and collect vertex points
    final pathData = Path();
    final List<Offset> dataPoints = [];
    for (var i = 0; i < n; i++) {
      final val = (i < data.length) ? (data[i].clamp(0, maxValue) / maxValue) : 0.0;
      final r = radius * val;
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      dataPoints.add(Offset(x, y));
      if (i == 0) {
        pathData.moveTo(x, y);
      } else {
        pathData.lineTo(x, y);
      }
    }
    pathData.close();

    // Create gradient paint for fill - yellow/orange at top to pink/coral at bottom
    // Using baseColor and secondaryColor from Pokemon type for coherence
    final gradientColors = [
      Color.lerp(const Color(0xFFFFD54F), baseColor, 0.3) ?? const Color(0xFFFFD54F), // Yellow/orange tint
      Color.lerp(const Color(0xFFFF8A80), secondaryColor, 0.3) ?? const Color(0xFFFF8A80), // Pink/coral tint
    ];

    final paintGradientFill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx, cy - radius), // Top
        Offset(cx, cy + radius), // Bottom
        gradientColors,
      )
      ..style = PaintingStyle.fill;

    // Draw the gradient fill with transparency
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPath(pathData, paintGradientFill..color = paintGradientFill.color.withOpacity(0.7));
    canvas.restore();

    // Draw the data polygon fill with gradient
    canvas.drawPath(pathData, paintGradientFill);

    // Draw the data polygon border/stroke
    final paintStroke = Paint()
      ..color = Color.lerp(baseColor, secondaryColor, 0.5)?.withOpacity(0.8) ?? baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(pathData, paintStroke);

    // Draw small black circles at each vertex of the data polygon
    final paintVertex = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    for (final point in dataPoints) {
      canvas.drawCircle(point, 4, paintVertex);
    }

    // Draw central circle
    final paintCenterCircle = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 4, paintCenterCircle);

    // Draw external labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < n; i++) {
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      // Position labels further out from the chart
      final labelRadius = radius + 24;
      final x = cx + labelRadius * math.cos(angle);
      final y = cy + labelRadius * math.sin(angle);

      final label = (i < labels.length) ? labels[i] : '';
      final tp = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      );
      textPainter.text = tp;
      textPainter.layout();

      // Adjust offset based on position for better alignment
      double offsetX = x - textPainter.width / 2;
      double offsetY = y - textPainter.height / 2;

      // Fine-tune positioning based on angle
      if (angle > -math.pi / 4 && angle < math.pi / 4) {
        // Top area - move up slightly
        offsetY -= 4;
      } else if (angle > 3 * math.pi / 4 || angle < -3 * math.pi / 4) {
        // Bottom area - move down slightly
        offsetY += 4;
      }

      textPainter.paint(canvas, Offset(offsetX, offsetY));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.labels != labels ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.secondaryColor != secondaryColor;
}

class _EvolutionNode extends StatelessWidget {
  final int id;
  final String name;

  const _EvolutionNode({
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w).join(' ');
    final artworkUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return Column(
      children: [
        Text(
          displayName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '#${id.toString().padLeft(3, '0')}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PokemonDetailScreen(
              pokemonId: id,
              heroTag: 'pokemon_$id',
              initialPokemon: null,
            )));
          },
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: ClipOval(
              child: Image.network(
                artworkUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeColumn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double scale;

  const _TypeColumn({
    required this.icon,
    required this.color,
    required this.label,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypeChip(icon: icon, color: color, scale: scale),
        SizedBox(height: 8 * scale),
        _TypeLabelChip(label: label, scale: scale),
      ],
    );
  }
}

class _TypeLabelChip extends StatelessWidget {
  final String label;
  final double scale;

  const _TypeLabelChip({required this.label, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 2 * scale),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: math.max(10.0, 14.0 * scale), fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double scale;

  const _TypeChip({required this.icon, required this.color, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final outerSize = 62.0 * scale;
    final innerSize = 44.0 * scale;
    final iconSize = 22.0 * scale;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4 * scale))
      ]),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}

class _TabsCard extends StatelessWidget {
  const _TabsCard({required this.selectedIndex, required this.primaryColor, required this.secondaryColor, required this.onChanged, this.onOptionsPressed});

  final int selectedIndex;
  final Color primaryColor;
  final Color secondaryColor;
  final ValueChanged<int> onChanged;
  final VoidCallback? onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    final aboutColor = primaryColor;
    final evolutionColor = primaryColor;
    final movesColor = secondaryColor;
    final optionsColor = secondaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 18, offset: const Offset(0, 6))
      ]),
      child: Row(
        children: [
          Expanded(child: _TabButton(label: 'About', icon: Icons.info_outline, color: aboutColor, selected: selectedIndex == 0, onTap: () => onChanged(0))),
          Expanded(child: _TabButton(label: 'Evolution', icon: Icons.auto_graph, color: evolutionColor, selected: selectedIndex == 1, onTap: () => onChanged(1))),
          Expanded(child: _TabButton(label: 'Moves', icon: Icons.blur_circular, color: movesColor, selected: selectedIndex == 2, onTap: () => onChanged(2))),
          // Options opens a modal, not a tab panel, so it's never marked as selected
          Expanded(child: _TabButton(label: 'Options', icon: Icons.tune, color: optionsColor, selected: false, onTap: onOptionsPressed ?? () {})),
        ],
      ),
    );
  }
}
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color ringColor = selected ? color : Colors.grey.shade300;
    final Color iconBg = Colors.grey.shade900;
    final Color textColor = selected ? color : Colors.grey.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// CÍRCULO CON ICONO
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ringColor,
                width: 4,
              ),
            ),
            child: Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// TEXTO DEBAJO
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}


// --- Componentes auxiliares ---

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 20)),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({super.key, required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: background, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 24, offset: const Offset(0, -4))
    ]), child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), child: child));
  }
}

class _AboutBlock extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _AboutBlock({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [Icon(icon, size: 18), const SizedBox(height: 8), Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(label, style: TextStyle(color: Colors.black.withOpacity(.6))) ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color primaryColor;
  final Color secondaryColor;

  const _StatRow({required this.label, required this.value, required this.primaryColor, required this.secondaryColor});

  @override
  Widget build(BuildContext context) {
    final pct = (value / 255).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
      child: Row(children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
        Expanded(child: Container(height: 12, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: pct, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryColor, secondaryColor]), borderRadius: BorderRadius.circular(6)))))),
        const SizedBox(width: 12),
        SizedBox(width: 30, child: Text(value.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700)))
      ]),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorBanner({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade700,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

// Two-color progress bar widget for stats
class _TwoColorProgressBar extends StatelessWidget {
  final double value;
  final Color fillColor;
  final Color backgroundColor;

  const _TwoColorProgressBar({
    required this.value,
    required this.fillColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: backgroundColor,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedValue,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: fillColor,
          ),
        ),
      ),
    );
  }
}

// Local helper to capitalize (used in UI areas)
String _capitalizeLocal(String raw) {
  if (raw.isEmpty) return raw;
  final parts = raw.replaceAll('-', ' ').split(' ');
  return parts.map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w).join(' ');
}