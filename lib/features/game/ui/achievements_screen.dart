import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_carbonica/gen/l10n/app_localizations.dart';
import 'package:pokedex_carbonica/common/extensions/l10n_extension.dart';
import 'package:pokedex_carbonica/common/widgets/language_selector.dart';
import 'game_provider.dart';
import 'widgets/achievement_badge.dart';

/// Pantalla de logros del juego.
///
/// Muestra todos los logros disponibles y su estado de desbloqueo.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  // Colores del tema
  static const Color _bg1 = Color(0xFFFF365A);
  static const Color _bg2 = Color(0xFF8C0025);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final achievementsAsync = ref.watch(achievementsProvider);
    final statsAsync = ref.watch(gameStatsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_bg1, _bg2],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, l10n),

                // Estadísticas
                statsAsync.when(
                  data: (stats) => _buildStats(stats, l10n),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Lista de logros
                Expanded(
                  child: achievementsAsync.when(
                    data: (achievements) =>
                        _buildAchievementsList(achievements, l10n),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (error, _) => Center(
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
                            l10n.achievementsError,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.achievementsTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const LanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildStats(GameStats stats, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.sports_esports,
            value: '${stats.totalGames}',
            label: l10n.statsGames,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            value: '${stats.totalCorrect}',
            label: l10n.statsHits,
          ),
          _buildStatItem(
            icon: Icons.local_fire_department,
            value: '${stats.bestStreak}',
            label: l10n.statsBestStreak,
          ),
          _buildStatItem(
            icon: Icons.emoji_events,
            value: '${stats.unlockedAchievements}/6',
            label: l10n.statsAchievements,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(
    List<dynamic> achievements,
    AppLocalizations l10n,
  ) {
    // Ordenar: desbloqueados primero
    final sorted = List.from(achievements)
      ..sort((a, b) {
        if (a.isUnlocked == b.isUnlocked) return 0;
        return a.isUnlocked ? -1 : 1;
      });

    final unlocked = sorted.where((a) => a.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.progressUnlocked('$unlocked', '${achievements.length}'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        // Barra de progreso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: achievements.isNotEmpty ? unlocked / achievements.length : 0,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final achievement = sorted[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AchievementBadge(
                  achievement: achievement,
                  showDescription: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
