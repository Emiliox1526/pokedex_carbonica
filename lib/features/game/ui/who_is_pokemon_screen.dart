import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_carbonica/features/pokemon_list/ui/widgets/language_selector.dart';
import 'package:pokedex_carbonica/l10n/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../core/utils/sprite_utils.dart';
import '../domain/game_state.dart';
import '../domain/game_achievement.dart';
import 'game_provider.dart';
import 'widgets/pokemon_silhouette.dart';
import 'widgets/answer_button.dart';
import 'widgets/timer_bar.dart';
import 'widgets/score_display.dart';
import 'widgets/achievement_unlock_modal.dart';
import 'game_results_screen.dart';
import 'achievements_screen.dart';

// --- Configuración assets por generación (idéntico a lista principal) ---
const Map<int, String> _generationBackgroundImages = {
  0: 'lib/assets/AllGenerations.png',
  1: 'lib/assets/kanto.png',
  2: 'lib/assets/johto.png',
  3: 'lib/assets/hoenn.png',
  4: 'lib/assets/sinnoh.png',
  5: 'lib/assets/unova.png',
  6: 'lib/assets/kalos.png',
  7: 'lib/assets/alola.png',
  8: 'lib/assets/galar.png',
  9: 'lib/assets/paldea.png',
};
String _assetForGeneration(int? generation) =>
    _generationBackgroundImages[generation] ?? _generationBackgroundImages[0]!;

const Map<int, Color> _regionColors = {
  1: Color(0xFFEF5350),
  2: Color(0xFFFFCA28),
  3: Color(0xFF26A69A),
  4: Color(0xFF42A5F5),
  5: Color(0xFF7E57C2),
  6: Color(0xFFEC407A),
  7: Color(0xFF26C6DA),
  8: Color(0xFFD81B60),
  9: Color(0xFFFF7043),
};
Color _regionColorForGeneration(int? generation) =>
    _regionColors[generation] ?? const Color(0xFFEF5350);

class WhoIsPokemonScreen extends ConsumerStatefulWidget {
  final int? selectedGeneration;
  const WhoIsPokemonScreen({super.key, this.selectedGeneration});

  @override
  ConsumerState<WhoIsPokemonScreen> createState() =>
      _WhoIsPokemonScreenState();
}

