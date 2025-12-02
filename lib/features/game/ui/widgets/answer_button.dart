import 'package:flutter/material.dart';

import 'package:pokedex_carbonica/core/utils/string_utils.dart';

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

  const AnswerButton({
    super.key,
    required this.pokemonName,
    required this.state,
    this.onPressed,
    this.index = 0,
  });

  // Colores del tema
  static const Color _dexBurgundy = Color(0xFF7A0A16);
  static const Color _dexDeep = Color(0xFF4E0911);
  static const Color _correctGreen = Color(0xFF2E7D32);
  static const Color _incorrectRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
