import 'package:flutter/material.dart';
import '../../data/models.dart';
import 'map_utils.dart';

/// Marker widget for displaying trainers on the map
class TrainerMarker extends StatelessWidget {
  final TrainerData trainer;
  final VoidCallback onTap;
  final double scale;

  const TrainerMarker({
    super.key,
    required this.trainer,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24 * scale,
        height: 24 * scale,
        decoration: BoxDecoration(
          color: _getTrainerColor(),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getTrainerIcon(),
            size: 14 * scale,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getTrainerColor() {
    if (trainer.isSpinner) {
      return Colors.purple;
    } else if (trainer.isWalker) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getTrainerIcon() {
    if (trainer.isSpinner) {
      return Icons.refresh;
    } else if (trainer.isWalker) {
      return Icons.directions_walk;
    } else {
      return Icons.person;
    }
  }
}

/// Shows detailed information about a trainer in a bottom sheet
void showTrainerDetails(BuildContext context, TrainerData trainer) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                trainer.isSpinner
                    ? Icons.refresh
                    : trainer.isWalker
                        ? Icons.directions_walk
                        : Icons.person,
                size: 32,
                color: trainer.isSpinner
                    ? Colors.purple
                    : trainer.isWalker
                        ? Colors.orange
                        : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainer.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (trainer.isSpinner || trainer.isWalker)
                      Text(
                        trainer.isSpinner ? 'Spinner' : 'Walker',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoRow(
            label: 'Pokémon',
            value: '${trainer.numPokemon}',
          ),
          const SizedBox(height: 8),
          InfoRow(
            label: 'Levels',
            value: trainer.levelsString,
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
