import 'package:flutter/material.dart';

class PokemonOptionsModal extends StatelessWidget {
  const PokemonOptionsModal({
    Key? key,
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, -6)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 6,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(6)),
            ),

            // Title + Close
            Row(
              children: [
                const Expanded(
                  child: Text('Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 6),

            // Toggle shiny + Favorite
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                    title: const Text('Show shiny'),
                    subtitle: const Text('Toggle shiny sprite when available'),
                    trailing: Switch(
                      value: initialShowShiny,
                      onChanged: (_) {
                        onToggleShiny();
                        // Keep modal open so user sees the change
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: initialIsFavorite ? Colors.red.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    tooltip: initialIsFavorite ? 'Remove favorite' : 'Add to favorites',
                    onPressed: () {
                      onToggleFavorite();
                    },
                    icon: Icon(initialIsFavorite ? Icons.favorite : Icons.favorite_border,
                        color: initialIsFavorite ? Colors.red : Colors.black54),
                  ),
                )
              ],
            ),

            const Divider(height: 18),


],
        ),
      ),
    );
  }
}
