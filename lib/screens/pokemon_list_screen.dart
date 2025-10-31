import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../queries/get_pokemon_list.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final PageController _pageController = PageController(viewportFraction: .90);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 🎨 Colores por tipo
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: hex('#F5F7F9'),
      body: Stack(
        children: [
          // Fondo degradado + patrón suave
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [hex('#9e1932'), hex('#520317')],
                ),
              ),
            ),
          ),
          // Sutiles burbujas decorativas
          Positioned(
            top: -80,
            left: -40,
            child: _Bubble(size: 180, blur: 40, opacity: .20),
          ),
          Positioned(
            bottom: -60,
            right: -30,
            child: _Bubble(size: 140, blur: 30, opacity: .18),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 12),

                  // Buscador (placeholder visual)
                  _SearchBar(),
                  const SizedBox(height: 16),

                  // Contenido
                  Expanded(
                    child: Query(
                      options: QueryOptions(document: gql(getPokemonListQuery)),
                      builder: (result, {fetchMore, refetch}) {
                        if (result.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (result.hasException) {
                          return Center(child: Text('Error: \\n${result.exception}'));
                        }

                        final List data = result.data?['pokemon_v2_pokemon'] ?? [];
                        if (data.isEmpty) {
                          return const Center(child: Text('Sin resultados'));
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: data.length,
                                padEnds: false,
                                itemBuilder: (context, index) {
                                  final p = data[index] as Map<String, dynamic>;
                                  final String name = (p['name'] as String?)?.toUpperCase() ?? 'POKÉMON';
                                  final int id = p['id'] as int? ?? 0;
                                  final String idStr = '#${id.toString().padLeft(3, '0')}';

                                  // Imagen oficial desde sprites JSON
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

                                  // Detalles simples
                                  final int height = (p['height'] as int?) ?? 0;
                                  final int weight = (p['weight'] as int?) ?? 0;
                                  final int baseExp = (p['base_experience'] as int?) ?? 0;
                                  final List<String> abilities = ((p['pokemon_v2_pokemonabilities'] as List?) ?? [])
                                      .map((a) => a['pokemon_v2_ability']?['name'] as String? ?? '')
                                      .where((s) => s.isNotEmpty)
                                      .toList();

                                  final primary = types.isNotEmpty ? types.first : 'normal';
                                  final baseColor = typeColor[primary] ?? typeColor['normal']!;

                                  final isFocused = (index - _page).abs() < 0.6;

                                  return AnimatedScale(
                                    scale: isFocused ? 1.0 : 0.95,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    child: _PokemonCard(
                                      id: idStr,
                                      name: name,
                                      imageUrl: imageUrl,
                                      types: types,
                                      color: baseColor,
                                      typeColor: typeColor,
                                      iconForType: iconForType,
                                      height: height,
                                      weight: weight,
                                      baseExp: baseExp,
                                      abilities: abilities,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            _DotsIndicator(
                              controller: _pageController,
                              itemCount: data.length,
                              color: Colors.black26,
                              activeColor: Colors.black87,
                            ),
                            const SizedBox(height: 8),
                          ],
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

class _PokemonCard extends StatelessWidget {
  _PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.color,
    required this.typeColor,
    required this.iconForType,
    required this.height,
    required this.weight,
    required this.baseExp,
    required this.abilities,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final List<String> types;
  final Color color;
  final Map<String, Color> typeColor;
  final IconData Function(String) iconForType;
  final int height;
  final int weight;
  final int baseExp;
  final List<String> abilities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Fondo por tipo
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.75),
                      color.withOpacity(1),
                    ],
                  ),
                ),
              ),
            ),
            // Patrón diagonal tenue


            // Contenido
            Column(
              children: [
                // Cabecera compacta (id + nombre + tipos)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(id, style: theme.textTheme.labelLarge?.copyWith(color: Colors.black45)),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: .4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final t in types)
                                  _TypeChip(
                                    label: t,
                                    color: typeColor[t] ?? typeColor['normal']!,
                                    icon: iconForType(t),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Botón flotante de acción (decorativo)
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: () {},
                          tooltip: 'Favorito',
                        ),
                      )
                    ],
                  ),
                ),

                // Imagen
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'img_$id',
                      child: imageUrl != null
                          ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Image.network(
                          imageUrl!,
                          filterQuality: FilterQuality.high,
                          key: ValueKey(imageUrl),
                          height: 210,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(Icons.hide_image, size: 80),
                        ),
                      )
                          : Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
                ),

                // Panel de detalles (glassmorphism)
                _GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detalles', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _InfoTile(icon: Icons.height, label: 'Altura', value: '${(height / 10.0).toStringAsFixed(1)} m'),
                            _InfoTile(icon: Icons.monitor_weight, label: 'Peso', value: '${(weight / 10.0).toStringAsFixed(1)} kg'),
                            _InfoTile(icon: Icons.bolt, label: 'Exp. base', value: '$baseExp'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (abilities.isNotEmpty) ...[
                          Text('Habilidades', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final a in abilities.take(4)) _AbilityChip(label: a),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true, // por ahora solo visual
      decoration: InputDecoration(
        hintText: 'Buscar (próximamente)',
        prefixIcon: Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DotsIndicator extends AnimatedWidget {
  const _DotsIndicator({
    required this.controller,
    required this.itemCount,
    this.color = Colors.black26,
    this.activeColor = Colors.black,
    this.maxDots = 9,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final Color color;
  final Color activeColor;
  final int maxDots;

  static const double _dotBase = 7.0;
  static const double _spacing = 6.0;

  int get _currentIndex =>
      (controller.page ?? controller.initialPage.toDouble()).round().clamp(0, itemCount - 1);

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox.shrink();

    final visible = itemCount <= maxDots ? itemCount : maxDots;
    int start = _currentIndex - (visible ~/ 2);
    start = start.clamp(0, (itemCount - visible).clamp(0, itemCount));
    final end = (start + visible).clamp(0, itemCount);

    final dots = <Widget>[];
    if (start > 0) {
      dots.add(const _MiniEllipsis());
    }

    for (int i = start; i < end; i++) {
      final selectedness = (1.0 - ((controller.page ?? _currentIndex.toDouble()) - i).abs())
          .clamp(0.0, 1.0);
      final size = _dotBase + (6.0 * selectedness);
      dots.add(Container(
        width: size,
        height: _dotBase,
        margin: const EdgeInsets.symmetric(horizontal: _spacing / 2),
        decoration: BoxDecoration(
          color: Color.lerp(color, activeColor, selectedness),
          borderRadius: BorderRadius.circular(8),
        ),
      ));
    }

    if (end < itemCount) {
      dots.add(const _MiniEllipsis());
    }

    return SizedBox(
      height: _dotBase,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: dots),
        ),
      ),
    );
  }
}

class _MiniEllipsis extends StatelessWidget {
  const _MiniEllipsis();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
            (i) => Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12.withOpacity(.06))),
        ),
        child: child,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.color, required this.icon});
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color.withOpacity(.9)),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: color.darken(),
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbilityChip extends StatelessWidget {
  const _AbilityChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: hex('#00000014'), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Text(
        label.replaceAll('-', ' '),
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12.withOpacity(.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.blur, required this.opacity});
  final double size;
  final double blur; // ya no se usa, se deja para mantener compatibilidad
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity * 0.7),
      ),
    );
  }
}

