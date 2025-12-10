import 'dart:math';
import 'package:flutter/material.dart';

class SplashInteractive extends StatefulWidget {
  final Widget nextScreen;

  const SplashInteractive({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashInteractive> createState() => _SplashInteractiveState();
}

class _SplashInteractiveState extends State<SplashInteractive>
    with TickerProviderStateMixin {
  late AnimationController pokeballController;
  late Animation<double> pokeballScale;
  late Animation<double> pokeballOpacity;

  late AnimationController panelsController;
  late Animation<double> topPanelOffset;
  late Animation<double> bottomPanelOffset;

  bool opened = false;
  bool showOverlay = true; // controla el overlay (paneles + pokebola)

  @override
  void initState() {
    super.initState();

    // Pokébola: escala + opacidad
    pokeballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    pokeballScale = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: pokeballController,
        curve: Curves.easeInOut,
      ),
    );

    pokeballOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: pokeballController,
        curve: Curves.easeOut,
      ),
    );

    // Paneles que se abren hacia arriba/abajo
    panelsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    topPanelOffset = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(
        parent: panelsController,
        curve: Curves.easeInOut,
      ),
    );

    bottomPanelOffset = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: panelsController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    pokeballController.dispose();
    panelsController.dispose();
    super.dispose();
  }

  void startAnimation() async {
    if (opened) return;
    opened = true;

    // Pokébola + paneles al mismo tiempo
    await Future.wait([
      pokeballController.forward(),
      panelsController.forward(),
    ]);

    if (!mounted) return;

    // En vez de Navigator, hacemos fade-out del overlay
    setState(() {
      showOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // El fondo real lo pone nextScreen, este color casi ni se ve
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ---------- PANTALLA REAL AL FONDO ----------
          Positioned.fill(
            child: IgnorePointer(
              // Mientras haya overlay, bloqueamos interacción con la app
              ignoring: showOverlay,
              child: widget.nextScreen,
            ),
          ),

          // ---------- OVERLAY (paneles + pokebola + filtro) ----------
          if (showOverlay)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: _buildOverlay(size),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlay(Size size) {
    return Stack(
      children: [
        // Capa oscura para que se vea "detrás"
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.35),
          ),
        ),

        // ---------- PANEL SUPERIOR ----------
        AnimatedBuilder(
          animation: panelsController,
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, topPanelOffset.value * size.height),
              child: Container(
                height: size.height / 2,
                width: size.width,
                color: Colors.white,
              ),
            );
          },
        ),

        // ---------- PANEL INFERIOR ----------
        AnimatedBuilder(
          animation: panelsController,
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, bottomPanelOffset.value * size.height),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height / 2,
                  width: size.width,
                  color: Colors.red.shade600,
                ),
              ),
            );
          },
        ),

        // ---------- POKÉBOLA (ESCALA + FADE OUT) ----------
        Center(
          child: GestureDetector(
            onTap: startAnimation,
            child: AnimatedBuilder(
              animation: pokeballController,
              builder: (_, child) {
                return Opacity(
                  opacity: pokeballOpacity.value,
                  child: Transform.scale(
                    scale: pokeballScale.value,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: PokeballPainter(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// - Franja central y círculo central
class PokeballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final outerRect = Rect.fromCircle(center: center, radius: radius);

    // ---------- MITAD SUPERIOR (ROJA) ----------
    final topPaint = Paint()
      ..color = Colors.red.shade600
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      outerRect,
      -pi, // inicia arriba
      pi, // cubre la mitad superior
      true,
      topPaint,
    );

    // ---------- MITAD INFERIOR (BLANCA) ----------
    final bottomPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      outerRect,
      0, // inicia abajo
      pi, // cubre la mitad inferior
      true,
      bottomPaint,
    );

    // ---------- BORDE NEGRO EXTERNO ----------
    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.15;

    canvas.drawCircle(center, radius * 0.4, borderPaint);
    canvas.drawCircle(center, radius * 1.05, borderPaint);

    // ---------- CÍRCULO CENTRAL ----------
    final centerInnerRadius = radius * 0.35;

    final centerInnerPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, centerInnerRadius, centerInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
