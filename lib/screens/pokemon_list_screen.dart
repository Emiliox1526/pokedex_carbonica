import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../queries/get_pokemon_list.dart';
import 'dart:ui';

import 'pokemon_detail_screen.dart';

// Helper functions (assuming they exist elsewhere, like in your original code)
Color hex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

extension ColorUtil on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}


class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final Color _bg1 = hex('#9e1932');
  final Color _bg2 = hex('#520317');
  String _searchText = '';
// Tipos seleccionados para el filtro
  final Set<String> selectedTypes = {};

// Función que se usa desde el Drawer para alternar selección de tipo
  void toggleType(String type, bool selected) {
    setState(() {
      if (selected) {
        selectedTypes.add(type.toLowerCase());
      } else {
        selectedTypes.remove(type.toLowerCase());
      }
    });
  }
  int? _selectedGeneration;



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  int _startIdFor(int gen) {
    const startIds = [1, 152, 252, 387, 494, 650, 722, 810, 906];
    return startIds[gen - 1];
  }

  int _endIdFor(int gen) {
    const endIds = [151, 251, 386, 493, 649, 721, 809, 905, 1025];
    return endIds[gen - 1];
  }

  // 🎨 Colores por tipo (remains the same)
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

  // iconForType method (remains the same)
  IconData iconForType(String type) {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hex('#F5F7F9'),
      drawer: GenerationDrawer(
        onSelectGeneration: (int gen) {
          setState(() {
            _selectedGeneration = (gen == 0) ? null : gen;
          });
          Navigator.of(context).maybePop();
        },
        typeColor: typeColor,
        selectedTypes: selectedTypes,
        onToggleType: toggleType,
        iconForType: iconForType,
      ),

      body: Stack(
        children: [
          // Static gradient background
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // Adjusted padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  if (_selectedGeneration != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Mostrando: Generación $_selectedGeneration',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  _SearchBar(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value.toLowerCase().trim();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Query(
                      options: QueryOptions(
                        document: gql(getPokemonListQuery),
                      ),
                      builder: (result, {fetchMore, refetch}) {
                        if (result.isLoading) {
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        }
                        if (result.hasException) {
                          return Center(child: Text('Error: \n${result.exception}', style: const TextStyle(color: Colors.white)));
                        }

                        List data = result.data?['pokemon_v2_pokemon'] ?? [];

                        if (_searchText.isNotEmpty) {
                          data = data.where((p) {
                            final name = (p['name'] as String?)?.toLowerCase() ?? '';
                            final id = (p['id'] as int?)?.toString() ?? '';
                            return name.contains(_searchText) || id.contains(_searchText);
                          }).toList();
                        }
                        if (selectedTypes.isNotEmpty) {
                          data = data.where((p) {
                            final types = ((p['pokemon_v2_pokemontypes'] as List?) ?? [])
                                .map((t) => (t['pokemon_v2_type']?['name'] as String?)?.toLowerCase() ?? '')
                                .where((s) => s.isNotEmpty)
                                .toList();

                            // Si al menos un tipo del Pokémon está en selectedTypes, se queda
                            return types.any(selectedTypes.contains);
                          }).toList();
                        }
                        if (data.isEmpty) {
                          return const Center(
                            child: Text(
                              'No se encontraron Pokémon',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (_selectedGeneration != null) {
                          final start = _startIdFor(_selectedGeneration!);
                          final end = _endIdFor(_selectedGeneration!);
                          data = data.where((p) {
                            final id = p['id'] as int? ?? 0;
                            return id >= start && id <= end;
                          }).toList();
                        }
                        if (data.isEmpty) {
                          return const Center(child: Text('Sin resultados', style: TextStyle(color: Colors.white)));
                        }

                        // Replaced PageView.builder with ListView.builder
                        return ListView.builder(
                          itemCount: data.length,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24), // Padding at the bottom of the list
                          itemBuilder: (context, index) {
                            final p = data[index] as Map<String, dynamic>;
                            final String name = (p['name'] as String?)?.toUpperCase() ?? 'POKÉMON';
                            final int id = p['id'] as int? ?? 0;
                            final String idStr = '#${id.toString().padLeft(3, '0')}';
                            final String heroTag = 'pokemon-image-$id';
                            String? imageUrl;
                            final spritesList = p['pokemon_v2_pokemonsprites'] as List?;
                            if (spritesList != null && spritesList.isNotEmpty) {
                              try {
                                final dynamic raw = spritesList.first['sprites'];
                                Map<String, dynamic>? map;
                                if (raw is String) {
                                  map = jsonDecode(raw) as Map<String, dynamic>;
                                } else if (raw is Map) {
                                  map = Map<String, dynamic>.from(raw as Map);
                                }
                                imageUrl = (map?['other']?['official-artwork']?['front_default'] as String?) ??
                                    (map?['front_default'] as String?);
                              } catch (_) {
                                imageUrl = null;
                              }
                            }

                            final types = (p['pokemon_v2_pokemontypes'] as List?)
                                ?.map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
                                .where((e) => e.isNotEmpty)
                                .toList() ??
                                <String>['normal'];

                            final primary = types.isNotEmpty ? types.first : 'normal';
                            final baseColor = typeColor[primary] ?? typeColor['normal']!;

                            // Entry animation for each card
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, t, child) {
                                return Opacity(
                                  opacity: t,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - t) * 20),
                                    child: child,
                                  ),
                                );
                              },
                            child: GestureDetector(
                            onTap: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (_) => PokemonDetailScreen(
                            pokemonId: id,
                            heroTag: heroTag,
                            initialPokemon: p,
                            ),
                            ),
                            );
                            },
                              child: _PokemonCard(
                                id: idStr,
                                name: name,
                                heroTag: heroTag,
                                imageUrl: imageUrl,
                                types: types,
                                color: baseColor,
                                typeColor: typeColor,
                                iconForType: iconForType,
                              ),
                            ),
                            );
                          },
                        );
                      },
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

