import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../queries/get_pokemon_detail.dart';

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
          if (result.isLoading && result.data == null && widget.initialPokemon == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException && widget.initialPokemon == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _ErrorBanner(
                  message: 'Error loading Pokémon details:\n${result.exception}',
                ),
              ),
            );
          }

          final pokemon = result.data?['pokemon_v2_pokemon_by_pk']
          as Map<String, dynamic>? ?? widget.initialPokemon;

          if (pokemon == null) {
            return const Center(child: Text('Pokémon not found'));
          }

          final pokemonName = (pokemon['name'] as String? ?? 'Unknown')
              .replaceAll('-', ' ')
              .split(' ')
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' ');

          final idLabel = '#${pokemon['id'].toString().padLeft(3, '0')}';

          final types = ((pokemon['pokemon_v2_pokemontypes'] as List?) ?? [])
              .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
              .where((t) => t.isNotEmpty)
              .cast<String>()
              .toList();

          final primaryType = types.isNotEmpty ? types.first : 'normal';
          final secondaryTypeName = types.length > 1 ? types[1] : primaryType;

          final baseColor = _typeColor[primaryType] ?? _typeColor['normal']!;
          final secondaryColor =
              _typeColor[secondaryTypeName] ?? Color.lerp(baseColor, Colors.white, .35)!;

          final imageUrl = _extractImageUrl(pokemon);

          final abilities =
          ((pokemon['pokemon_v2_pokemonabilities'] as List?) ?? []).map((a) {
            final ability = a['pokemon_v2_ability'] as Map<String, dynamic>?;
            return ability?['name'] as String? ?? '';
          }).where((name) => name.isNotEmpty).toList();

          final stats = ((pokemon['pokemon_v2_pokemonstats'] as List?) ?? [])
              .map((s) => {
            'name': formatStatName(s['pokemon_v2_stat']?['name'] as String? ?? ''),
            'value': s['base_stat'] as int? ?? 0,
          })
              .where((s) => (s['name'] as String).isNotEmpty)
              .toList();

          final moves = ((pokemon['pokemon_v2_pokemonmoves'] as List?) ?? [])
              .map((m) => {
            'name': m['pokemon_v2_move']?['name'] as String? ?? '',
            'type':
            m['pokemon_v2_move']?['pokemon_v2_type']?['name'] as String? ?? '',
            'damage_class': m['pokemon_v2_move']
            ?['pokemon_v2_movedamageclass']?['name'] as String? ??
                '',
            'level': m['level'] as int?,
          })
              .where((m) => (m['name'] as String).isNotEmpty)
              .toList();

          final uniqueMoves = {
            for (var move in moves) move['name'] as String: move,
          }.values.toList();

          final height = (pokemon['height'] as int?) ?? 0;
          final weight = (pokemon['weight'] as int?) ?? 0;
          final baseExperience = (pokemon['base_experience'] as int?) ?? 0;

          // --- EXTRA: obtener la cadena evolutiva desde la species -> evolution chain (si existe)
          final speciesObj = pokemon['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
          final evolutionSpeciesRaw = (speciesObj?['pokemon_v2_evolutionchain']?['pokemon_v2_pokemonspecies'] as List?) ?? [];
          // Cada entry suele venir como { id: int, name: String }
          final evolutionSpecies = evolutionSpeciesRaw.cast<Map<String, dynamic>>();

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
                          Row(
                            children: [
                              _CircleButton(
                                icon: Icons.arrow_back,
                                onTap: () => Navigator.of(context).maybePop(),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                pokemonName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
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

                          const SizedBox(height: 18),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Usamos LayoutBuilder para ajustar el tamaño de la imagen
                                // respecto al ancho disponible y escalar los chips en consecuencia.
                                LayoutBuilder(builder: (context, constraints) {
                                  // ancho disponible dentro del Column / SingleChildScrollView
                                  final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
                                      ? constraints.maxWidth
                                      : MediaQuery.of(context).size.width - 32; // fallback

                                  // Calculamos diámetro de la imagen: depende del ancho disponible.
                                  // Lógica: intenta usar 220 en pantallas amplias, pero si el espacio es pequeño,
                                  // reduce el tamaño proporcionalmente. Clamp entre 100 y 320.
                                  final imageDiameter = math.max(
                                    100.0,
                                    math.min(320.0, availableWidth * 0.45),
                                  );

                                  // escala relativa para chips (1.0 = tamaño base cuando imageDiameter == 220)
                                  final scale = imageDiameter / 220.0;

                                  // desplazamiento horizontal de los chips para que queden "pegados" a la imagen,
                                  // pero sin salirse tanto que se corten.
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
                                            child: imageUrl != null
                                                ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                            )
                                                : Container(
                                              color: Colors.white.withOpacity(0.18),
                                              child: Icon(
                                                Icons.image_not_supported_outlined,
                                                color: Colors.white,
                                                size: math.max(32.0, 64.0 * scale),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // CHIP IZQUIERDO
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
                          const SizedBox(height: 24),
                          _TabsCard(
                            selectedIndex: _selectedTab,
                            primaryColor: baseColor,
                            secondaryColor: secondaryColor,
                            onChanged: _onTabSelected,
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: _buildTabBody(
                              key: ValueKey(_selectedTab),
                              tabIndex: _selectedTab,
                              baseColor: baseColor,
                              secondaryColor: secondaryColor,
                              height: height,
                              weight: weight,
                              baseExperience: baseExperience,
                              abilities: abilities,
                              stats: stats,
                              uniqueMoves: uniqueMoves,
                              evolutionSpecies: evolutionSpecies,
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

  String? _extractImageUrl(Map<String, dynamic> pokemon) {
    // 1) Lista de sprites de la relación
    final spriteList = pokemon['pokemon_v2_pokemonsprites'] as List?;
    if (spriteList == null || spriteList.isEmpty) return null;

    final raw = spriteList.first['sprites'];
    if (raw == null) return null;

    Map<String, dynamic> decoded;

    // 2) Puede venir como String (JSON) o como Map ya decodificado
    if (raw is String) {
      try {
        decoded = json.decode(raw) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    } else if (raw is Map<String, dynamic>) {
      decoded = raw;
    } else {
      return null;
    }

    // 3) Buscar la mejor URL disponible
    final fromDb =
        decoded['other']?['official-artwork']?['front_default'] ??
            decoded['other']?['home']?['front_default'] ??
            decoded['front_default'] ??
            decoded['front_shiny'] ??
            decoded['front_female'] ??
            decoded['back_default'] ??
            decoded['back_shiny'];

    if (fromDb is String && fromDb.isNotEmpty) {
      return fromDb;
    }

    return null;
  }

  // Helper para construir URL oficial de artwork por id (fallback si no hay sprite en DB)
  String _artworkUrlForId(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  // Helper para capitalizar nombres
  String _capitalize(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.replaceAll('-', ' ').split(' ');
    return parts.map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w).join(' ');
  }

}

Widget _buildTabBody({
  Key? key,
  required int tabIndex,
  required Color baseColor,
  required Color secondaryColor,
  required int height,
  required int weight,
  required int baseExperience,
  required List<String> abilities,
  required List<Map<String, dynamic>> stats,
  required List<Map<String, dynamic>> uniqueMoves,
  required List<Map<String, dynamic>> evolutionSpecies,
}) {
  switch (tabIndex) {
    case 0:
    // ABOUT
      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Título "About" ---
            Center(
              child: Text(
                'About',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Bloques Weight / Height / Moves ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AboutBlock(
                    icon: Icons.monitor_weight_outlined,
                    value: '${(weight / 10).toStringAsFixed(1)} kg',
                    label: 'Weight',
                  ),
                  Container(width: 1, height: 40, color: Colors.black12),
                  _AboutBlock(
                    icon: Icons.height,
                    value: '${(height / 10).toStringAsFixed(1)} m',
                    label: 'Height',
                  ),
                  Container(width: 1, height: 40, color: Colors.black12),
                  _AboutBlock(
                    icon: Icons.list_alt_outlined,
                    value: abilities.isNotEmpty ? abilities.join('\n') : '—',
                    label: 'Moves',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Descripción (placeholder, puedes cambiarla por flavor text) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              child: Text(
                'There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: Colors.black.withOpacity(.75),
                ),
              ),
            ),

            if (stats.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: const Center(
                  child: Text(
                    'Base Stats',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              for (final stat in stats)
                _StatRow(
                  label: (stat['name'] as String).replaceAll('-', ' ').toUpperCase(),
                  value: stat['value'] as int,
                  primaryColor: baseColor,
                  secondaryColor: secondaryColor,
                ),
            ],
          ],
        ),
      );

    case 1:
    // EVOLUTION: mostramos una "evolution chart" vertical usando los species provistos por la query.
      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Evolution Chart',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (evolutionSpecies.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 64.0),
                child: Center(child: Text('No evolution data available')),
              )
            else
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
                        // Flecha y badge de nivel (si no hay nivel, mostramos un badge neutral)
                        Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Lv. -',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w800),
                                ),
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
              ),
            const SizedBox(height: 8),
          ],
        ),
      );

    case 2:
    // MOVES
      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Moves',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (uniqueMoves.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 64.0),
                child: Center(
                  child: Text(
                    'No moves found for this Pokémon.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),

                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Move',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Class',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Lvl',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final move in uniqueMoves.take(60))
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 0.75,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      (move['name'] as String)
                                          .replaceAll('-', ' ')
                                          .split(' ')
                                          .map((w) => w[0].toUpperCase() + w.substring(1))
                                          .join(' '),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade800,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.bolt,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (move['type'] as String).isNotEmpty
                                              ? (move['type'] as String)
                                              .replaceAll('-', ' ')
                                              .toUpperCase()
                                              : '—',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      (move['damage_class'] as String).isNotEmpty
                                          ? (move['damage_class'] as String)
                                          .replaceAll('-', ' ')
                                          .toUpperCase()
                                          : '—',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        (move['level'] as int?)?.toString() ?? '—',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      );

    case 3:
    default:
      return _DetailCard(
        key: key,
        background: Colors.white,
        child: const Center(
          child: Text(
            'Options coming soon',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
  }
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
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))
            ],
          ),
          child: ClipOval(
            child: Image.network(
              artworkUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    super.key,
    required this.background,
    required this.child,
  });

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: child,
      ),
    );
  }
}

