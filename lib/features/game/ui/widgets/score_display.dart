import 'package:flutter/material.dart';
import 'package:pokedex_carbonica/l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';

/// ScoreDisplay centrado con estilo vibrante y moderno.
/// - Todo el contenido alineado y centrado para mejor equilibrio visual.
/// - Acentos de color vivos, tipografía clara y compacta.
/// - Mantiene la misma API pública.
class ScoreDisplay extends StatelessWidget {
  final int score;
  final int currentQuestion;
  final int totalQuestions;
  final int currentStreak;
  final int highScore;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.currentStreak,
    required this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Acentos vivos
    final bool isNewHighScore = score > highScore;
    final Color scoreAccent =
    isNewHighScore ? const Color(0xFFFFD740) /* Amber A200 */ : const Color(0xFF00E5FF) /* Cyan A200 */;
    final Color questionAccent = const Color(0xFFFF6F00) /* Orange A700 */;
    final bool hasStreak = currentStreak > 0;
    final bool hasMultiplier = currentStreak >= 3;
    final Color streakAccent = hasStreak ? const Color(0xFFFF5252) /* Red A200 */ : Colors.white54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ScoreItem(
            icon: Icons.stars_rounded,
            iconColor: scoreAccent,
            title: l10n.scoreLabel,
            value: score.toString(),
            centered: true,
            trailing: isNewHighScore
                ? const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.arrow_upward, color: Color(0xFFFFD740), size: 16),
            )
                : null,
            valueColor: isNewHighScore ? const Color(0xFFFFD740) : Colors.white,
          ),

          _ScoreItem(
            icon: Icons.help_outline_rounded,
            iconColor: questionAccent,
            title: l10n.questionLabel,
            value: '$currentQuestion/$totalQuestions',
            centered: true,
          ),

          _ScoreItem(
            icon: Icons.local_fire_department,
            iconColor: streakAccent,
            title: l10n.streakLabel,
            value: currentStreak.toString(),
            centered: true,
            valueColor: hasStreak ? const Color(0xFFFF5252) : Colors.white54,
            badge: hasMultiplier
                ? _Badge(text: l10n.streakMultiplier, color: const Color(0xFFFF7043))
                : null,
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool centered;
  final Widget? trailing;
  final Color? valueColor;
  final Widget? badge;

  const _ScoreItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.centered = false,
    this.trailing,
    this.valueColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = Colors.white.withOpacity(0.75);
    final Color valColor = valueColor ?? Colors.white;

    return SizedBox(
      width: 110, // ancho fijo para mantener equilibrio y centrado
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Encabezado con icono y título
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Valor grande y opcional trailing
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (badge != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: centered ? Alignment.center : Alignment.centerLeft,
              child: badge!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    // Etiqueta vibrante y compacta
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.60)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}