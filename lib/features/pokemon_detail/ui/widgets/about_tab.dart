import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/pokemon_detail.dart';
import '../../domain/pokemon_ability.dart';
import '../../domain/pokemon_stat.dart';
import '../../../../core/utils/type_utils.dart';
import '../../../../core/utils/string_utils.dart';
import 'detail_card.dart';
import 'type_chip.dart';

/// The About tab displaying Pokemon information, stats, and type matchups.
class AboutTab extends StatelessWidget {
  /// The Pokemon detail data.
  final PokemonDetail detail;

  /// The primary color for the UI.
  final Color baseColor;

  /// The secondary color for the UI.
  final Color secondaryColor;

  const AboutTab({
    super.key,
    required this.detail,
    required this.baseColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final abilityNames = detail.visibleAbilities
        .map((a) => capitalize(a.name))
        .take(2)
        .toList();

    return DetailCard(
      background: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Center(
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Main info row: Weight | Height | Abilities
          _buildInfoRow(abilityNames),
          const SizedBox(height: 24),

          // Base Stats section
          const Center(
            child: Text(
              'Base Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Radar Chart
          if (detail.stats.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'No stats available',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 280,
                child: _RadarChart(
                  data: detail.stats.map((s) => s.value.toDouble()).toList(),
                  labels: detail.stats
                      .map((s) => getAbbreviatedStatName(s.name))
                      .toList(),
                  maxValue: 255,
                  baseColor: baseColor,
                  secondaryColor: secondaryColor,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Type Matchups section
          _buildTypeMatchups(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(List<String> abilityNames) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Weight column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.balance, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      '${detail.weightKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Weight',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Vertical divider
          Container(
            width: 1,
            color: Colors.grey.shade300,
          ),
          // Height column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.straighten, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      '${detail.heightMeters.toStringAsFixed(1)} m',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Height',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Vertical divider
          Container(
            width: 1,
            color: Colors.grey.shade300,
          ),
          // Abilities column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    for (final name in abilityNames)
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Abilities',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeMatchups() {
    final matchups = computeMatchups(detail.types);

    final hasWeaknesses =
        matchups.x4Weaknesses.isNotEmpty || matchups.x2Weaknesses.isNotEmpty;
    final hasResistances = matchups.x05Resistances.isNotEmpty ||
        matchups.x025Resistances.isNotEmpty ||
        matchups.immunities.isNotEmpty;

    if (!hasWeaknesses && !hasResistances) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 22, color: baseColor),
            const SizedBox(width: 8),
            const Text(
              'Type Matchups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              if (hasWeaknesses)
                _buildMatchupCard(
                  title: 'Weaknesses',
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.red.shade400,
                  categories: [
                    MapEntry('×4 Super Effective', matchups.x4Weaknesses),
                    MapEntry('×2 Effective', matchups.x2Weaknesses),
                  ],
                ),
              if (hasResistances)
                _buildMatchupCard(
                  title: 'Resistances',
                  icon: Icons.shield_rounded,
                  iconColor: Colors.green.shade400,
                  categories: [
                    MapEntry('×0.5 Resistant', matchups.x05Resistances),
                    MapEntry('×0.25 Very Resistant', matchups.x025Resistances),
                    MapEntry('×0 Immune', matchups.immunities),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchupCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<MapEntry<String, List<String>>> categories,
  }) {
    final nonEmptyCategories =
        categories.where((c) => c.value.isNotEmpty).toList();
    if (nonEmptyCategories.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...nonEmptyCategories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children:
                        category.value.map((t) => TypeChipDetail(typeName: t)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Radar chart implementation
class _RadarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final double maxValue;
  final Color baseColor;
  final Color secondaryColor;

  const _RadarChart({
    required this.data,
    required this.labels,
    required this.maxValue,
    required this.baseColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarPainter(
        data: data,
        labels: labels,
        maxValue: maxValue,
        baseColor: baseColor,
        secondaryColor: secondaryColor,
      ),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _RadarPainter extends CustomPainter {
  static const double _labelOffsetAdjustment = 4.0;
  static const double _topAngleThreshold = math.pi / 4;
  static const double _bottomAngleThreshold = 3 * math.pi / 4;
  static const double _radiusScale = 0.72;
  static const double _labelRadiusOffset = 30.0;
  static const double _vertexCircleRadius = 4.0;
  static const double _centerCircleRadius = 5.0;

  final List<double> data;
  final List<String> labels;
  final double maxValue;
  final Color baseColor;
  final Color secondaryColor;

  const _RadarPainter({
    required this.data,
    required this.labels,
    required this.maxValue,
    required this.baseColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) * _radiusScale;
    final center = Offset(cx, cy);
    final n = math.max(3, data.length);

    // Background circle
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Data points
    final List<Offset> dataPoints = [];
    for (int i = 0; i < n; i++) {
      final double normalized =
          (i < data.length) ? (data[i].clamp(0.0, maxValue) / maxValue) : 0.0;
      final r = radius * normalized;
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      dataPoints.add(Offset(x, y));
    }

    // Curved polygon path
    final Path pathData = Path()..moveTo(dataPoints[0].dx, dataPoints[0].dy);
    const double inwardFactor = 0.12;

    for (int i = 0; i < dataPoints.length; i++) {
      final current = dataPoints[i];
      final next = dataPoints[(i + 1) % dataPoints.length];
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      final control = Offset(
        mid.dx + (center.dx - mid.dx) * inwardFactor,
        mid.dy + (center.dy - mid.dy) * inwardFactor,
      );
      pathData.quadraticBezierTo(control.dx, control.dy, next.dx, next.dy);
    }
    pathData.close();

    // Vivid gradient colors
    final vividBase = HSLColor.fromColor(baseColor)
        .withSaturation(
            (HSLColor.fromColor(baseColor).saturation * 1.4).clamp(0.0, 1.0))
        .withLightness(
            (HSLColor.fromColor(baseColor).lightness * 1.15).clamp(0.0, 1.0))
        .toColor();

    final vividSecondary = HSLColor.fromColor(secondaryColor)
        .withSaturation(
            (HSLColor.fromColor(secondaryColor).saturation * 1.4).clamp(0.0, 1.0))
        .withLightness(
            (HSLColor.fromColor(secondaryColor).lightness * 1.15).clamp(0.0, 1.0))
        .toColor();

    final vividMiddle = Color.fromARGB(
      255,
      ((vividBase.red * 0.5) + (vividSecondary.red * 0.5)).toInt(),
      ((vividBase.green * 0.5) + (vividSecondary.green * 0.5)).toInt(),
      ((vividBase.blue * 0.5) + (vividSecondary.blue * 0.5)).toInt(),
    );

    final paintGradientFill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx - radius * 0.35, cy - radius * 0.35),
        Offset(cx + radius * 0.35, cy + radius * 0.35),
        [
          vividBase.withOpacity(0.98),
          vividMiddle.withOpacity(0.96),
          vividSecondary.withOpacity(0.98),
        ],
        [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.fill;

    // Draw polygon with gradient
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPath(
      pathData,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      pathData,
      paintGradientFill..blendMode = BlendMode.srcIn,
    );
    canvas.restore();

    // Polygon border
    final Paint paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawPath(pathData, paintStroke);

    // Grid lines
    final Paint gridPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Paint radialPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const int rings = 6;
    for (int r = 1; r <= rings; r++) {
      canvas.drawCircle(center, radius * (r / rings), gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), radialPaint);
    }

    // Data points
    final Paint paintVertex = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    for (final p in dataPoints) {
      canvas.drawCircle(p, _vertexCircleRadius, paintVertex);
    }

    // Center circle
    final Paint centerStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, _centerCircleRadius * 1.5, centerStroke);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final angle = (math.pi * 2 / n) * i - math.pi / 2;
      final double labelRadius = radius + _labelRadiusOffset;
      final lx = cx + labelRadius * math.cos(angle);
      final ly = cy + labelRadius * math.sin(angle);
      final String label = labels[i];
      final double value = (i < data.length) ? data[i] : 0;
      final String fullText = "$label  ${value.toInt()}";

      textPainter.text = TextSpan(
        text: fullText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      );
      textPainter.layout();

      double dx = lx - textPainter.width / 2;
      double dy = ly - textPainter.height / 2;

      if (angle > -_topAngleThreshold && angle < _topAngleThreshold) {
        dy -= _labelOffsetAdjustment;
      } else if (angle > _bottomAngleThreshold ||
          angle < -_bottomAngleThreshold) {
        dy += _labelOffsetAdjustment;
      }

      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.labels != labels ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.secondaryColor != secondaryColor;
}
