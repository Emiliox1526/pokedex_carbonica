import 'dart:convert';

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

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                          Row(
                            children: [
                              for (final type in types) ...[
                                _TypeTag(
                                  label: type.toUpperCase(),
                                  color: _typeColor[type] ?? _typeColor['normal']!,
                                  icon: _iconForType(type),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Hero(
                              tag: widget.heroTag,
                              child: Container(
                                width: 220,
                                height: 220,
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
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white,
                                      size: 72,
                                    ),
                                  ),
                                ),
                              ),
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
    // EVOLUTION (placeholder por ahora, listo para conectar a la API)
      return _DetailCard(
        key: key,
        background: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Evolution',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(top: 64.0),
              child: Center(
                child: Text(
                  'Evolution chart coming soon',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
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
    final fg = selected ? Colors.white : Colors.black87;
    final bg = selected ? color : Colors.white;
    final shadow = selected
        ? [
      BoxShadow(
        color: color.withOpacity(.45),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ]
        : [
      BoxShadow(
        color: Colors.black.withOpacity(.06),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.black.withOpacity(.9) : Colors.black87,
                border: Border.all(color: color, width: 3),
              ),
              child: Icon(icon, size: 22, color: fg),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String label;
  final int value;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0, 255) / 255;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              value.toString().padLeft(3, '0'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    color: Colors.black.withOpacity(.08),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: normalizedValue,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            primaryColor.withOpacity(.95),
                            secondaryColor.withOpacity(.95),
                          ],
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
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.black87.withOpacity(.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
