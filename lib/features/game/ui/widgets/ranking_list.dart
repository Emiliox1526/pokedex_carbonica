import 'package:flutter/material.dart';
import 'package:pokedex_carbonica/gen/l10n/app_localizations.dart';
import '../../domain/game_score.dart';
import 'package:pokedex_carbonica/common/extensions/l10n_extension.dart';

/// Lista de ranking con las mejores puntuaciones.
///
/// Muestra el top 10 de puntuaciones con información detallada.
class RankingList extends StatelessWidget {
  /// Lista de puntuaciones a mostrar.
  final List<GameScore> scores;

  /// Si está cargando.
  final bool isLoading;

  /// Mensaje de error si existe.
  final String? errorMessage;

  const RankingList({
    super.key,
    required this.scores,
    this.isLoading = false,
    this.errorMessage,
  });

  // Colores del tema
  static const Color _dexBurgundy = Color(0xFF7A0A16);
  static const Color _dexDeep = Color(0xFF4E0911);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (scores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noScores,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.playToRank,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        return _RankingItem(
          score: scores[index],
          rank: index + 1,
          l10n: l10n,
        );
      },
    );
  }
}

/// Item individual del ranking.
class _RankingItem extends StatelessWidget {
  final GameScore score;
  final int rank;
  final AppLocalizations l10n;

  const _RankingItem({
    required this.score,
    required this.rank,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: rank <= 3
              ? _getTopColors(rank)
              : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
        ),
        border: Border.all(
          color: rank <= 3 ? _getRankColor(rank) : Colors.white24,
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: _getRankColor(rank).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Posición
          _buildRankBadge(),
          const SizedBox(width: 16),
          
          // Información de la puntuación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Puntuación
                Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.scorePoints('${score.score}'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Detalles
                Row(
                  children: [
                    _buildDetailChip(
                      Icons.check_circle_outline,
                      '${score.correctAnswers}/${score.totalQuestions}',
                      Colors.green.shade300,
                    ),
                    const SizedBox(width: 12),
                    _buildDetailChip(
                      Icons.local_fire_department,
                      'x${score.bestStreak}',
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Fecha
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                score.formattedDate,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rank <= 3
            ? _getRankColor(rank).withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: rank <= 3 ? _getRankColor(rank) : Colors.white38,
          width: 2,
        ),
      ),
      child: Center(
        child: rank <= 3
            ? Text(
                _getRankEmoji(rank),
                style: const TextStyle(fontSize: 24),
              )
            : Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return Colors.white54;
    }
  }

  List<Color> _getTopColors(int rank) {
    switch (rank) {
      case 1:
        return [
          Colors.amber.withOpacity(0.2),
          Colors.amber.withOpacity(0.1),
        ];
      case 2:
        return [
          Colors.grey.withOpacity(0.2),
          Colors.grey.withOpacity(0.1),
        ];
      case 3:
        return [
          Colors.brown.withOpacity(0.2),
          Colors.brown.withOpacity(0.1),
        ];
      default:
        return [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ];
    }
  }
}
