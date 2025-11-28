import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget que muestra la silueta de un Pokémon.
///
/// Usa ColorFiltered para mostrar la imagen en negro (silueta)
/// y puede revelar la imagen original con una animación.
class PokemonSilhouette extends StatelessWidget {
  /// URL de la imagen del Pokémon.
  final String? imageUrl;

  /// Si debe mostrar la silueta (true) o la imagen original (false).
  final bool showSilhouette;

  /// Tamaño del widget.
  final double size;

  /// Duración de la animación de revelación.
  final Duration animationDuration;

  const PokemonSilhouette({
    super.key,
    required this.imageUrl,
    this.showSilhouette = true,
    this.size = 200,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return _buildPlaceholder();
    }

    return AnimatedSwitcher(
      duration: animationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      child: showSilhouette
          ? _buildSilhouette()
          : _buildRevealedImage(),
    );
  }

  Widget _buildSilhouette() {
    return ColorFiltered(
      key: const ValueKey('silhouette'),
      colorFilter: const ColorFilter.mode(
        Colors.black,
        BlendMode.srcIn,
      ),
      child: _buildImage(),
    );
  }

  Widget _buildRevealedImage() {
    return Container(
      key: const ValueKey('revealed'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => _buildLoadingIndicator(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.catching_pokemon,
          size: 80,
          color: Colors.white30,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Icon(
        Icons.error_outline,
        size: 60,
        color: Colors.white54,
      ),
    );
  }
}