// Updated _PokemonCard to be simpler for a list view
class _PokemonCard extends StatelessWidget {
  const _PokemonCard({
    required this.id,
    required this.heroTag,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.color,
    required this.typeColor,
    required this.iconForType,
  });

  final String id;
  final String name;
  final String heroTag;
  final String? imageUrl;
  final List<String> types;
  final Color color;
  final Map<String, Color> typeColor;
  final IconData Function(String) iconForType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140, // Fixed height for cards in the list
      margin: const EdgeInsets.symmetric(vertical: 8), // Vertical spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.darken(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Card content arranged in a Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Left side: Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(id, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black45)),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: .4,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 28,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (_, i) {
                              final t = types[i];
                              return _TypeChip(
                                label: t,
                                color: typeColor[t] ?? typeColor['normal']!,
                                icon: iconForType(t),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 6),
                            itemCount: types.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right side: Image
                  Hero(
                    tag: heroTag,
                    child: imageUrl != null
                        ? Image.network(
                      imageUrl!,
                      filterQuality: FilterQuality.high,
                      key: ValueKey(imageUrl),
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    )
                        : const Icon(Icons.image_not_supported, size: 60, color: Colors.black26),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _TypeChip widget (can be extracted or kept here)
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      splashColor: Colors.white.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.darken(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class TypeFilterChips extends StatelessWidget {
  const TypeFilterChips({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.typeColor,
  });

  final Set<String> selected;
  final void Function(String type, bool selected) onToggle;
  final Map<String, Color> typeColor;

  static const List<String> kTypes = [
    'normal','fire','water','grass','electric','ice','fighting','poison',
    'ground','flying','psychic','bug','rock','ghost','dragon','dark','steel','fairy',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in kTypes)
                FilterChip(
                  label: Text(t[0].toUpperCase() + t.substring(1)),
                  selected: selected.contains(t),
                  onSelected: (sel) => onToggle(t, sel),
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: typeColor[t] ?? Colors.blue.shade300,
                  labelStyle: TextStyle(
                    color: selected.contains(t) ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GenerationDrawer extends StatelessWidget {
  const GenerationDrawer({
    required this.onSelectGeneration,
    required this.typeColor,
    required this.selectedTypes,
    required this.onToggleType,
    required this.iconForType,
  });
  final ValueChanged<int> onSelectGeneration;
  final Map<String, Color> typeColor;
  final Set<String> selectedTypes;
  final IconData Function(String type) iconForType;
  final void Function(String type, bool selected) onToggleType;

  static const _dexBurgundy = Color(0xFF7A0A16);
  static const _dexDeep = Color(0xFF4E0911);
  static const _dexDark = Color(0xFF240507);
  static const _dexWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final regionBanners = [
      {"title": "", "image": "lib/assets/AllGenerations.png"},
      {"title": "", "image": "lib/assets/kanto.png"},
      {"title": "", "image": "lib/assets/johto.png"},
      {"title": "", "image": "lib/assets/hoenn.png"},
      {"title": "", "image": "lib/assets/sinnoh.png"},
      {"title": "", "image": "lib/assets/unova.png"},
      {"title": "", "image": "lib/assets/kalos.png"},
      {"title": "", "image": "lib/assets/alola.png"},
      {"title": "", "image": "lib/assets/galar.png"},
      {"title": "", "image": "lib/assets/paldea.png"},
    ];

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_dexBurgundy, _dexDeep, _dexDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Encabezado con Pokébola
                Row(
                  children: const [
                    Icon(
                      Icons.catching_pokemon,
                      color: _dexWhite,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Pokédex Regional",
                      style: TextStyle(
                        color: _dexWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1.4, color: _dexWhite),
                const SizedBox(height: 14),

                // 🔄 Scroll unificado (Configuración + Generación)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Configuración
                        const Text(
                          "Configuración",
                          style: TextStyle(
                            color: _dexWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),



                        // FILTRO DE TIPOS
                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.7,
                          children: [
                            for (final t in [
                              'normal','fire','water','grass','electric','ice',
                              'fighting','poison','ground','flying','psychic',
                              'bug','rock','ghost','dragon','dark','steel','fairy',
                            ])
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: selectedTypes.contains(t) ? 1.0 : 0.0,
                                  end: selectedTypes.contains(t) ? 1.0 : 0.0,
                                ),
                                duration: const Duration(milliseconds: 250),
                                builder: (context, value, child) {
                                  final color = typeColor[t] ?? Colors.grey;
                                  final icon = iconForType(t);
                                  final base = Color.lerp(Colors.white, color, value)!;

                                  return GestureDetector(
                                    onTap: () => onToggleType(t, !selectedTypes.contains(t)),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOutCubic,
                                      decoration: BoxDecoration(
                                        color: selectedTypes.contains(t)
                                            ? base
                                            : Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selectedTypes.contains(t)
                                              ? color
                                              : Colors.grey.shade300,
                                          width: 1.2,
                                        ),
                                        boxShadow: selectedTypes.contains(t)
                                            ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                            : [],
                                      ),
                                      transform: Matrix4.identity()
                                        ..scale(selectedTypes.contains(t) ? 1.05 : 1.0),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              icon,
                                              size: 16,
                                              color: selectedTypes.contains(t)
                                                  ? Colors.white
                                                  : color.withOpacity(0.9),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              t[0].toUpperCase() + t.substring(1),
                                              style: TextStyle(
                                                color: selectedTypes.contains(t)
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),




                        const SizedBox(height: 16),
                        Container(height: 1.4, color: _dexWhite),
                        const SizedBox(height: 14),

                        // 🔹 Generación
                        const Text(
                          "Generación",
                          style: TextStyle(
                            color: _dexWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 🔹 Lista de regiones (sin scroll independiente)
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: regionBanners.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final region = regionBanners[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () =>
                                    onSelectGeneration(index == 0 ? 0 : index),
                                child: Container(
                                  height: 82,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xCC7A0A16),
                                        Color(0xCC4E0911),
                                      ],
                                    ),
                                    border:
                                    Border.all(color: _dexWhite, width: 1.2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // 🔹 Imagen limpia
                                        if ((region["image"] as String).isNotEmpty)
                                          Image.network(
                                            region["image"]!,
                                            fit: BoxFit.cover,
                                            filterQuality: FilterQuality.high,
                                            errorBuilder: (_, __, ___) =>
                                            const SizedBox(),
                                          ),

                                        // 🔹 Degradado lateral leve
                                        const DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0x1A000000),
                                                Colors.transparent,
                                                Color(0x1A000000),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // 🔹 Contenido: barra + texto + chevron
                                        Positioned.fill(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                margin: const EdgeInsets.symmetric(
                                                    vertical: 12),
                                                decoration: BoxDecoration(
                                                  color:
                                                  _dexWhite.withOpacity(.85),
                                                  borderRadius:
                                                  BorderRadius.circular(8),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  region["title"]!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: _dexWhite,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    letterSpacing: .4,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black45,
                                                        offset: Offset(0, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                color: _dexWhite,
                                                size: 22,
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );


  }
}






// _SearchBar remains the same
class _SearchBar extends StatelessWidget {
  const _SearchBar({this.onChanged});
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.hasDrawer ?? false) {
              scaffold!.openDrawer();
            }
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o #ID',
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
