import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget que muestra la silueta de un Pokémon.
/// Ajustado para que el borde/sombra no se corte en layouts estrechos.
class PokemonSilhouette extends StatelessWidget {
  final String? imageUrl;
  final bool showSilhouette;
  final double size;
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
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      child: showSilhouette ? _buildSilhouette() : _buildRevealedImage(),
    );
  }

  Widget _buildSilhouette() {
    return ColorFiltered(
      key: const ValueKey('silhouette'),
      colorFilter: const ColorFilter.mode(
        Colors.black,
        BlendMode.srcIn,
      ),
      child: _buildImageContainer(),
    );
  }

  Widget _buildRevealedImage() {
    // Usamos ClipRRect para evitar que el boxShadow se "corte"
    return ClipRRect(
      key: const ValueKey('revealed'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        // Añadimos padding interno para que el shadow no se recorte visualmente
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.25),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _buildImageContainer(),
      ),
    );
  }

  Widget _buildImageContainer() {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),
        child: const Center(
          child: Icon(
            Icons.catching_pokemon,
            size: 80,
            color: Colors.white30,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
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