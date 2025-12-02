import 'package:flutter/material.dart';

import '../../../../common/extensions/l10n_extension.dart';

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
