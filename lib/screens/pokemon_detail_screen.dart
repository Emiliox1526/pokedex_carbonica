import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../queries/get_pokemon_detail.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({
    super.key,
    required this.pokemonId,
    required this.heroTag,
    this.initialPokemon,
  });

  final int pokemonId;
  final String heroTag;
  final Map<String, dynamic>? initialPokemon;
  Color _getClassColor(String damageClass) {
    switch (damageClass.toLowerCase()) {
      case 'physical':
        return const Color(0xFFDD5E56);
      case 'special':
        return const Color(0xFF4B7BF5);
      case 'status':
        return const Color(0xFF9A8CFC);
      default:
        return Colors.grey;
    }
  }
  static const Map<String, Color> _typeColor = {
    'fire': Color(0xFFF57D31),
    'water': Color(0xFF6493EB),
    'grass': Color(0xFF74CB48),
    'electric': Color(0xFFF9CF30),
    'ice': Color(0xFF9AD6DF),
    'fighting': Color(0xFFC12239),
    'poison': Color(0xFFA43E9E),
    'ground': Color(0xFFDEC16B),
    'flying': Color(0xFFA891EC),
    'psychic': Color(0xFFFB5584),
    'bug': Color(0xFFA7B723),
    'rock': Color(0xFFB69E31),
    'ghost': Color(0xFF70559B),
    'dragon': Color(0xFF7037FF),
    'dark': Color(0xFF75574C),
    'steel': Color(0xFFB7B9D0),
    'fairy': Color(0xFFE69EAC),
    'normal': Color(0xFFAAA67F),
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
        return Icons.blur_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetailQuery),
          variables: {'id': pokemonId},
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          optimisticResult: initialPokemon == null
              ? null
              : {
            'pokemon_v2_pokemon_by_pk': initialPokemon,
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          final pokemon = (result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?) ??
              initialPokemon;

          if (pokemon == null) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (result.hasException) {
              return Center(child: Text('Error al cargar el Pokémon:\n${result.exception}'));
            }
            return const Center(child: Text('No se encontró información del Pokémon.'));
          }

          final name = (pokemon['name'] as String? ?? 'Pokémon').toUpperCase();
          final idLabel = '#${pokemonId.toString().padLeft(3, '0')}';

          final types = ((pokemon['pokemon_v2_pokemontypes'] as List?) ?? [])
              .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
              .where((t) => t.isNotEmpty)
              .cast<String>()
              .toList();
          final primaryType = types.isNotEmpty ? types.first : 'normal';
          final baseColor = _typeColor[primaryType] ?? _typeColor['normal']!;
          final secondaryColor = Color.lerp(baseColor, Colors.white, .35)!;

          final imageUrl = _extractImageUrl(pokemon);
          final abilities = ((pokemon['pokemon_v2_pokemonabilities'] as List?) ?? [])
              .map((a) => a['pokemon_v2_ability']?['name'] as String? ?? '')
              .where((s) => s.isNotEmpty)
              .cast<String>()
              .toList();
          final stats = ((pokemon['pokemon_v2_pokemonstats'] as List?) ?? [])
              .map((s) => {
            'name': s['pokemon_v2_stat']?['name'] as String? ?? '',
            'value': s['base_stat'] as int? ?? 0,
          })
              .where((s) => (s['name'] as String).isNotEmpty)
              .toList();
          final moves = ((pokemon['pokemon_v2_pokemonmoves'] as List?) ?? [])
              .map((m) => {
            'name': m['pokemon_v2_move']?['name'] as String? ?? '',
            'type': m['pokemon_v2_move']?['pokemon_v2_type']?['name'] as String? ?? '',
            'damage_class': m['pokemon_v2_move']?['pokemon_v2_movedamageclass']?['name'] as String? ?? '',
            'level': m['level'] as int?,
          })
              .where((m) => (m['name'] as String).isNotEmpty)
              .toList();
          final uniqueMoves = {
            for (var move in moves) move['name'] as String: move,
          }.values.toList();

          final displayedMoves = uniqueMoves.take(12).toList();
          final height = (pokemon['height'] as int?) ?? 0;
          final weight = (pokemon['weight'] as int?) ?? 0;
          final baseExperience = (pokemon['base_experience'] as int?) ?? 0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [secondaryColor, baseColor],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _CircleButton(
                              icon: Icons.arrow_back,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
                            Text(
                              idLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: .8,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final type in types)
                              _TypeTag(
                                label: type,
                                color: _typeColor[type] ?? _typeColor['normal']!,
                                icon: _iconForType(type),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Hero(
                            tag: heroTag,
                            child: imageUrl != null
                                ? Image.network(
                              imageUrl,
                              height: 220,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.hide_image,
                                size: 88,
                                color: Colors.white70,
                              ),
                            )
                                : const Icon(
                              Icons.image_not_supported,
                              size: 88,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _DetailCard(
                          background: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader('Información general'),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _InfoPill(
                                    icon: Icons.height,
                                    label: 'Altura',
                                    value: '${(height / 10).toStringAsFixed(1)} m',
                                  ),
                                  _InfoPill(
                                    icon: Icons.monitor_weight,
                                    label: 'Peso',
                                    value: '${(weight / 10).toStringAsFixed(1)} kg',
                                  ),
                                  _InfoPill(
                                    icon: Icons.bolt,
                                    label: 'Exp. base',
                                    value: '$baseExperience',
                                  ),
                                ],
                              ),
                              if (abilities.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _SectionHeader('Habilidades'),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final ability in abilities)
                                      Chip(
                                        backgroundColor: Colors.grey.shade100,
                                        label: Text(
                                          ability.replaceAll('-', ' '),
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              if (stats.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _SectionHeader('Estadísticas base'),
                                const SizedBox(height: 12),
                                for (final stat in stats) ...[
                                  _StatRow(
                                    label: (stat['name'] as String).replaceAll('-', ' ').toUpperCase(),
                                    value: stat['value'] as int,
                                    color: baseColor,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],

                              if (uniqueMoves.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                _SectionHeader('Lista de movimientos'),
                                const SizedBox(height: 16),

                                // Encabezado de tabla
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    children: const [
                                      Expanded(flex: 3, child: Text('Movimiento', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text('Clase', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                ),

                                // Cuerpo
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
                                      for (final move in uniqueMoves.take(40))
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // Movimiento
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    ((move['name'] ?? '') as String).replaceAll('-', ' '),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 15,
                                                      height: 1.2,
                                                    ),
                                                  ),
                                                ),

                                                // Tipo
                                                Expanded(
                                                  flex: 2,
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: _TypeTag(
                                                      label: ((move['type'] ?? '') as String).toUpperCase(),
                                                      color: _typeColor[(move['type'] ?? '') as String] ?? Colors.grey,
                                                      icon: _iconForType(((move['type'] ?? '') as String)),
                                                    ),
                                                  ),
                                                ),

                                                // Clase (chip visual)
                                                Expanded(
                                                  flex: 2,
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _getClassColor((move['damage_class'] ?? '') as String),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        ((move['damage_class'] ?? '—') as String).toUpperCase(),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          letterSpacing: 0.3,
                                                        ),
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

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (result.isLoading)
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                  if (result.hasException)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: _ErrorBanner(message: result.exception.toString()),
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
    final spritesList = pokemon['pokemon_v2_pokemonsprites'] as List?;
    if (spritesList == null || spritesList.isEmpty) return null;
    try {
      final dynamic raw = spritesList.first['sprites'];
      Map<String, dynamic>? map;
      if (raw is String) {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map) {
        map = Map<String, dynamic>.from(raw as Map);
      }
      return (map?['other']?['official-artwork']?['front_default'] as String?) ??
          (map?['front_default'] as String?);
    } catch (_) {
      return null;
    }
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child, required this.background});

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
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
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color.withOpacity(.9)),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
              color: Color.lerp(color, Colors.black, .25),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: .4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value.toString(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (value.clamp(0, 255)) / 255,
            minHeight: 10,
            backgroundColor: color.withOpacity(.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _MoveTile extends StatelessWidget {
  const _MoveTile({required this.name, this.level});

  final String name;
  final int? level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (level != null && level! > 0)
            Text(
              'Nv. $level',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.black54, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.9),
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
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