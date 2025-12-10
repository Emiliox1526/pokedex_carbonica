import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/pokemon_data.dart';
import '../../../../core/utils/type_translation.dart';

/// Extensión para oscurecer colores.
extension ColorDarken on Color {
  /// Oscurece el color por la cantidad especificada.
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

/// Widget de tarjeta de Pokémon para la lista.
///
/// Muestra la información básica de un Pokémon incluyendo:
/// - ID formateado
/// - Nombre en mayúsculas
/// - Imagen oficial
/// - Tipos con iconos
class PokemonCard extends StatelessWidget {
  /// Pokémon a mostrar.
  final Pokemon pokemon;

  /// Mapa de colores por tipo.
  final Map<String, Color> typeColors;

  /// Función para obtener el icono de un tipo.
  final IconData Function(String) iconForType;

  /// Callback cuando se toca la tarjeta.
  final VoidCallback? onTap;

  /// Constructor del widget.
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.typeColors,
    required this.iconForType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryType = pokemon.primaryType;
    final baseColor = typeColors[primaryType] ?? typeColors['normal']!;
    final borderRadius = BorderRadius.circular(24);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: child,
          ),
        );
      },
      child: Container(
        height: 160, // ⬅️ misma altura
        margin: const EdgeInsets.symmetric(vertical: 8), // ⬅️ mismas dimensiones exteriores
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            colors: [
              baseColor.darken(0.10),
              baseColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Stack(
                children: [
                  // ---------- SHAPES DE FONDO (más moderno) ----------
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Capa de brillo suave
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.10),
                            Colors.white.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // ---------- CONTENIDO PRINCIPAL ----------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Info textual
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Fila con ID en pill + pequeño indicador
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.22),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.18),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Text(
                                      pokemon.formattedId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                        color: Colors.white.withOpacity(0.90),
                                        letterSpacing: 0.6,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                ],
                              ),
                              const SizedBox(height: 10),
                              // Nombre del Pokémon
                              Text(
                                pokemon.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .4,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Chips de tipos
                              SizedBox(
                                height: 30,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: pokemon.types.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                                  itemBuilder: (_, i) {
                                    final t = pokemon.types[i];
                                    return _TypeChipSmall(
                                      label: t,
                                      color: typeColors[t] ??
                                          typeColors['normal']!,
                                      icon: iconForType(t),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Imagen del Pokémon
                        Hero(
                          tag: pokemon.heroTag,
                          child: pokemon.imageUrl != null
                              ? CachedNetworkImage(
                            imageUrl: pokemon.imageUrl!,
                            filterQuality: FilterQuality.high,
                            key: ValueKey(pokemon.imageUrl),
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            placeholder: (context, url) =>
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                  ),
                                ),
                            fadeInDuration:
                            const Duration(milliseconds: 300),
                            fadeOutDuration:
                            const Duration(milliseconds: 300),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.black26,
                            ),
                          )
                              : const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip pequeño de tipo para la tarjeta de Pokémon.
class _TypeChipSmall extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _TypeChipSmall({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Builder(
            builder: (context) => Text(
              translateType(context, label).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
