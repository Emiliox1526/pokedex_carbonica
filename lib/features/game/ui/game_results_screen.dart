import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_carbonica/l10n/app_localizations.dart';
import '../domain/game_achievement.dart';
import '../domain/game_achievement_localizations.dart';
import 'game_provider.dart';
import 'widgets/ranking_list.dart';
import 'who_is_pokemon_screen.dart';
import 'package:pokedex_carbonica/l10n/l10n_extension.dart';
import 'package:pokedex_carbonica/features/pokemon_list/ui/widgets/language_selector.dart';

/// Pantalla de resultados del juego con estilo vibrante inspirado en Pokémon.
/// Mantiene la misma API pública.
class GameResultsScreen extends ConsumerWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int bestStreak;
  final int highScore;
  final List<GameAchievement> newlyUnlockedAchievements;
  final bool showRankingOnly;
  final int? selectedGeneration;

  const GameResultsScreen({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.bestStreak,
    required this.highScore,
    this.newlyUnlockedAchievements = const [],
    this.showRankingOnly = false,
    this.selectedGeneration,
  });

  // Paleta inspirada en Pokémon (Poké Ball rojo/negro + acentos azul/amarillo/verde)
  static const Color _bgTop = Color(0xFF1A1A1A);      // Negro suave (parte superior)
  static const Color _bgBottom = Color(0xFFB71C1C);   // Rojo intenso (parte inferior)
  static const Color _accentBlue = Color(0xFF1976D2); // Azul (Water-like)
  static const Color _accentYellow = Color(0xFFFFD600); // Amarillo (Electric)
  static const Color _accentGreen = Color(0xFF2E7D32); // Verde (Grass)
  static const Color _accentRed = Color(0xFFD32F2F);  // Rojo (Fire)
  static const Color _accentPurple = Color(0xFF7E57C2); // Morado (Psychic)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente tipo Poké Ball (negro → rojo)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_bgTop, _bgBottom],
                ),
              ),
            ),
          ),
          // Brillo diagonal suave
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, l10n),

                // Contenido
                Expanded(
                  child: showRankingOnly
                      ? _buildRankingOnlyView(rankingAsync, l10n)
                      : _buildResultsView(context, ref, rankingAsync, l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.chevron_left_rounded, color: Colors.black.withOpacity(0.2), size: 26),
                    const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              showRankingOnly ? l10n.rankingTitle : l10n.resultsTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const LanguageSelector(iconColor: Colors.white),
        ],
      ),
    );
  }

  Widget _buildRankingOnlyView(
      AsyncValue<dynamic> rankingAsync,
      AppLocalizations l10n,
      ) {
    return rankingAsync.when(
      data: (scores) => RankingList(scores: scores),
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (error, _) => RankingList(
        scores: const [],
        errorMessage: l10n.errorLoadingRanking,
      ),
    );
  }

  Widget _buildResultsView(
      BuildContext context,
      WidgetRef ref,
      AsyncValue<dynamic> rankingAsync,
      AppLocalizations l10n,
      ) {
    final isNewHighScore = score > highScore && score > 0;
    final accuracy = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).toStringAsFixed(0)
        : '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tarjeta principal de resultado
          _ResultCard(
            score: score,
            isNewHighScore: isNewHighScore,
            l10n: l10n,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            bestStreak: bestStreak,
            accuracy: accuracy,
          ),
          const SizedBox(height: 24),

          // Logros desbloqueados
          if (newlyUnlockedAchievements.isNotEmpty)
            _AchievementsCard(achievements: newlyUnlockedAchievements, l10n: l10n),

          const SizedBox(height: 28),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: _OutlinedModernButton(
                  icon: Icons.home_rounded,
                  label: l10n.menu,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GradientActionButton(
                  icon: Icons.replay_rounded,
                  label: l10n.play,
                  // Azul → Amarillo (referencia Water/Electric)
                  startColor: _accentBlue,
                  endColor: _accentYellow,
                  textColor: Colors.black.withOpacity(0.85),
                  onPressed: () {
                    ref.read(gameProvider(selectedGeneration).notifier).startGame();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => WhoIsPokemonScreen(
                          selectedGeneration: selectedGeneration,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Ranking
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.rankingSectionTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: rankingAsync.when(
              data: (scores) => RankingList(scores: scores),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.errorLoadingRanking,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int score;
  final bool isNewHighScore;
  final AppLocalizations l10n;
  final int correctAnswers;
  final int totalQuestions;
  final int bestStreak;
  final String accuracy;

  const _ResultCard({
    required this.score,
    required this.isNewHighScore,
    required this.l10n,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.bestStreak,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding más holgado para que “Game Finished” no se vea apretado
      padding: const EdgeInsets.fromLTRB(64, 28, 64, 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          // Header con icono contextual
          if (isNewHighScore) ...[
            Icon(Icons.emoji_events_rounded, color: GameResultsScreen._accentYellow, size: 44),
            const SizedBox(height: 10),
            Text(
              l10n.newRecord,
              style: TextStyle(
                color: GameResultsScreen._accentYellow,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ] else ...[
            const Icon(Icons.catching_pokemon_rounded, color: Colors.white, size: 44),
            const SizedBox(height: 10),
            Text(
              l10n.gameFinished,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Puntuación central
          Text(
            '$score',
            style: TextStyle(
              color: isNewHighScore ? GameResultsScreen._accentYellow : Colors.white,
              fontSize: 58,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.pointsLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 24),
          // Stats en chips con colores tipo tipo elemental
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatChip(
                icon: Icons.check_circle_rounded,
                label: l10n.statsHits,
                value: '$correctAnswers/$totalQuestions',
                bg: GameResultsScreen._accentGreen.withOpacity(0.20), // Grass-like
                fg: GameResultsScreen._accentGreen,
              ),
              _StatChip(
                icon: Icons.percent_rounded,
                label: l10n.statsAccuracy,
                value: '$accuracy%',
                bg: GameResultsScreen._accentBlue.withOpacity(0.20), // Water-like
                fg: GameResultsScreen._accentBlue,
              ),
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                label: l10n.statsBestStreak,
                value: '$bestStreak',
                bg: GameResultsScreen._accentRed.withOpacity(0.20), // Fire-like
                fg: GameResultsScreen._accentRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bg;
  final Color fg;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: fg,
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final List<GameAchievement> achievements;
  final AppLocalizations l10n;

  const _AchievementsCard({
    required this.achievements,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: GameResultsScreen._accentYellow.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameResultsScreen._accentYellow.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: GameResultsScreen._accentYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.unlockedAchievementsTitle,
                style: TextStyle(
                  color: GameResultsScreen._accentYellow,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: achievements.map((achievement) {
              final achievementName = achievement.localizedName(l10n);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(achievement.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      achievementName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OutlinedModernButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _OutlinedModernButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.45)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color startColor;
  final Color endColor;
  final Color textColor;

  const _GradientActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.startColor,
    required this.endColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}