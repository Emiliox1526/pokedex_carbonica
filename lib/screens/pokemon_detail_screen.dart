
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

// Shared type color map used across the detail screen
const Map<String, Color> _kTypeColor = {
  "normal": Color(0xFF9BA0A8),
  "fire": Color(0xFFFF6B3D),
  "water": Color(0xFF4C90FF),
  "electric": Color(0xFFFFD037),
  "grass": Color(0xFF6BD64A),
  "ice": Color(0xFF64DDF8),
  "fighting": Color(0xFFE34343),
  "poison": Color(0xFFB24ADD),
  "ground": Color(0xFFE2B36B),
  "flying": Color(0xFFA890F7),
  "psychic": Color(0xFFFF4888),
  "bug": Color(0xFF88C12F),
  "rock": Color(0xFFC9B68B),
  "ghost": Color(0xFF6F65D8),
  "dragon": Color(0xFF7366FF),
  "dark": Color(0xFF5A5A5A),
  "steel": Color(0xFF8AA4C1),
  "fairy": Color(0xFFFF78D5),
};

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
  
  // Page-based pagination for moves
  int _movesCurrentPage = 0;
  int _movesPerPage = 10;

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

  static const Map<String, Color> _typeColor = _kTypeColor;

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
          // Moves: include learn method, type, damage_class, version group id, level, TM/HM info
          final rawMoves = ((pokemon['pokemon_v2_pokemonmoves'] as List?) ?? []).map((m) {
            final mv = m['pokemon_v2_move'] as Map<String, dynamic>?;
            final moveType = mv?['pokemon_v2_type']?['name'] as String? ?? '';
            
            // Extract TM/HM information
            String? tmName;
            int? tmNumber;
            String? tmSpriteUrl;
            final machines = (mv?['pokemon_v2_machines'] as List?) ?? [];
            if (machines.isNotEmpty) {
              // Use the first machine entry (typically the most recent version)
              final machine = machines.first as Map<String, dynamic>?;
              if (machine != null) {
                tmNumber = machine['machine_number'] as int?;
                final item = machine['pokemon_v2_item'] as Map<String, dynamic>?;
                if (item != null) {
                  tmName = item['name'] as String?;
                  // Try to get sprite from item sprites
                  final itemSprites = (item['pokemon_v2_itemsprites'] as List?) ?? [];
                  if (itemSprites.isNotEmpty) {
                    final spritesData = itemSprites.first['sprites'];
                    if (spritesData != null) {
                      Map<String, dynamic>? spritesMap;
                      if (spritesData is String) {
                        try {
                          spritesMap = json.decode(spritesData) as Map<String, dynamic>?;
                        } catch (e) {
                          // Log decode error in debug mode for troubleshooting
                          if (kDebugMode) {
                            debugPrint('Failed to decode item sprites JSON: $e');
                          }
                        }
                      } else if (spritesData is Map<String, dynamic>) {
                        spritesMap = spritesData;
                      }
                      tmSpriteUrl = spritesMap?['default'] as String?;
                    }
                  }
                }
              }
            }
            // Fallback sprite URL based on move type
            tmSpriteUrl ??= moveType.isNotEmpty
                ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/tm-$moveType.png'
                : null;
            
            return {
              'name': mv?['name'] as String? ?? '',
              'type': moveType,
              'damage_class': mv?['pokemon_v2_movedamageclass']?['name'] as String? ?? '',
              'level': m['level'] as int?,
              'method': m['pokemon_v2_movelearnmethod']?['name'] as String? ?? '',
              'version_group_id': m['version_group_id'] as int?,
              'tm_name': tmName,
              'tm_number': tmNumber,
              'tm_sprite_url': tmSpriteUrl,
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
                                _movesCurrentPage = 0; // Reset to first page
                              }),
                              movesSort: _movesSort,
                              onChangeMovesSort: (s) => setState(() {
                                _movesSort = s;
                                _movesCurrentPage = 0; // Reset to first page
                              }),
                              movesLimit: _movesLimit,
                              onLoadMoreMoves: () => setState(() => _movesLimit += 20),
                              onlyLevelUp: _onlyLevelUp,
                              onToggleOnlyLevelUp: () => setState(() {
                                _onlyLevelUp = !_onlyLevelUp;
                                _movesCurrentPage = 0; // Reset to first page
                              }),
                              movesList: movesList,
                              pokemonName: pokemonName,
                              pokemonId: pokemon['id'] as int,
                              computeMatchups: (t) => _computeMatchups(t),
                              // Height in meters, weight in kg (converted from dm and hg)
                              heightMeters: heightMeters,
                              weightKg: weightKg,
                              types: types,
                              // Page-based pagination
                              movesCurrentPage: _movesCurrentPage,
                              movesPerPage: _movesPerPage,
                              onMovesPageChange: (page) => setState(() => _movesCurrentPage = page),
                              onMovesPerPageChange: (perPage) => setState(() {
                                _movesPerPage = perPage;
                                _movesCurrentPage = 0; // Reset to first page
                              }),
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

// Height of the radar chart container
const double _kRadarChartHeight = 280.0;

// Helper function to get icon for a Pokemon type
IconData _getTypeIcon(String type) {
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
  required List<String> types,
  String? description,
  // Page-based pagination for moves
  required int movesCurrentPage,
  required int movesPerPage,
  required ValueChanged<int> onMovesPageChange,
  required ValueChanged<int> onMovesPerPageChange,
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
                  height: _kRadarChartHeight,
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

            // Type Matchups section - Redesigned
            Builder(
              builder: (context) {
                // Calculate matchups
                final matchups = computeMatchups(types);
                
                // Group types by multiplier
                final List<String> x4Types = [];
                final List<String> x2Types = [];
                final List<String> x05Types = [];
                final List<String> x025Types = [];
                final List<String> x0Types = [];
                
                for (final entry in matchups.entries) {
                  final multiplier = entry.value;
                  if (multiplier == 4.0) {
                    x4Types.add(entry.key);
                  } else if (multiplier == 2.0) {
                    x2Types.add(entry.key);
                  } else if (multiplier == 0.5) {
                    x05Types.add(entry.key);
                  } else if (multiplier == 0.25) {
                    x025Types.add(entry.key);
                  } else if (multiplier == 0.0) {
                    x0Types.add(entry.key);
                  }
                }
                
                // Build enhanced type chip widget with icon and shadow
                Widget buildTypeChip(String typeName) {
                  final color = _kTypeColor[typeName] ?? Colors.grey;
                  return Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(typeName),
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          typeName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Build matchup category card with icon
                Widget buildMatchupCard({
                  required String title,
                  required IconData icon,
                  required Color iconColor,
                  required List<MapEntry<String, List<String>>> categories,
                }) {
                  // Filter out empty categories
                  final nonEmptyCategories = categories.where((c) => c.value.isNotEmpty).toList();
                  if (nonEmptyCategories.isEmpty) return const SizedBox.shrink();
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card header with icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                size: 18,
                                color: iconColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Categories
                        ...nonEmptyCategories.map((category) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                children: category.value.map((t) => buildTypeChip(t)).toList(),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  );
                }
                
                // Check if there's anything to show
                final hasWeaknesses = x4Types.isNotEmpty || x2Types.isNotEmpty;
                final hasResistances = x05Types.isNotEmpty || x025Types.isNotEmpty || x0Types.isNotEmpty;
                
                if (!hasWeaknesses && !hasResistances) return const SizedBox.shrink();
                
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    // Title with icon - matching other section titles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 22,
                          color: baseColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Type Matchups',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Weaknesses card
                          if (hasWeaknesses)
                            buildMatchupCard(
                              title: 'Weaknesses',
                              icon: Icons.arrow_upward_rounded,
                              iconColor: Colors.red.shade400,
                              categories: [
                                MapEntry('×4 Super Effective', x4Types),
                                MapEntry('×2 Effective', x2Types),
                              ],
                            ),
                          // Resistances card
                          if (hasResistances)
                            buildMatchupCard(
                              title: 'Resistances',
                              icon: Icons.shield_rounded,
                              iconColor: Colors.green.shade400,
                              categories: [
                                MapEntry('×0.5 Resistant', x05Types),
                                MapEntry('×0.25 Very Resistant', x025Types),
                                MapEntry('×0 Immune', x0Types),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
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
    // MOVES - Redesigned with modern UI and page-based pagination
    // Apply filters by method
      List<Map<String, dynamic>> filtered = List.from(movesList);
      if (movesMethodFilter.isNotEmpty) {
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
      
      // Page-based pagination
      final int totalMoves = filtered.length;
      final int totalPages = (totalMoves / movesPerPage).ceil();
      final int safeCurrentPage = totalPages > 0 ? movesCurrentPage.clamp(0, totalPages - 1) : 0;
      final int startIndex = safeCurrentPage * movesPerPage;
      final int endIndex = (startIndex + movesPerPage).clamp(0, totalMoves);
      final visibleMoves = totalMoves > 0 ? filtered.sublist(startIndex, endIndex) : <Map<String, dynamic>>[];
      
      // Helper to get damage class icon
      IconData getDamageClassIcon(String damageClass) {
        switch (damageClass.toLowerCase()) {
          case 'physical':
            return Icons.fitness_center;
          case 'special':
            return Icons.auto_awesome;
          case 'status':
            return Icons.swap_horiz;
          default:
            return Icons.help_outline;
        }
      }
      
      // Helper to get damage class color
      Color getDamageClassColor(String damageClass) {
        switch (damageClass.toLowerCase()) {
          case 'physical':
            return Colors.orange.shade600;
          case 'special':
            return Colors.blue.shade600;
          case 'status':
            return Colors.grey.shade600;
          default:
            return Colors.grey.shade400;
        }
      }
      
      // Build move type chip with color
      Widget buildMoveTypeChip(String typeName) {
        final color = _kTypeColor[typeName.toLowerCase()] ?? Colors.grey;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTypeIcon(typeName.toLowerCase()),
                size: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Text(
                typeName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }
      
      // Build move item card
      Widget buildMoveItem(Map<String, dynamic> mv) {
        final moveName = _capitalizeLocal(mv['name'] as String);
        final moveType = (mv['type'] as String?) ?? '';
        final damageClass = (mv['damage_class'] as String?) ?? '';
        final level = mv['level'] as int?;
        final method = (mv['method'] as String?) ?? '';
        final isLevelUp = method == 'level-up';
        final isMachine = method == 'machine';
        
        // TM/HM info
        final tmName = mv['tm_name'] as String?;
        final tmNumber = mv['tm_number'] as int?;
        final tmSpriteUrl = mv['tm_sprite_url'] as String?;
        
        // Build TM/HM label (e.g., "TM01", "HM03")
        String? tmLabel;
        if (isMachine && tmNumber != null) {
          // Determine if it's an HM based on the item name
          final isHm = tmName != null && tmName.toLowerCase().startsWith('hm');
          final prefix = isHm ? 'HM' : 'TM';
          tmLabel = '$prefix${tmNumber.toString().padLeft(2, '0')}';
        } else if (isMachine && tmName != null) {
          // Use the name directly if no number
          tmLabel = tmName.toUpperCase().replaceAll('-', '');
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Level circle (for level-up moves)
              if (isLevelUp && level != null)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: baseColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      level.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: baseColor,
                      ),
                    ),
                  ),
                )
              // TM/HM image and label (for machine moves)
              else if (isMachine)
                Container(
                  width: 48,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TM/HM disc image
                      if (tmSpriteUrl != null)
                        Image.network(
                          tmSpriteUrl,
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback icon colored by move type
                            final typeColor = _kTypeColor[moveType.toLowerCase()] ?? Colors.grey;
                            return Icon(
                              Icons.album,
                              size: 32,
                              color: typeColor,
                            );
                          },
                        )
                      else
                        Icon(
                          Icons.album,
                          size: 32,
                          color: _kTypeColor[moveType.toLowerCase()] ?? Colors.grey,
                        ),
                      // TM/HM label
                      if (tmLabel != null)
                        Text(
                          tmLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 48),
              
              // Move name
              Expanded(
                flex: 3,
                child: Text(
                  moveName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Type chip
              if (moveType.isNotEmpty)
                buildMoveTypeChip(moveType)
              else
                const SizedBox(width: 60),
              
              const SizedBox(width: 8),
              
              // Damage class icon with tooltip
              if (damageClass.isNotEmpty)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: getDamageClassColor(damageClass).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    getDamageClassIcon(damageClass),
                    size: 16,
                    color: getDamageClassColor(damageClass),
                  ),
                )
              else
                const SizedBox(width: 28),
            ],
          ),
        );
      }

      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.blur_circular,
                  size: 22,
                  color: baseColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Moves',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Filters section - Redesigned with Wrap for responsiveness
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Method filter chips
                  Text(
                    'Learn Method',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMethodFilterChip(
                        label: 'Level-up',
                        value: 'level-up',
                        selected: movesMethodFilter == 'level-up',
                        baseColor: baseColor,
                        onSelected: () => onChangeMovesMethod('level-up'),
                      ),
                      _buildMethodFilterChip(
                        label: 'TM/HM',
                        value: 'machine',
                        selected: movesMethodFilter == 'machine',
                        baseColor: baseColor,
                        onSelected: () => onChangeMovesMethod('machine'),
                      ),
                      _buildMethodFilterChip(
                        label: 'Tutor',
                        value: 'tutor',
                        selected: movesMethodFilter == 'tutor',
                        baseColor: baseColor,
                        onSelected: () => onChangeMovesMethod('tutor'),
                      ),
                      _buildMethodFilterChip(
                        label: 'Egg',
                        value: 'egg',
                        selected: movesMethodFilter == 'egg',
                        baseColor: baseColor,
                        onSelected: () => onChangeMovesMethod('egg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Sort and items per page row
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Sort toggle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sort: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onChangeMovesSort(movesSort == 'level' ? 'name' : 'level'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: baseColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: baseColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    movesSort == 'level' ? Icons.trending_up : Icons.sort_by_alpha,
                                    size: 14,
                                    color: baseColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    movesSort == 'level' ? 'Level' : 'Name',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: baseColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Items per page selector
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Per page: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: movesPerPage,
                                isDense: true,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 5, child: Text('5')),
                                  DropdownMenuItem(value: 10, child: Text('10')),
                                  DropdownMenuItem(value: 15, child: Text('15')),
                                  DropdownMenuItem(value: 20, child: Text('20')),
                                ],
                                onChanged: (v) => onMovesPerPageChange(v ?? 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Moves count indicator
            if (totalMoves > 0)
              Center(
                child: Text(
                  '$totalMoves moves found',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Moves list
            if (visibleMoves.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No moves found with current filters',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (final mv in visibleMoves)
                    buildMoveItem(mv),
                ],
              ),
            
            // Page navigation controls
            if (totalPages > 1)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous button
                    IconButton(
                      onPressed: safeCurrentPage > 0
                          ? () => onMovesPageChange(safeCurrentPage - 1)
                          : null,
                      icon: Icon(
                        Icons.chevron_left,
                        color: safeCurrentPage > 0 ? baseColor : Colors.grey.shade300,
                      ),
                      splashRadius: 20,
                    ),
                    
                    // Page indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Page ${safeCurrentPage + 1} of $totalPages',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    
                    // Next button
                    IconButton(
                      onPressed: safeCurrentPage < totalPages - 1
                          ? () => onMovesPageChange(safeCurrentPage + 1)
                          : null,
                      icon: Icon(
                        Icons.chevron_right,
                        color: safeCurrentPage < totalPages - 1 ? baseColor : Colors.grey.shade300,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
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
  static const double _labelOffsetAdjustment = 4.0;
  static const double _topAngleThreshold = math.pi / 4;
  static const double _bottomAngleThreshold = 3 * math.pi / 4;

  static const double _radiusScale = 0.72;
  static const double _labelRadiusOffset = 30.0;
  static const double _vertexCircleRadius = 4.0;
  static const double _centerCircleRadius = 5.0;

  final List<double> data;
  final List<String> labels;
  final double maxValue;
  final Color baseColor;
  final Color secondaryColor;

  const _RadarPainter({
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
    final radius = math.min(cx, cy) * _radiusScale;
    final center = Offset(cx, cy);
    final n = math.max(3, data.length);

    // Fondo gris
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Puntos del polígono
    final List<Offset> dataPoints = [];
    for (int i = 0; i < n; i++) {
      final double normalized =
      (i < data.length) ? (data[i].clamp(0.0, maxValue) / maxValue) : 0.0;

      final r = radius * normalized;
      final angle = (math.pi * 2 / n) * i - math.pi / 2;

      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);

      dataPoints.add(Offset(x, y));
    }

    // Polígono curvo hacia dentro
    final Path pathData = Path()..moveTo(dataPoints[0].dx, dataPoints[0].dy);
    const double inwardFactor = 0.12;

    for (int i = 0; i < dataPoints.length; i++) {
      final current = dataPoints[i];
      final next = dataPoints[(i + 1) % dataPoints.length];

      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );

      final control = Offset(
        mid.dx + (center.dx - mid.dx) * inwardFactor,
        mid.dy + (center.dy - mid.dy) * inwardFactor,
      );

      pathData.quadraticBezierTo(control.dx, control.dy, next.dx, next.dy);
    }

    pathData.close();

    // Gradiente más fuerte
    final vividBase = HSLColor.fromColor(baseColor)
        .withSaturation((HSLColor.fromColor(baseColor).saturation * 1.4).clamp(0.0, 1.0))
        .withLightness((HSLColor.fromColor(baseColor).lightness * 1.15).clamp(0.0, 1.0))
        .toColor();

    final vividSecondary = HSLColor.fromColor(secondaryColor)
        .withSaturation((HSLColor.fromColor(secondaryColor).saturation * 1.4).clamp(0.0, 1.0))
        .withLightness((HSLColor.fromColor(secondaryColor).lightness * 1.15).clamp(0.0, 1.0))
        .toColor();

    final vividMiddle = Color.fromARGB(
      255,
      ((vividBase.red   * 0.5) + (vividSecondary.red   * 0.5)).toInt(),
      ((vividBase.green * 0.5) + (vividSecondary.green * 0.5)).toInt(),
      ((vividBase.blue  * 0.5) + (vividSecondary.blue  * 0.5)).toInt(),
    );

    final paintGradientFill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx - radius * 0.35, cy - radius * 0.35),
        Offset(cx + radius * 0.35, cy + radius * 0.35),
        [
          vividBase.withOpacity(0.98),
          vividMiddle.withOpacity(0.96),
          vividSecondary.withOpacity(0.98),
        ],
        [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.fill;



    // 1. Área del polígono

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    canvas.drawPath(
      pathData,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      pathData,
      paintGradientFill
        ..blendMode = BlendMode.srcIn,
    );


    canvas.restore();


    // 2. Borde del polígono
    final Paint paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawPath(pathData, paintStroke);

    // 3. Líneas del radar
    final Paint gridPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Paint radialPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const int rings = 6;
    for (int r = 1; r <= rings; r++) {
      canvas.drawCircle(center, radius * (r / rings), gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), radialPaint);
    }

    // 4. Puntos
    final Paint paintVertex = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    for (final p in dataPoints) {
      canvas.drawCircle(p, _vertexCircleRadius, paintVertex);
    }

    // Centro hueco
    final Paint centerStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, _centerCircleRadius * 1.5, centerStroke);

    // --- LABELS + VALORES ---
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      final double labelRadius = radius + _labelRadiusOffset;

      final lx = cx + labelRadius * math.cos(angle);
      final ly = cy + labelRadius * math.sin(angle);

      final String label = labels[i];
      final double value = (i < data.length) ? data[i] : 0;

      final String fullText = "$label  ${value.toInt()}";

      textPainter.text = TextSpan(
        text: fullText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      );

      textPainter.layout();

      double dx = lx - textPainter.width / 2;
      double dy = ly - textPainter.height / 2;

      if (angle > -_topAngleThreshold && angle < _topAngleThreshold) {
        dy -= _labelOffsetAdjustment;
      } else if (angle > _bottomAngleThreshold ||
          angle < -_bottomAngleThreshold) {
        dy += _labelOffsetAdjustment;
      }

      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.data != data ||
          oldDelegate.labels != labels ||
          oldDelegate.maxValue != maxValue ||
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
    return Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(32), boxShadow: [
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

// Helper widget for method filter chips in Moves section
Widget _buildMethodFilterChip({
  required String label,
  required String value,
  required bool selected,
  required Color baseColor,
  required VoidCallback onSelected,
}) {
  return GestureDetector(
    onTap: onSelected,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? baseColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? baseColor : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.grey.shade700,
        ),
      ),
    ),
  );
}