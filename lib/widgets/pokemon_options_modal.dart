import 'package:flutter/material.dart';

class PokemonOptionsModal extends StatefulWidget {
  const PokemonOptionsModal({
    Key? key,
    required this.baseColor,
    required this.secondaryColor,
    required this.initialShowShiny,
    required this.initialIsFavorite,
    required this.onlyLevelUp,
    required this.movesMethod,
    required this. movesSort,
    required this.onToggleShiny,
    required this.onToggleFavorite,
    required this. onChangeMovesMethod,
    required this.onChangeMovesSort,
    required this.onToggleOnlyLevelUp,
  }) : super(key: key);

  final Color baseColor;
  final Color secondaryColor;
  final bool initialShowShiny;
  final bool initialIsFavorite;
  final bool onlyLevelUp;
  final String movesMethod;
  final String movesSort;

  final VoidCallback onToggleShiny;
  final VoidCallback onToggleFavorite;
  final ValueChanged<String> onChangeMovesMethod;
  final ValueChanged<String> onChangeMovesSort;
  final VoidCallback onToggleOnlyLevelUp;

  @override
  State<PokemonOptionsModal> createState() => _PokemonOptionsModalState();
}

class _PokemonOptionsModalState extends State<PokemonOptionsModal>
    with SingleTickerProviderStateMixin {
  late bool _showShiny;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _showShiny = widget.initialShowShiny;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]). animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController. dispose();
    super.dispose();
  }

  void _handleToggleShiny() {
    setState(() {
      _showShiny = !_showShiny;
    });
    _animationController. forward(from: 0);
    widget.onToggleShiny();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius. circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, -6)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors. grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune, size: 22, color: widget.baseColor),
                const SizedBox(width: 8),
                const Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Shiny toggle card con animación
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border. all(
                      color: _showShiny
                          ? widget.baseColor. withOpacity(0.5 + (_glowAnimation.value * 0.5))
                          : Colors.grey.shade200,
                      width: _showShiny ? 2 : 1,
                    ),
                    boxShadow: _showShiny
                        ? [
                      BoxShadow(
                        color: widget.baseColor. withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 12 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Icon con animación de escala
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.baseColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _showShiny ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                            color: widget.baseColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Show Shiny',
                              style: TextStyle(
                                fontWeight: FontWeight. w700,
                                color: _showShiny ? widget.baseColor : Colors.black,
                              ),
                            ),
                            Text(
                              _showShiny ? 'Shiny sprite enabled ✨' : 'Toggle shiny sprite',
                              style: TextStyle(
                                fontSize: 12,
                                color: _showShiny
                                    ? widget.baseColor.withOpacity(0.7)
                                    : Colors. grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Switch animado con colores del Pokémon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _showShiny
                              ? [
                            BoxShadow(
                              color: widget.baseColor.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                              : null,
                        ),
                        child: Switch(
                          value: _showShiny,
                          activeColor: widget.baseColor,
                          activeTrackColor: widget.baseColor.withOpacity(0.5),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey. shade300,
                          splashRadius: 20,
                          onChanged: (_) => _handleToggleShiny(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Widget helper para AnimatedBuilder
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    Key? key,
    required Animation<double> animation,
    required this.builder,
    this. child,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}