class _WhoIsPokemonScreenState extends ConsumerState<WhoIsPokemonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gameState = ref.watch(gameProvider);
    final int? selectedGeneration = widget.selectedGeneration ?? 0;

    // Mostrar resultados si la partida terminó
    if (gameState.status == GameStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultsScreen(gameState);
      });
    }

    // --------------- FONDO VISUAL (idéntico lista principal y favoritos) ---------------
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Imagen blur por generación KANTO=1, etc
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Opacity(
                opacity: 0.55,
                child: Image.asset(
                  _assetForGeneration(selectedGeneration),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Decorativos igual que lista
          IgnorePointer(
            child: Stack(
              children: [
                // Círculo arriba izquierda
                Positioned(
                  top: -120,
                  left: -40,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 18,
                      ),
                    ),
                  ),
                ),
                // Rectángulo diagonal en el centro-derecha
                Positioned(
                  top: 600,
                  right: -150,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Container(
                      width: 260,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.white.withOpacity(0.02),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Gradiente color región por generación seleccionada
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _regionColorForGeneration(selectedGeneration)
                        .withOpacity(0.85),
                    _regionColorForGeneration(selectedGeneration)
                        .withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
          // Overlay oscuro igual a lista principal
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                _buildHeader(gameState, l10n),
                Expanded(child: _buildContent(gameState)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- HEADER Y CONTENIDO DEL GAME ----------
  Widget _buildHeader(GameState gameState, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (gameState.isPlaying) {
                _showExitConfirmation();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.whoIsPokemonTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (gameState.status == GameStatus.initial)
            IconButton(
              icon: const Icon(Icons.emoji_events, color: Colors.amber),
              tooltip: l10n.achievementsTitle,
              onPressed: () => _navigateToAchievements(),
            ),
          const SizedBox(width: 4),
          LanguageSelector(iconColor: Colors.white),
        ],
      ),
    );
  }

  Widget _buildContent(GameState gameState) {
    switch (gameState.status) {
      case GameStatus.initial:
        return _buildInitialMenu(gameState);
      case GameStatus.playing:
      case GameStatus.waitingAnswer:
      case GameStatus.showingResult:
        return _buildGameView(gameState);
      case GameStatus.finished:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
    }
  }

  Widget _buildInitialMenu(GameState gameState) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38, width: 3),
            ),
            child: const Center(
              child: Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.whoIsPokemonDescription,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.whoIsPokemonRules,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          if (gameState.highScore > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    l10n.highScoreLabel('${gameState.highScore}'),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: () => ref.read(gameProvider.notifier).startGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _regionColorForGeneration(widget.selectedGeneration ?? 0),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, size: 28),
                const SizedBox(width: 8),
                Text(
                  l10n.startGame,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _navigateToResults(),
            icon: const Icon(Icons.leaderboard, color: Colors.white70),
            label: Text(
              l10n.viewRanking,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(GameState gameState) {
    final l10n = context.l10n;
    final showSilhouette = gameState.status == GameStatus.waitingAnswer;
    final imageUrl = gameState.currentPokemon != null
        ? artworkUrlForId(gameState.currentPokemon!.id)
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ScoreDisplay(
            score: gameState.score,
            currentQuestion: gameState.currentQuestion,
            totalQuestions: gameState.totalQuestions,
            currentStreak: gameState.currentStreak,
            highScore: gameState.highScore,
          ),
          const SizedBox(height: 16),
          TimerBar(
            remainingSeconds: gameState.remainingTimeSeconds,
            maxSeconds: gameState.maxTimeSeconds,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: showSilhouette
                        ? l10n.silhouetteHiddenLabel
                        : l10n.silhouetteRevealedLabel,
                    image: true,
                    child: PokemonSilhouette(
                      imageUrl: imageUrl,
                      showSilhouette: showSilhouette,
                      size: 180,
                    ),
                  ),
                  if (gameState.status == GameStatus.showingResult)
                    _buildResultMessage(gameState, l10n),
                ],
              ),
            ),
          ),
          _buildAnswerOptions(gameState),
          if (gameState.status == GameStatus.showingResult)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(gameProvider.notifier).continueToNextQuestion(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _regionColorForGeneration(widget.selectedGeneration ?? 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  gameState.currentQuestion >= gameState.totalQuestions
                      ? l10n.showResults
                      : l10n.nextQuestion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultMessage(GameState gameState, AppLocalizations l10n) {
    final isCorrect = gameState.lastAnswerCorrect ?? false;
    final pokemonName = gameState.currentPokemon?.name ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text(
            isCorrect ? l10n.resultCorrect : l10n.resultIncorrect,
            style: TextStyle(
              color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.resultAnswer(pokemonName.toUpperCase()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          if (isCorrect && gameState.lastAnswerTimeSeconds != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                gameState.lastAnswerTimeSeconds! < 5
                    ? l10n.timeBonus
                    : l10n.timeElapsed(
                  gameState.lastAnswerTimeSeconds!.toStringAsFixed(1),
                ),
                style: TextStyle(
                  color: gameState.lastAnswerTimeSeconds! < 5
                      ? Colors.amber
                      : Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(GameState gameState) {
    final l10n = context.l10n;
    return Column(
      children: gameState.answerOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final pokemon = entry.value;
        final state = _getAnswerButtonState(gameState, index);

        return AnswerButton(
          pokemonName: pokemon.name,
          state: state,
          index: index,
          semanticsLabel: l10n.answerOption(pokemon.name),
          onPressed: () => ref.read(gameProvider.notifier).submitAnswer(index),
        );
      }).toList(),
    );
  }

  AnswerButtonState _getAnswerButtonState(GameState gameState, int index) {
    if (gameState.status == GameStatus.waitingAnswer) {
      return AnswerButtonState.idle;
    }

    if (gameState.status == GameStatus.showingResult) {
      final correctIndex = gameState.correctAnswerIndex;
      final selectedIndex = gameState.selectedAnswerIndex;

      if (index == correctIndex) {
        return selectedIndex == correctIndex
            ? AnswerButtonState.correct
            : AnswerButtonState.revealedCorrect;
      }

      if (index == selectedIndex) {
        return AnswerButtonState.incorrect;
      }

      return AnswerButtonState.disabled;
    }

    return AnswerButtonState.disabled;
  }

  void _showResultsScreen(GameState gameState) {
    _showUnlockedAchievements(gameState.newlyUnlockedAchievements, () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameResultsScreen(
            score: gameState.score,
            correctAnswers: gameState.correctAnswers,
            totalQuestions: gameState.totalQuestions,
            bestStreak: gameState.bestStreak,
            highScore: gameState.highScore,
            newlyUnlockedAchievements: gameState.newlyUnlockedAchievements,
          ),
        ),
      );
    });
  }

  void _showUnlockedAchievements(
      List<GameAchievement> achievements,
      VoidCallback onComplete,
      ) {
    if (achievements.isEmpty) {
      onComplete();
      return;
    }
    int currentIndex = 0;
    void showNext() {
      if (currentIndex >= achievements.length) {
        onComplete();
        return;
      }
      AchievementUnlockModal.show(
        context,
        achievements[currentIndex],
        onClose: () {
          currentIndex++;
          showNext();
        },
      );
    }
    showNext();
  }

  void _showExitConfirmation() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4E0911),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.exitGameTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.exitGameMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(gameProvider.notifier).resetToMenu();
              Navigator.of(context).pop();
            },
            child: Text(
              l10n.exit,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAchievements() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
  }

  void _navigateToResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameResultsScreen(
          score: 0,
          correctAnswers: 0,
          totalQuestions: 0,
          bestStreak: 0,
          highScore: 0,
          showRankingOnly: true,
        ),
      ),
    );
  }
}