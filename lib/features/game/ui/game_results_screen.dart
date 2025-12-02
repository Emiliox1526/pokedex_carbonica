import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_achievement.dart';
import 'game_provider.dart';
import 'widgets/ranking_list.dart';
import 'who_is_pokemon_screen.dart';

/// Pantalla de resultados del juego.
///
/// Muestra la puntuación final, estadísticas de la partida
/// y el ranking de mejores puntuaciones.
class GameResultsScreen extends ConsumerWidget {
  /// Puntuación de la partida.
  final int score;

  /// Número de respuestas correctas.
  final int correctAnswers;

  /// Número total de preguntas.
  final int totalQuestions;

  /// Mejor racha de la partida.
  final int bestStreak;

  /// Mejor puntuación histórica.
  final int highScore;

  /// Logros desbloqueados en la partida.
  final List<GameAchievement> newlyUnlockedAchievements;

  /// Si solo mostrar el ranking (sin resultados de partida).
  final bool showRankingOnly;

  const GameResultsScreen({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.bestStreak,
    required this.highScore,
    this.newlyUnlockedAchievements = const [],
    this.showRankingOnly = false,
  });

  // Colores del tema
  static const Color _bg1 = Color(0xFFFF365A);
  static const Color _bg2 = Color(0xFF8C0025);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider);

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
                _buildHeader(context),

                // Contenido
                Expanded(
                  child: showRankingOnly
                      ? _buildRankingOnlyView(rankingAsync)
                      : _buildResultsView(context, ref, rankingAsync),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            showRankingOnly ? 'Ranking' : 'Resultados',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingOnlyView(AsyncValue<dynamic> rankingAsync) {
    return rankingAsync.when(
      data: (scores) => RankingList(scores: scores),
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (error, _) => RankingList(
        scores: const [],
        errorMessage: 'Error al cargar ranking',
      ),
    );
  }

  Widget _buildResultsView(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> rankingAsync,
  ) {
    final isNewHighScore = score > highScore && score > 0;
    final accuracy = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).toStringAsFixed(0)
        : '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tarjeta de resultado
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Column(
              children: [
                // Icono y título
                if (isNewHighScore) ...[
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡NUEVO RÉCORD!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  const Icon(
                    Icons.catching_pokemon,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PARTIDA FINALIZADA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Puntuación
                Text(
                  '$score',
                  style: TextStyle(
                    color: isNewHighScore ? Colors.amber : Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'PUNTOS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 24),

                // Estadísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.check_circle,
                      value: '$correctAnswers/$totalQuestions',
                      label: 'Aciertos',
                      color: Colors.green.shade300,
                    ),
                    _buildStatItem(
                      icon: Icons.percent,
                      value: '$accuracy%',
                      label: 'Precisión',
                      color: Colors.blue.shade300,
                    ),
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      value: '$bestStreak',
                      label: 'Mejor racha',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logros desbloqueados
          if (newlyUnlockedAchievements.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logros desbloqueados',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: newlyUnlockedAchievements.map((achievement) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(achievement.icon),
                            const SizedBox(width: 4),
                            Text(
                              achievement.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text(
                    'MENÚ',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(gameProvider.notifier).startGame();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const WhoIsPokemonScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('JUGAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _bg2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Ranking
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'RANKING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: rankingAsync.when(
              data: (scores) => RankingList(scores: scores),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (error, _) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Error al cargar ranking',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
