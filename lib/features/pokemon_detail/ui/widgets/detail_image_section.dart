import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:pokedex_carbonica/core/utils/type_utils.dart';
import 'type_chip.dart';

/// Widget displaying the Pokemon image with Hero animation and type chips.
class DetailImageSection extends StatelessWidget {
  /// The Pokemon's ID for fallback image URL.
  final int pokemonId;

  /// URL to the default sprite.
  final String? defaultImageUrl;

  /// URL to the shiny sprite.
  final String? shinyImageUrl;

  /// Whether to show the shiny sprite.
  final bool showShiny;

  /// The primary type name.
  final String primaryType;

  /// The secondary type name.
  final String secondaryType;

  /// The primary type color.
  final Color primaryColor;

  /// The secondary type color.
  final Color secondaryColor;

  /// The Hero tag for animation.
  final String heroTag;

  const DetailImageSection({
    super.key,
    required this.pokemonId,
    this.defaultImageUrl,
    this.shinyImageUrl,
    required this.showShiny,
    required this.primaryType,
    required this.secondaryType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.heroTag,
  });

  String _artworkUrlForId(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth.isFinite &&
                      constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width - 32;
              final imageDiameter =
                  math.max(100.0, math.min(360.0, availableWidth * 0.48));
              final scale = imageDiameter / 220.0;
              final chipOffset = imageDiameter * 0.45;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Pokemon image
                  Hero(
                    tag: heroTag,
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
                          crossFadeState: showShiny
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Image.network(
                            defaultImageUrl ?? _artworkUrlForId(pokemonId),
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Image.network(
                              _artworkUrlForId(pokemonId),
                              fit: BoxFit.contain,
                            ),
                          ),
                          secondChild: Image.network(
                            shinyImageUrl ??
                                defaultImageUrl ??
                                _artworkUrlForId(pokemonId),
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Image.network(
                              _artworkUrlForId(pokemonId),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Left type chip
                  Positioned(
                    left: -chipOffset,
                    child: TypeColumn(
                      icon: iconForType(primaryType),
                      color: primaryColor,
                      label: primaryType,
                      scale: scale,
                    ),
                  ),

                  // Right type chip
                  Positioned(
                    right: -chipOffset,
                    child: TypeColumn(
                      icon: iconForType(secondaryType),
                      color: secondaryColor,
                      label: secondaryType,
                      scale: scale,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
