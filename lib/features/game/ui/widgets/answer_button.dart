import 'package:flutter/material.dart';
import 'package:pokedex_carbonica/core/utils/string_utils.dart';

/// Estado del botón de respuesta.
enum AnswerButtonState {
  idle,
  correct,
  incorrect,
  revealedCorrect,
  disabled,
}

/// Botón de opción de respuesta (diseño clean y vibrante).
/// Mantiene la misma API pública.
class AnswerButton extends StatelessWidget {
  final String pokemonName;
  final AnswerButtonState state;
  final VoidCallback? onPressed;
  final int index;
  final String? semanticsLabel;

  const AnswerButton({
    super.key,
    required this.pokemonName,
    required this.state,
    this.onPressed,
    this.index = 0,
    this.semanticsLabel,
  });

  // Paleta vibrante
  static const Color _baseBurgundy = Color(0xFF7A0A16);
  static const Color _baseDeep = Color(0xFF4E0911);
  static const Color _green = Color(0xFF00C853); // Green A700
  static const Color _red = Color(0xFFFF1744); // Red A400
  static const Color _orange = Color(0xFFFF6F00); // Orange A700
  static const Color _cyan = Color(0xFF00E5FF); // Cyan A200

  @override
  Widget build(BuildContext context) {
    final bool enabled = state == AnswerButtonState.idle;
    final List<Color> gradient = _getGradientColors();
    final Color borderColor = _getBorderColor();
    final Color labelColor = _getLabelColor();
    final IconData leadingIcon = _leadingIcon();
    final Color leadingColor = _leadingColor();

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel ?? capitalize(pokemonName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 7),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: const BoxConstraints(minHeight: 54),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                // Gradiente vibrante y limpio (flat, sin sombras pesadas)
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: gradient,
                ),
                border: Border.all(color: borderColor, width: 1.4),
              ),
              child: Row(
                children: [
                  // Icono de estado
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      leadingIcon,
                      key: ValueKey(state),
                      color: leadingColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nombre del Pokémon
                  Expanded(
                    child: Text(
                      capitalize(pokemonName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Indicador discreto cuando está idle
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state == AnswerButtonState.idle
                        ? Icon(
                      Icons.chevron_right_rounded,
                      key: const ValueKey('chev'),
                      color: Colors.white.withOpacity(0.85),
                      size: 22,
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _leadingIcon() {
    switch (state) {
      case AnswerButtonState.correct:
        return Icons.check_circle_rounded;
      case AnswerButtonState.incorrect:
        return Icons.cancel_rounded;
      case AnswerButtonState.revealedCorrect:
        return Icons.check_circle_outline_rounded;
      case AnswerButtonState.idle:
      case AnswerButtonState.disabled:
        return Icons.catching_pokemon;
    }
  }

  Color _leadingColor() {
    switch (state) {
      case AnswerButtonState.correct:
        return Colors.white;
      case AnswerButtonState.incorrect:
        return Colors.white;
      case AnswerButtonState.revealedCorrect:
        return Colors.white;
      case AnswerButtonState.idle:
        return Colors.white.withOpacity(0.9);
      case AnswerButtonState.disabled:
        return Colors.white70;
    }
  }

  List<Color> _getGradientColors() {
    switch (state) {
      case AnswerButtonState.correct:
      // Verde → Cian (vibrante)
        return [_green, _cyan];
      case AnswerButtonState.incorrect:
      // Rojo → Naranja (vibrante)
        return [_red, _orange];
      case AnswerButtonState.revealedCorrect:
      // Verde suave → Cian suave
        return [_green.withOpacity(0.75), _cyan.withOpacity(0.7)];
      case AnswerButtonState.disabled:
      // Fondo tenue (clean)
        return [
          _baseDeep.withOpacity(0.45),
          _baseBurgundy.withOpacity(0.30),
        ];
      case AnswerButtonState.idle:
      // Burgundy profundo → Burgundy más claro (sutil pero vivo)
        return [
          _baseDeep.withOpacity(0.95),
          _baseBurgundy.withOpacity(0.85),
        ];
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case AnswerButtonState.correct:
      case AnswerButtonState.incorrect:
        return Colors.white.withOpacity(0.95);
      case AnswerButtonState.revealedCorrect:
        return Colors.white70;
      case AnswerButtonState.disabled:
        return Colors.white24;
      case AnswerButtonState.idle:
        return Colors.white38;
    }
  }

  Color _getLabelColor() {
    switch (state) {
      case AnswerButtonState.correct:
        return Colors.white;
      case AnswerButtonState.incorrect:
        return Colors.white;
      case AnswerButtonState.revealedCorrect:
        return Colors.white;
      case AnswerButtonState.disabled:
        return Colors.white60;
      case AnswerButtonState.idle:
        return Colors.white;
    }
  }
}