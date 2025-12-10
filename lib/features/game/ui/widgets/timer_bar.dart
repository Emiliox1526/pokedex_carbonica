import 'package:flutter/material.dart';
import '../../../../l10n/l10n_extension.dart';

/// TimerBar con colores vivos, tipografía mejorada y textos antiguos (compatibles).
/// - Diseño cápsula con gradiente vibrante.
/// - Transición de color suave según el tiempo restante.
/// - Usa los textos ya existentes en l10n: `timerLabel`.
/// - Mantiene la misma API pública.
class TimerBar extends StatelessWidget {
  final int remainingSeconds;
  final int maxSeconds;
  final double height;

  const TimerBar({
    super.key,
    required this.remainingSeconds,
    required this.maxSeconds,
    this.height = 16,
  });

  double get _progress {
    if (maxSeconds <= 0) return 0;
    return (remainingSeconds / maxSeconds).clamp(0.0, 1.0);
  }

  String _formatLabel(BuildContext context) {
    final secs = remainingSeconds.clamp(0, maxSeconds);
    final minutes = secs ~/ 60;
    final seconds = secs % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '$secs s';
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;

    // Paleta vibrante con gradiente según progreso: rojo -> naranja -> amarillo -> verde/cian
    final List<Color> gradientColors = _vibrantGradient(p);
    final Color accentText = _accentForProgress(p);
    final Color trackBg = Colors.white.withOpacity(0.10);

    final label = _formatLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Encabezado con icono + texto antiguo (timerLabel) + tiempo a la derecha
        Row(
          children: [
            Icon(Icons.timer_rounded, color: accentText, size: 20),
            const SizedBox(width: 8),
            Text(
              context.l10n.timerLabel,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: accentText.withOpacity(0.95),
                fontSize: p < 0.2 ? 16 : 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Barra tipo cápsula con gradiente vivo
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Fondo neutro del track
                Container(color: trackBg),

                // Progreso con gradiente vibrante
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth * p;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: w,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    );
                  },
                ),

                // Etiqueta centrada con dígitos monoespaciados
                Positioned.fill(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.98),
                        fontSize: p < 0.2 ? 13.5 : 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                      child: Text(label),
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

  // Color de texto/icónos según progreso (vibrante pero legible)
  Color _accentForProgress(double p) {
    if (p > 0.66) return const Color(0xFF00E5FF); // Cyan A200
    if (p > 0.33) return const Color(0xFFFFD54F); // Amber 300
    return const Color(0xFFFF5252); // Red A200
  }

  // Gradiente vivo según progreso
  List<Color> _vibrantGradient(double p) {
    if (p <= 0.33) {
      // Bajo tiempo: rojo → magenta
      return const [
        Color(0xFFFF1744), // Red A400
        Color(0xFFF50057), // Pink A400
      ];
    } else if (p <= 0.66) {
      // Medio: naranja → amarillo
      return const [
        Color(0xFFFF6F00), // Orange A700
        Color(0xFFFFD740), // Yellow A200
      ];
    } else {
      // Alto: verde → cian
      return const [
        Color(0xFF00C853), // Green A700
        Color(0xFF00E5FF), // Cyan A200
      ];
    }
  }
}