class _TabsCard extends StatelessWidget {
  const _TabsCard({
    required this.selectedIndex,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onChanged,
  });

  final int selectedIndex;
  final Color primaryColor;
  final Color secondaryColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final aboutColor = primaryColor;
    final evolutionColor = primaryColor;
    final movesColor = secondaryColor;
    final optionsColor = secondaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'About',
              icon: Icons.info_outline,
              color: aboutColor,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Evolution',
              icon: Icons.auto_graph,
              color: evolutionColor,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Moves',
              icon: Icons.blur_circular,
              color: movesColor,
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Options',
              icon: Icons.menu,
              color: optionsColor,
              selected: selectedIndex == 3,
              onTap: () => onChanged(3),
            ),
          ),
        ],
      ),
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
        _TypeChip(
          icon: icon,
          color: color,
          scale: scale,
        ),
        SizedBox(height: 8 * scale),
        _TypeLabelChip(
          label: label,
          scale: scale,
        ),
      ],
    );
  }
}
class _TypeLabelChip extends StatelessWidget {
  final String label;
  final double scale;

  const _TypeLabelChip({
    required this.label,
    this.scale = 1.0,
  });

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
        style: TextStyle(
          color: Colors.white,
          fontSize: math.max(10.0, 14.0 * scale),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double scale;

  const _TypeChip({
    required this.icon,
    required this.color,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final outerSize = 62.0 * scale;
    final innerSize = 44.0 * scale;
    final iconSize = 22.0 * scale;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
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
    // Color del icono
    final iconColor = selected ? Colors.white : color;
    final bgColor = selected ? color : Colors.white;
    final textColor = selected ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            // Evitamos overflow: el texto está dentro de Flexible y corta con ellipsis si falta espacio.
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Componentes auxiliares (sin cambios funcionales, solo tal vez usados más arriba) ---

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _AboutBlock({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.black.withOpacity(.6)),
          )
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color primaryColor;
  final Color secondaryColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / 255).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              value.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}