import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/game_achievement.dart';
import '../../domain/game_achievement_localizations.dart';

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
