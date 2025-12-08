/// UI widgets for this feature.
///
/// Contains all reusable UI components and widgets.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pokedex_carbonica/gen/l10n/app_localizations.dart';
import 'package:pokedex_carbonica/core/utils/utils.dart';
import 'package:pokedex_carbonica/common/widgets/type_chip.dart';
import '../domain/model.dart';
import 'controller.dart';


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


/// Modal que muestra un logro recién desbloqueado.
///
/// Aparece con animaciones cuando el usuario desbloquea un nuevo logro.
class AchievementUnlockModal extends StatefulWidget {
  /// El logro desbloqueado.
  final GameAchievement achievement;

  /// Callback cuando se cierra el modal.
  final VoidCallback? onClose;

  const AchievementUnlockModal({
    super.key,
    required this.achievement,
    this.onClose,
  });

  /// Muestra el modal de logro desbloqueado.
  static Future<void> show(
    BuildContext context,
    GameAchievement achievement, {
    VoidCallback? onClose,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppLocalizations.of(context)!.cancel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AchievementUnlockModal(
          achievement: achievement,
          onClose: onClose,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AchievementUnlockModal> createState() => _AchievementUnlockModalState();
}

class _AchievementUnlockModalState extends State<AchievementUnlockModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.6),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final achievementName = widget.achievement.localizedName(l10n);
    final achievementDescription =
        widget.achievement.localizedDescription(l10n);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7A0A16),
                Color(0xFF4E0911),
              ],
            ),
            border: Border.all(color: Colors.white54, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                l10n.achievementUnlockTitle,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),

              // Icono del logro con animación
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 30 * _glowAnimation.value,
                          spreadRadius: 10 * _glowAnimation.value,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: _iconScaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.amber,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.achievement.icon,
                            style: const TextStyle(fontSize: 56),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Nombre del logro
              Text(
                achievementName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                achievementDescription,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Botón de cerrar
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onClose?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.great,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// Estado del botón de respuesta.
enum AnswerButtonState {
  /// Estado normal, esperando selección.
  idle,

  /// Seleccionado como respuesta correcta.
  correct,

  /// Seleccionado como respuesta incorrecta.
  incorrect,

  /// Es la respuesta correcta pero el usuario eligió otra.
  revealedCorrect,

  /// Deshabilitado mientras se muestra el resultado.
  disabled,
}

/// Botón de opción de respuesta para el juego.
///
/// Muestra el nombre del Pokémon y cambia de color según el estado.
class AnswerButton extends StatelessWidget {
  /// Nombre del Pokémon a mostrar.
  final String pokemonName;

  /// Estado actual del botón.
  final AnswerButtonState state;

  /// Callback cuando se presiona el botón.
  final VoidCallback? onPressed;

  /// Índice del botón (para animaciones escalonadas).
  final int index;

  /// Etiqueta de accesibilidad opcional.
  final String? semanticsLabel;

  const AnswerButton({
    super.key,
    required this.pokemonName,
    required this.state,
    this.onPressed,
    this.index = 0,
    this.semanticsLabel,
  });

  // Colores del tema
  static const Color _dexBurgundy = Color(0xFF7A0A16);
  static const Color _dexDeep = Color(0xFF4E0911);
  static const Color _correctGreen = Color(0xFF2E7D32);
  static const Color _incorrectRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: state == AnswerButtonState.idle,
      label: semanticsLabel ?? capitalize(pokemonName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: state == AnswerButtonState.idle ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              constraints: const BoxConstraints(minHeight: 56),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(),
                ),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getShadowColor(),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildStateIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      capitalize(pokemonName),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state == AnswerButtonState.idle)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateIcon() {
    IconData icon;
    Color iconColor;

    switch (state) {
      case AnswerButtonState.correct:
        icon = Icons.check_circle;
        iconColor = Colors.white;
        break;
      case AnswerButtonState.incorrect:
        icon = Icons.cancel;
        iconColor = Colors.white;
        break;
      case AnswerButtonState.revealedCorrect:
        icon = Icons.check_circle_outline;
        iconColor = Colors.white;
        break;
      case AnswerButtonState.idle:
      case AnswerButtonState.disabled:
        icon = Icons.catching_pokemon;
        iconColor = Colors.white70;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Icon(
        icon,
        key: ValueKey(state),
        color: iconColor,
        size: 28,
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (state) {
      case AnswerButtonState.correct:
        return [_correctGreen, _correctGreen.withOpacity(0.8)];
      case AnswerButtonState.incorrect:
        return [_incorrectRed, _incorrectRed.withOpacity(0.8)];
      case AnswerButtonState.revealedCorrect:
        return [_correctGreen.withOpacity(0.7), _correctGreen.withOpacity(0.5)];
      case AnswerButtonState.disabled:
        return [_dexDeep.withOpacity(0.5), _dexBurgundy.withOpacity(0.3)];
      case AnswerButtonState.idle:
        return [_dexDeep, _dexBurgundy];
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case AnswerButtonState.correct:
        return Colors.white;
      case AnswerButtonState.incorrect:
        return Colors.white;
      case AnswerButtonState.revealedCorrect:
        return Colors.white70;
      case AnswerButtonState.disabled:
        return Colors.white24;
      case AnswerButtonState.idle:
        return Colors.white54;
    }
  }

  Color _getShadowColor() {
    switch (state) {
      case AnswerButtonState.correct:
        return _correctGreen.withOpacity(0.5);
      case AnswerButtonState.incorrect:
        return _incorrectRed.withOpacity(0.5);
      default:
        return Colors.black26;
    }
  }
}


/// Widget que muestra la silueta de un Pokémon.
///
/// Usa ColorFiltered para mostrar la imagen en negro (silueta)
/// y puede revelar la imagen original con una animación.
class PokemonSilhouette extends StatelessWidget {
  /// URL de la imagen del Pokémon.
  final String? imageUrl;

  /// Si debe mostrar la silueta (true) o la imagen original (false).
  final bool showSilhouette;

  /// Tamaño del widget.
  final double size;

  /// Duración de la animación de revelación.
  final Duration animationDuration;

  const PokemonSilhouette({
    super.key,
    required this.imageUrl,
    this.showSilhouette = true,
    this.size = 200,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return _buildPlaceholder();
    }

    return AnimatedSwitcher(
      duration: animationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      child: showSilhouette
          ? _buildSilhouette()
          : _buildRevealedImage(),
    );
  }

  Widget _buildSilhouette() {
    return ColorFiltered(
      key: const ValueKey('silhouette'),
      colorFilter: const ColorFilter.mode(
        Colors.black,
        BlendMode.srcIn,
      ),
      child: _buildImage(),
    );
  }

  Widget _buildRevealedImage() {
    return Container(
      key: const ValueKey('revealed'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => _buildLoadingIndicator(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.catching_pokemon,
          size: 80,
          color: Colors.white30,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Icon(
        Icons.error_outline,
        size: 60,
        color: Colors.white54,
      ),
    );
  }
}


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



/// Barra de progreso del tiempo restante.
///
/// Muestra visualmente el tiempo restante para responder
/// la pregunta actual con un gradiente animado.
class TimerBar extends StatelessWidget {
  /// Tiempo restante en segundos.
  final int remainingSeconds;

  /// Tiempo máximo en segundos.
  final int maxSeconds;

  /// Altura de la barra.
  final double height;

  const TimerBar({
    super.key,
    required this.remainingSeconds,
    required this.maxSeconds,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = maxSeconds > 0
        ? (remainingSeconds / maxSeconds).clamp(0.0, 1.0)
        : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Texto del tiempo
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: _getTimerColor(progress),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.timerLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _getTimerColor(progress),
                  fontSize: progress < 0.3 ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
                child: Text('${remainingSeconds}s'),
              ),
            ],
          ),
        ),
        
        // Barra de progreso
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: Colors.white.withOpacity(0.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Stack(
              children: [
                // Fondo animado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width * progress * 0.85,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: _getGradientColors(progress),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getTimerColor(progress).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                
                // Efecto de brillo
                if (progress > 0.1)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTimerColor(double progress) {
    if (progress > 0.5) {
      return const Color(0xFF4CAF50); // Verde
    } else if (progress > 0.25) {
      return const Color(0xFFFFA726); // Naranja
    } else {
      return const Color(0xFFEF5350); // Rojo
    }
  }

  List<Color> _getGradientColors(double progress) {
    if (progress > 0.5) {
      return [
        const Color(0xFF66BB6A),
        const Color(0xFF4CAF50),
      ];
    } else if (progress > 0.25) {
      return [
        const Color(0xFFFFB74D),
        const Color(0xFFFFA726),
      ];
    } else {
      return [
        const Color(0xFFEF5350),
        const Color(0xFFE53935),
      ];
    }
  }
}