/// Patrón diagonal muy suave para darle textura al fondo de la tarjeta
class _DiagonalPatternPainter extends CustomPainter {
  _DiagonalPatternPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double gap = 14;
    for (double y = 0; y < size.height + size.width; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(y, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension _ColorUtils on Color {
  Color darken([double amount = .18]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

/// Utilidad para usar colores en formato CSS tipo '#FFF', '#RRGGBB' o '#RRGGBBAA' (CSS).
/// Convierte a ARGB (Flutter) por ti.
Color hex(String input) {
  assert(input.isNotEmpty);
  var h = input.trim();
  if (h.startsWith('#')) h = h.substring(1);
  // Expandir #RGB y #RGBA
  if (h.length == 3) {
    // RGB -> RRGGBB
    h = h.split('').map((c) => '$c$c').join();
    h = 'FF' + h; // opaco
  } else if (h.length == 4) {
    // RGBA -> RRGGBBAA, luego a AARRGGBB (Flutter)
    final chars = h.split('');
    final r = '${chars[0]}${chars[0]}';
    final g = '${chars[1]}${chars[1]}';
    final b = '${chars[2]}${chars[2]}';
    final a = '${chars[3]}${chars[3]}';
    h = a + r + g + b; // ARGB
  } else if (h.length == 6) {
    // RRGGBB -> AARRGGBB
    h = 'FF' + h;
  } else if (h.length == 8) {
    // CSS RGBA #RRGGBBAA -> ARGB
    final rrggbb = h.substring(0, 6);
    final aa = h.substring(6, 8);
    h = aa + rrggbb;
  } else {
    throw FormatException('Hex inválido: use #RGB, #RGBA, #RRGGBB o #RRGGBBAA.');
  }
  return Color(int.parse(h, radix: 16));
}

/// Conveniencia: '#F80'.toColor()
extension HexStringToColor on String {
  Color toColor() => hex(this);
}
