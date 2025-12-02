import 'package:flutter/material.dart';
import 'package:pokedex_carbonica/l10n/app_localizations.dart';

import '../../../../common/extensions/l10n_extension.dart';

/// Widget que muestra la puntuación actual y racha.
///
/// Incluye la puntuación, número de pregunta actual y racha de aciertos.
class ScoreDisplay extends StatelessWidget {
  /// Puntuación actual.
  final int score;

  /// Pregunta actual (1-10).
  final int currentQuestion;

  /// Total de preguntas.
  final int totalQuestions;

  /// Racha actual de aciertos.
  final int currentStreak;

  /// Mejor puntuación histórica.
  final int highScore;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.currentStreak,
    required this.highScore,
  });

  // Colores del tema
  static const Color _dexBurgundy = Color(0xFF7A0A16);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Puntuación
          _buildScoreSection(l10n),
          
          // Separador
          Container(
            height: 40,
            width: 1,
            color: Colors.white30,
          ),
          
          // Pregunta actual
          _buildQuestionSection(l10n),
          
          // Separador
          Container(
            height: 40,
            width: 1,
            color: Colors.white30,
          ),
          
          // Racha
          _buildStreakSection(l10n),
        ],
      ),
    );
  }

  Widget _buildScoreSection(AppLocalizations l10n) {
    final isNewHighScore = score > highScore;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars_rounded,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.scoreLabel,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              score.toString(),
              style: TextStyle(
                color: isNewHighScore ? Colors.amber : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isNewHighScore)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionSection(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.help_outline_rounded,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.questionLabel,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$currentQuestion/$totalQuestions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSection(AppLocalizations l10n) {
    final hasMultiplier = currentStreak >= 3;
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: currentStreak > 0 ? Colors.orange : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.streakLabel,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              currentStreak.toString(),
              style: TextStyle(
                color: currentStreak > 0 ? Colors.orange : Colors.white54,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasMultiplier)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.streakMultiplier,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
