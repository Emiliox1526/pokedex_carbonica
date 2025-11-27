import 'package:flutter/material.dart';

class PokemonOptionsModal extends StatelessWidget {
  const PokemonOptionsModal({
    Key? key,
    required this.baseColor,
    required this.secondaryColor,
    required this.initialShowShiny,
    required this.initialIsFavorite,
    required this.onlyLevelUp,
    required this.movesMethod,
    required this.movesSort,
    required this.onToggleShiny,
    required this.onToggleFavorite,
    required this.onChangeMovesMethod,
    required this.onChangeMovesSort,
    required this.onToggleOnlyLevelUp,
  }) : super(key: key);

  final Color baseColor;
  final Color secondaryColor;
  final bool initialShowShiny;
  final bool initialIsFavorite;
  final bool onlyLevelUp;
  final String movesMethod;
  final String movesSort;

  final VoidCallback onToggleShiny;
  final VoidCallback onToggleFavorite;
  final ValueChanged<String> onChangeMovesMethod;
  final ValueChanged<String> onChangeMovesSort;
  final VoidCallback onToggleOnlyLevelUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        // Make corners rounded and use a subtle elevation look
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, -6)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Improved drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune, size: 22, color: baseColor),
                const SizedBox(width: 8),
                const Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Shiny toggle card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Icon with colored background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome, color: baseColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Show Shiny',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Toggle shiny sprite',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  // Styled switch
                  Switch(
                    value: initialShowShiny,
                    activeColor: baseColor,
                    onChanged: (_) => onToggleShiny(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Favorites card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: initialIsFavorite ? Colors.red.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: initialIsFavorite ? Colors.red.shade200 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: initialIsFavorite ? Colors.red.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      initialIsFavorite ? Icons.favorite : Icons.favorite_border,
                      color: initialIsFavorite ? Colors.red : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          initialIsFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Save this Pokémon for quick access',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      initialIsFavorite ? Icons.favorite : Icons.favorite_border,
                      color: initialIsFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
