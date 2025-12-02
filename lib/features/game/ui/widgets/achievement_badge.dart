import 'package:flutter/material.dart';
import 'package:pokedex_carbonica/l10n/app_localizations.dart';

import '../../domain/game_achievement.dart';
import '../../domain/game_achievement_localizations.dart';

/// Badge que muestra un logro del juego.
///
/// Muestra el icono, nombre y estado de desbloqueo del logro.
class AchievementBadge extends StatelessWidget {
  /// El logro a mostrar.
  final GameAchievement achievement;

  /// Si mostrar la descripción completa.
  final bool showDescription;

  /// Si el badge es compacto.
  final bool compact;

  /// Callback al presionar el badge.
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showDescription = true,
    this.compact = false,
    this.onTap,
  });

  static const Color _dexBurgundy = Color(0xFF7A0A16);
  static const Color _dexDeep = Color(0xFF4E0911);
  static const Color _lockedColor = Color(0xFF424242);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = achievement.localizedName(l10n);
    final description = achievement.localizedDescription(l10n);

    if (compact) {
      return _buildCompactBadge(name, description);
    }
    return Semantics(
      label: name,
      hint: description,
      child: _buildFullBadge(l10n, name, description),
    );
  }

  Widget _buildCompactBadge(String name, String description) {
    return Tooltip(
      message: '$name\n$description',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: achievement.isUnlocked
                    ? Colors.white38
                    : Colors.white12,
              ),
            ),
            child: Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 24,
                color: achievement.isUnlocked ? null : Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullBadge(
    AppLocalizations l10n,
    String name,
    String description,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: achievement.isUnlocked
                  ? [_dexDeep, _dexBurgundy]
                  : [_lockedColor.withOpacity(0.5), _lockedColor.withOpacity(0.3)],
            ),
            border: Border.all(
              color: achievement.isUnlocked
                  ? Colors.white54
                  : Colors.white24,
              width: 1.5,
            ),
            boxShadow: achievement.isUnlocked
                ? [
                    BoxShadow(
                      color: _dexBurgundy.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Icono del logro
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 32,
                      color: achievement.isUnlocked ? null : Colors.white38,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del logro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: achievement.isUnlocked
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showDescription) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: achievement.isUnlocked
                              ? Colors.white70
                              : Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (achievement.isUnlocked && achievement.unlockedDate != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade300,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.unlockedOnDate(
                              _formatDate(achievement.unlockedDate!),
                            ),
                            style: TextStyle(
                              color: Colors.green.shade300,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Indicador de estado
              if (!achievement.isUnlocked)
                const Icon(
                  Icons.lock_outline,
                  color: Colors.white38,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
