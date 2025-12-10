import 'dart:async';
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

/// ---- Widget carrusel de siluetas con animación ----
class PokemonSilhouetteCarousel extends StatefulWidget {
  final List<int> pokemonIds;
  final double size;

  const PokemonSilhouetteCarousel({
    super.key,
    required this.pokemonIds,
    this.size = 210,
  });

  @override
  State<PokemonSilhouetteCarousel> createState() =>
      _PokemonSilhouetteCarouselState();
}

class _PokemonSilhouetteCarouselState extends State<PokemonSilhouetteCarousel>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _controller.reverse().then((_) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.pokemonIds.length;
        });
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = artworkUrlForId(widget.pokemonIds[_currentIndex]);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: PokemonSilhouette(
              imageUrl: imageUrl,
              showSilhouette: true,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

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
      ref.read(gameProvider(widget.selectedGeneration).notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gameState = ref.watch(gameProvider(widget.selectedGeneration));
    final int? selectedGeneration = widget.selectedGeneration ?? 0;

    if (gameState.status == GameStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultsScreen(gameState);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
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
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _regionColorForGeneration(selectedGeneration).withOpacity(0.13),
                    Colors.black.withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: gameState.status == GameStatus.initial
                      ? _buildHeader(gameState, l10n)
                      : const SizedBox.shrink(key: ValueKey('no-header')),
                ),
                Expanded(child: _buildContent(gameState)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GameState gameState, AppLocalizations l10n) {
    final selectedColor = _regionColorForGeneration(widget.selectedGeneration ?? 0);
    return Padding(
      key: const ValueKey('header'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 2),
      child: Container(
        decoration: BoxDecoration(
          color: selectedColor.withOpacity(0.23),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: selectedColor.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(2, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.whoIsPokemonTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (gameState.status == GameStatus.initial)
                    Tooltip(
                      message: l10n.achievementsTitle,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _navigateToAchievements(),
                          child: Container(
                            margin: const EdgeInsets.only(left: 7),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amberAccent.shade200,
                                  Colors.amber.withOpacity(0.95),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white70, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amberAccent.withOpacity(0.65),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.deepOrange.shade400,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            LanguageSelector(iconColor: Colors.white),
          ],
        ),
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
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white30,
              shape: BoxShape.circle,
              border: Border.all(
                color: _regionColorForGeneration(widget.selectedGeneration ?? 0).withOpacity(0.5),
                width: 16,
              ),
            ),
            child: Center(
              child: PokemonSilhouetteCarousel(
                pokemonIds: List.generate(9, (i) => i + 1),
                size: 200,
              ),
            ),
          ),
          const SizedBox(height: 40),
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
          const SizedBox(height: 48),
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
            onPressed: () => ref.read(gameProvider(widget.selectedGeneration).notifier).startGame(),
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
          const SizedBox(height: 12),
          if (widget.selectedGeneration != null && widget.selectedGeneration! > 0)
          // ... generation chip code unchanged ...
            if (widget.selectedGeneration == null || widget.selectedGeneration == 0)
            // ... all generations chip code unchanged ...
              const SizedBox(height: 12),
          TimerBar(
            remainingSeconds: gameState.remainingTimeSeconds,
            maxSeconds: gameState.maxTimeSeconds,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
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
                    const SizedBox(height: 12),
                    _buildAnswerOptions(gameState),

                    // Modern "Next" button (chip-like, vibrant, clean)
                    if (gameState.status == GameStatus.showingResult)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: _NextActionButton(
                          label: gameState.currentQuestion >= gameState.totalQuestions
                              ? l10n.showResults
                              : l10n.nextQuestion,
                          onTap: () => ref
                              .read(gameProvider(widget.selectedGeneration).notifier)
                              .continueToNextQuestion(),
                          // Colors aligned with vibrant theme
                          startColor: const Color(0xFF00C853), // Green A700
                          endColor: const Color(0xFF00E5FF),   // Cyan A200
                          textColor: Colors.black.withOpacity(0.85),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Sección de resultado: solo "Correct/Incorrect" y "Time Bonus/Elapsed" con chips modernos
  Widget _buildResultMessage(GameState gameState, AppLocalizations l10n) {
    final isCorrect = gameState.lastAnswerCorrect ?? false;
    final bool showTime = gameState.lastAnswerTimeSeconds != null;

    final Color statusBg = isCorrect ? const Color(0xFF00C853) : const Color(0xFFFF1744); // Green/Red
    final Color statusFg = Colors.white;

    // Fondo del chip de tiempo con mejor contraste y texto oscuro cuando es bonus (amarillo)
    final bool isBonus = showTime && gameState.lastAnswerTimeSeconds! < 5;
    final Color timeBg = isBonus ? const Color(0xFFFFD740) : const Color(0xFF7E57C2); // Amber A200 or Purple 600
    final Color timeFg = isBonus ? Colors.black.withOpacity(0.85) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          _ModernChip(
            label: isCorrect ? l10n.resultCorrect : l10n.resultIncorrect,
            icon: isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            bgColor: statusBg,
            fgColor: statusFg,
            borderColor: Colors.white.withOpacity(0.35),
          ),
          if (showTime)
            _ModernChip(
              label: isBonus
                  ? l10n.timeBonus
                  : l10n.timeElapsed(gameState.lastAnswerTimeSeconds!.toStringAsFixed(1)),
              icon: Icons.timer_rounded,
              bgColor: timeBg,
              fgColor: timeFg,
              // Para el amarillo usamos borde más oscuro para resaltar el texto
              borderColor: isBonus ? Colors.black.withOpacity(0.20) : Colors.white.withOpacity(0.35),
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
          onPressed: () =>
              ref.read(gameProvider(widget.selectedGeneration).notifier).submitAnswer(index),
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
            selectedGeneration: widget.selectedGeneration,
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
class _NextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color startColor;
  final Color endColor;
  final Color textColor;

  const _NextActionButton({
    required this.label,
    required this.onTap,
    required this.startColor,
    required this.endColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.45),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flecha mejorada: más nítida y con pequeño contorno para contraste
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black.withOpacity(0.20),
                    size: 24,
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Texto con mejor legibilidad y ligero tracking
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Chip moderno reutilizable con estilo limpio y vibrante
class _ModernChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
  final Color borderColor;

  const _ModernChip({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}