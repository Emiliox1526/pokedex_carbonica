import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/pokemon.dart';

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
        onTap: onTap,
        child: Container(
          height: 160,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [baseColor.withOpacity(0.8), baseColor.darken(0.15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Información del Pokémon
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              pokemon.formattedId,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.black45),
                            ),
                            const SizedBox(height: 6),
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
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 28,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: pokemon.types.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 6),
                                itemBuilder: (_, i) {
                                  final t = pokemon.types[i];
                                  return _TypeChipSmall(
                                    label: t,
                                    color: typeColors[t] ?? typeColors['normal']!,
                                    icon: iconForType(t),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Imagen del Pokémon con CachedNetworkImage
                      const SizedBox(width: 16),
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
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                  ),
                                ),
                                fadeInDuration: const Duration(milliseconds: 300),
                                fadeOutDuration: const Duration(milliseconds: 300),
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
    );
  }
}
