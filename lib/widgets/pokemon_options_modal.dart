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

            // Moves filters (method)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('Move filters', style: TextStyle(fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color)),
              ),
            ),

            // Method choice chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Level-up'),
                  selected: movesMethod == 'level-up',
                  onSelected: (_) => onChangeMovesMethod('level-up'),
                ),
                ChoiceChip(
                  label: const Text('Machine'),
                  selected: movesMethod == 'machine',
                  onSelected: (_) => onChangeMovesMethod('machine'),
                ),
                ChoiceChip(
                  label: const Text('Egg'),
                  selected: movesMethod == 'egg',
                  onSelected: (_) => onChangeMovesMethod('egg'),
                ),
                ChoiceChip(
                  label: const Text('Tutor'),
                  selected: movesMethod == 'tutor',
                  onSelected: (_) => onChangeMovesMethod('tutor'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Only level-up toggle + sort options
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(value: onlyLevelUp, onChanged: (_) => onToggleOnlyLevelUp()),
                      const SizedBox(width: 6),
                      const Expanded(child: Text('Only level-up')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: movesSort,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'level', child: Text('Sort: Level')),
                    DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
                  ],
                  onChanged: (v) {
                    if (v != null) onChangeMovesSort(v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reset & Close buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset filters'),
                    onPressed: () {
                      // Reset to defaults: level-up method, sort by level, onlyLevelUp=true
                      onChangeMovesMethod('level-up');
                      onChangeMovesSort('level');
                      // Ensure onlyLevelUp is true (toggle only if currently false)
                      if (!onlyLevelUp) onToggleOnlyLevelUp();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
