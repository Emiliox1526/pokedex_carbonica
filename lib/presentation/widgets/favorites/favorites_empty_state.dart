import 'package:flutter/material.dart';

/// Widget that displays an empty state message when there are no favorites.
///
/// Shows a friendly message and icon to encourage users to add favorites.
class FavoritesEmptyState extends StatelessWidget {
  const FavoritesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heart icon with pokeball
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.catching_pokemon,
                  size: 120,
                  color: Colors.white.withOpacity(0.15),
                ),
                const Icon(
                  Icons.favorite_outline,
                  size: 64,
                  color: Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Aún no tienes favoritos!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Explora la Pokédex y marca tus Pokémon favoritos tocando el corazón en la pantalla de detalles.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Hint with heart icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: 20,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Toca el corazón para agregar favoritos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
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
