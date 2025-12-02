import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'circle_button.dart';

/// Header widget for the Pokemon detail screen.
///
/// Displays the back button, Pokemon name, ID, favorite and share buttons.
class DetailHeader extends StatelessWidget {
  /// The Pokemon's display name.
  final String pokemonName;

  /// The Pokemon's formatted ID (e.g., '#001').
  final String idLabel;

  /// Whether this Pokemon is a favorite.
  final bool isFavorite;

  /// Callback when the back button is pressed.
  final VoidCallback onBack;

  /// Callback when the favorite button is pressed.
  final VoidCallback onToggleFavorite;

  /// Callback when the share button is pressed.
  final VoidCallback? onShare;

  /// Whether a share action is currently running.
  final bool isSharing;

  /// The image URL for sharing.
  final String? imageUrl;

  const DetailHeader({
    super.key,
    required this.pokemonName,
    required this.idLabel,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
    this.onShare,
    this.imageUrl,
    this.isSharing = false,
  });

  void _handleShare(BuildContext context) {
    if (onShare != null) {
      onShare!();
    } else {
      final txt = '$pokemonName $idLabel\n${imageUrl ?? ''}';
      Clipboard.setData(ClipboardData(text: txt));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied Pokémon info to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleButton(
          icon: Icons.arrow_back,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            pokemonName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
          ),
        ),
        IconButton(
          onPressed: onToggleFavorite,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isFavorite
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    key: ValueKey('fav_on'),
                  )
                : const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    key: ValueKey('fav_off'),
                  ),
          ),
        ),
        IconButton(
          onPressed: isSharing ? null : () => _handleShare(context),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSharing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.share, color: Colors.white),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          idLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
