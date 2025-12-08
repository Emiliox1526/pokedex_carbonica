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


/// A circular button widget with an icon.
///
/// Used for back buttons and other circular action buttons.
class CircleButton extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The icon color.
  final Color iconColor;

  /// The icon size.
  final double iconSize;

  /// The button size.
  final double size;

  const CircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.iconSize = 20,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withOpacity(.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}


/// A card container for detail section content.
class DetailCard extends StatelessWidget {
  /// The background color of the card.
  final Color background;

  /// The content of the card.
  final Widget child;

  const DetailCard({
    super.key,
    required this.background,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: child,
      ),
    );
  }
}

/// A horizontal stat bar widget.
class StatBar extends StatelessWidget {
  /// The stat label.
  final String label;

  /// The stat value.
  final int value;

  /// The primary color for the bar.
  final Color primaryColor;

  /// The secondary color for the gradient.
  final Color secondaryColor;

  /// Maximum possible value (default 255 for Pokemon stats).
  final int maxValue;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.primaryColor,
    required this.secondaryColor,
    this.maxValue = 255,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              value.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// An error banner widget with retry option.
class ErrorBanner extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Callback for retry action.
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          if (onRetry != null)...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade700,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}



/// Header widget for the Pokemon detail screen.
///
/// Displays the back button, Pokemon name, ID, favorite and share buttons.
class DetailHeader extends StatelessWidget {
  /// The Pokemon's display name.
  final String pokemonName;

  /// The Pokemon's formatted ID (e.g., '#001').
  final String idLabel;

  /// Whether this Pokemon is a favorite.
  final bool isFavorite;

  /// Callback when the back button is pressed.
  final VoidCallback onBack;

  /// Callback when the favorite button is pressed.
  final VoidCallback onToggleFavorite;

  /// Callback when the share button is pressed.
  final VoidCallback? onShare;

  /// Whether a share action is currently running.
  final bool isSharing;

  /// The image URL for sharing.
  final String? imageUrl;

  const DetailHeader({
    super.key,
    required this.pokemonName,
    required this.idLabel,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
    this.onShare,
    this.imageUrl,
    this.isSharing = false,
  });

  void _handleShare(BuildContext context) {
    if (onShare != null) {
      onShare!();
    } else {
      final txt = '$pokemonName $idLabel\n${imageUrl ?? ''}';
      Clipboard.setData(ClipboardData(text: txt));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied Pokémon info to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleButton(
          icon: Icons.arrow_back,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            pokemonName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
          ),
        ),
        IconButton(
          onPressed: onToggleFavorite,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isFavorite
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    key: ValueKey('fav_on'),
                  )
                : const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    key: ValueKey('fav_off'),
                  ),
          ),
        ),
        IconButton(
          onPressed: isSharing ? null : () => _handleShare(context),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSharing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.share, color: Colors.white),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          idLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}




/// Widget displaying the Pokemon image with Hero animation and type chips.
class DetailImageSection extends StatelessWidget {
  /// The Pokemon's ID for fallback image URL.
  final int pokemonId;

  /// URL to the default sprite.
  final String? defaultImageUrl;

  /// URL to the shiny sprite.
  final String? shinyImageUrl;

  /// Whether to show the shiny sprite.
  final bool showShiny;

  /// The primary type name.
  final String primaryType;

  /// The secondary type name.
  final String secondaryType;

  /// The primary type color.
  final Color primaryColor;

  /// The secondary type color.
  final Color secondaryColor;

  /// The Hero tag for animation.
  final String heroTag;

  const DetailImageSection({
    super.key,
    required this.pokemonId,
    this.defaultImageUrl,
    this.shinyImageUrl,
    required this.showShiny,
    required this.primaryType,
    required this.secondaryType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.heroTag,
  });

  String _artworkUrlForId(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth.isFinite &&
                      constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width - 32;
              final imageDiameter =
                  math.max(100.0, math.min(360.0, availableWidth * 0.48));
              final scale = imageDiameter / 220.0;
              final chipOffset = imageDiameter * 0.45;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Pokemon image
                  Hero(
                    tag: heroTag,
                    child: Container(
                      width: imageDiameter,
                      height: imageDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: showShiny
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Image.network(
                            defaultImageUrl ?? _artworkUrlForId(pokemonId),
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Image.network(
                              _artworkUrlForId(pokemonId),
                              fit: BoxFit.contain,
                            ),
                          ),
                          secondChild: Image.network(
                            shinyImageUrl ??
                                defaultImageUrl ??
                                _artworkUrlForId(pokemonId),
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Image.network(
                              _artworkUrlForId(pokemonId),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Left type chip
                  Positioned(
                    left: -chipOffset,
                    child: TypeColumn(
                      icon: iconForType(primaryType),
                      color: primaryColor,
                      label: primaryType,
                      scale: scale,
                    ),
                  ),

                  // Right type chip
                  Positioned(
                    right: -chipOffset,
                    child: TypeColumn(
                      icon: iconForType(secondaryType),
                      color: secondaryColor,
                      label: secondaryType,
                      scale: scale,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


/// Tab bar widget for navigating between detail sections.
class DetailTabBar extends StatelessWidget {
  /// The currently selected tab index.
  final int selectedIndex;

  /// The primary color for selected state.
  final Color primaryColor;

  /// The secondary color for some tabs.
  final Color secondaryColor;

  /// Callback when a tab is selected.
  final ValueChanged<int> onChanged;

  /// Callback when the options button is pressed.
  final VoidCallback? onOptionsPressed;

  const DetailTabBar({
    super.key,
    required this.selectedIndex,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onChanged,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'About',
              icon: Icons.info_outline,
              color: primaryColor,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Evolution',
              icon: Icons.auto_graph,
              color: primaryColor,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Moves',
              icon: Icons.blur_circular,
              color: secondaryColor,
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Options',
              icon: Icons.tune,
              color: secondaryColor,
              selected: false,
              onTap: onOptionsPressed ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color ringColor = selected ? color : Colors.grey.shade300;
    final Color iconBg = Colors.grey.shade900;
    final Color textColor = selected ? color : Colors.grey.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ringColor,
                width: 4,
              ),
            ),
            child: Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barrel file for Pokemon detail presentation widgets.
export 'circle_button.dart';
export 'type_chip.dart';
export 'detail_card.dart';
export 'detail_header.dart';
export 'detail_image_section.dart';
export 'detail_tab_bar.dart';
export 'about_tab.dart';
export 'evolution_tab.dart';
export 'moves_tab.dart';
export 'pokemon_options_modal.dart';



/// The Evolution tab displaying the Pokemon's evolution chain.
class EvolutionTab extends StatelessWidget {
  /// The evolution chain data.
  final List<PokemonEvolution> evolutionChain;

  /// The species name for fallback query.
  final String speciesName;

  const EvolutionTab({
    super.key,
    required this.evolutionChain,
    required this.speciesName,
  });

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      background: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Evolution Chart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (evolutionChain.isNotEmpty)
            _buildEvolutionChain(evolutionChain)
          else
            _buildFallbackQuery(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEvolutionChain(List<PokemonEvolution> chain) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Column(
        children: [
          for (var i = 0; i < chain.length; i++)...[
            _EvolutionNode(
              id: chain[i].speciesId,
              name: chain[i].name,
              types: chain[i].types,
            ),
            if (i < chain.length - 1)
              _EvolutionTransition(
                minLevel: chain[i + 1].minLevel,
                triggerName: chain[i + 1].trigger,
                itemName: chain[i + 1].item,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackQuery(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Query(
        options: QueryOptions(
          document: gql(_evolutionBySpeciesQuery),
          variables: {'name': speciesName.toLowerCase()},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (result.hasException) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'Error loading evolution data',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            );
          }

          final speciesList =
              (result.data?['pokemon_v2_pokemonspecies'] as List?) ?? [];
          if (speciesList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 64.0),
              child: Center(child: Text('No evolution data available')),
            );
          }

          final chain = (speciesList.first['pokemon_v2_evolutionchain']
                  ?['pokemon_v2_pokemonspecies'] as List?) ??
              [];
          final chainItems = chain.cast<Map<String, dynamic>>();

          if (chainItems.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 64.0),
              child: Center(child: Text('No evolution data available')),
            );
          }

          return Column(
            children: [
              for (var i = 0; i < chainItems.length; i++)...[
                _EvolutionNode(
                  id: (chainItems[i]['id'] as int?) ?? 0,
                  name: (chainItems[i]['name'] as String?) ?? '',
                  types: _extractTypesFromSpecies(chainItems[i]),
                ),
                if (i < chainItems.length - 1)
                  _EvolutionTransition(
                    minLevel: _extractEvolutionData(chainItems[i + 1])['min_level'] as int?,
                    triggerName:
                        _extractEvolutionData(chainItems[i + 1])['trigger'] as String?,
                    itemName: _extractEvolutionData(chainItems[i + 1])['item'] as String?,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<String> _extractTypesFromSpecies(Map<String, dynamic> species) {
    final pokemons = (species['pokemon_v2_pokemons'] as List?) ?? [];
    if (pokemons.isEmpty) return ['normal'];
    final pokemonTypes =
        (pokemons.first['pokemon_v2_pokemontypes'] as List?) ?? [];
    final types = pokemonTypes
       .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
       .where((t) => t.isNotEmpty)
       .toList();
    return types.isNotEmpty ? types : ['normal'];
  }

  Map<String, dynamic> _extractEvolutionData(Map<String, dynamic> nextSpecies) {
    final evolutions =
        (nextSpecies['pokemon_v2_pokemonevolutions'] as List?) ?? [];
    if (evolutions.isEmpty) {
      return {'min_level': null, 'trigger': null, 'item': null};
    }
    final evo = evolutions.first as Map<String, dynamic>;
    return {
      'min_level': evo['min_level'] as int?,
      'trigger': evo['pokemon_v2_evolutiontrigger']?['name'] as String?,
      'item': evo['pokemon_v2_item']?['name'] as String?,
    };
  }
}

// GraphQL query for evolution chain by species name
const String _evolutionBySpeciesQuery = r'''
  query GetEvolutionBySpeciesName($name: String!) {
    pokemon_v2_pokemonspecies(where: {name: {_eq: $name}}) {
      id
      name
      pokemon_v2_evolutionchain {
        id
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemonevolutions {
            min_level
            pokemon_v2_evolutiontrigger {
              name
            }
            pokemon_v2_item {
              name
            }
          }
          pokemon_v2_pokemons(limit: 1) {
            pokemon_v2_pokemontypes {
              pokemon_v2_type {
                name
              }
            }
          }
        }
      }
    }
  }
''';

class _EvolutionNode extends StatelessWidget {
  final int id;
  final String name;
  final List<String> types;

  const _EvolutionNode({
    required this.id,
    required this.name,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name
       .replaceAll('-', ' ')
       .split(' ')
       .map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w)
       .join(' ');

    final artworkUrl = artworkUrlForId(id);
    final primaryType = types.isNotEmpty ? types.first : 'normal';
    final secondaryType = types.length > 1 ? types[1] : primaryType;
    final primaryColor = typeColor[primaryType] ?? typeColor['normal']!;
    final secondaryColor = typeColor[secondaryType] ?? typeColor['normal']!;

    return Column(
      children: [
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '#${id.toString().padLeft(3, "0")}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(130),
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(130),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.network(
                    artworkUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -45,
              top: 50,
              child: TypeIconCircle(type: primaryType),
            ),
            Positioned(
              right: -45,
              top: 50,
              child: TypeIconCircle(type: secondaryType),
            ),
          ],
        ),
      ],
    );
  }
}

class _EvolutionTransition extends StatelessWidget {
  final int? minLevel;
  final String? triggerName;
  final String? itemName;

  const _EvolutionTransition({
    this.minLevel,
    this.triggerName,
    this.itemName,
  });

  String _getTriggerLabel(String? trigger) {
    if (trigger == null) return '—';
    switch (trigger) {
      case 'level-up':
        return 'Lv.';
      case 'trade':
        return 'Trade';
      case 'use-item':
        return 'Item';
      case 'shed':
        return 'Shed';
      default:
        return trigger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUseItem = triggerName == 'use-item' && itemName != null;
    final isLevelUp =
        triggerName == 'level-up' || (minLevel != null && minLevel! > 0);

    return Column(
      children: [
        const SizedBox(height: 4),
        Transform.translate(
          offset: const Offset(0, -20),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade600,
              border: Border.all(color: Colors.white, width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isUseItem
                  ? ClipOval(
                      child: Image.network(
                        getItemSpriteUrl(itemName!),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Text(
                      isLevelUp && minLevel != null
                          ? 'Lv.${minLevel!}'
                          : _getTriggerLabel(triggerName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Transform.translate(
          offset: const Offset(0, -30),
          child: Icon(
            Icons.arrow_downward,
            size: 42,
            color: Colors.red.shade600,
            shadows: [
              Shadow(
                color: Colors.red.shade600,
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -30),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}



/// The Moves tab displaying the Pokemon's learnable moves with filtering and pagination.
class MovesTab extends StatelessWidget {
  /// Default number of moves per page.
  static const int _defaultPerPage = 10;

  /// All moves for the Pokemon.
  final List<PokemonMove> moves;

  /// The primary color for the UI.
  final Color baseColor;

  /// Current filter method (level-up, machine, egg, tutor).
  final String methodFilter;

  /// Current sort order (level, name).
  final String sortOrder;

  /// Current page (0-indexed).
  final int currentPage;

  /// Number of moves per page.
  final int perPage;

  /// Callback when filter method changes.
  final ValueChanged<String> onChangeMethod;

  /// Callback when sort order changes.
  final ValueChanged<String> onChangeSort;

  /// Callback when page changes.
  final ValueChanged<int> onPageChange;

  /// Callback when per page changes.
  final ValueChanged<int> onPerPageChange;

  const MovesTab({
    super.key,
    required this.moves,
    required this.baseColor,
    required this.methodFilter,
    required this.sortOrder,
    required this.currentPage,
    required this.perPage,
    required this.onChangeMethod,
    required this.onChangeSort,
    required this.onPageChange,
    required this.onPerPageChange,
  });

  @override
  Widget build(BuildContext context) {
    // Apply filters
    List<PokemonMove> filtered = moves.where((m) => m.learnMethod == methodFilter).toList();

    // Apply sort
    if (sortOrder == 'level') {
      filtered.sort((a, b) {
        final la = a.level ?? 9999;
        final lb = b.level ?? 9999;
        if (la != lb) return la.compareTo(lb);
        return a.name.compareTo(b.name);
      });
    } else {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    // Pagination
    final totalMoves = filtered.length;
    final totalPages = (totalMoves / perPage).ceil();
    final safeCurrentPage =
        totalPages > 0 ? currentPage.clamp(0, totalPages - 1) : 0;
    final startIndex = safeCurrentPage * perPage;
    final endIndex = (startIndex + perPage).clamp(0, totalMoves);
    final visibleMoves =
        totalMoves > 0 ? filtered.sublist(startIndex, endIndex) : <PokemonMove>[];

    return DetailCard(
      background: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Moves',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters section
          _buildFiltersSection(context),
          const SizedBox(height: 16),

          // Moves count
          if (totalMoves > 0)
            Center(
              child: Text(
                '$totalMoves moves found',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          const SizedBox(height: 8),

          // Moves list
          if (visibleMoves.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: [
                for (final mv in visibleMoves) _buildMoveItem(mv),
              ],
            ),

          // Pagination controls
          if (totalPages > 1)
            _buildPaginationControls(safeCurrentPage, totalPages),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method filter chips
          Text(
            'Learn Method',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMethodFilterChip('Level-up', 'level-up'),
              _buildMethodFilterChip('TM/HM', 'machine'),
              _buildMethodFilterChip('Tutor', 'tutor'),
              _buildMethodFilterChip('Egg', 'egg'),
            ],
          ),
          const SizedBox(height: 12),

          // Sort and items per page
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildSortToggle(),
              _buildPerPageSelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodFilterChip(String label, String value) {
    final selected = methodFilter == value;
    return GestureDetector(
      onTap: () => onChangeMethod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? baseColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? baseColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildSortToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sort: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        GestureDetector(
          onTap: () => onChangeSort(sortOrder == 'level' ? 'name' : 'level'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: baseColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sortOrder == 'level' ? Icons.trending_up : Icons.sort_by_alpha,
                  size: 14,
                  color: baseColor,
                ),
                const SizedBox(width: 4),
                Text(
                  sortOrder == 'level' ? 'Level' : 'Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: baseColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerPageSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Per page: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: perPage,
              isDense: true,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5')),
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 15, child: Text('15')),
                DropdownMenuItem(value: 20, child: Text('20')),
              ],
              onChanged: (v) => onPerPageChange(v ?? _defaultPerPage),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No moves found with current filters',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveItem(PokemonMove mv) {
    final moveName = capitalize(mv.name);
    final moveColor = typeColor[mv.type.toLowerCase()] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level circle or TM indicator
          if (mv.isLevelUp && mv.level != null)
            _buildLevelIndicator(mv.level!)
          else if (mv.isMachine)
            _buildTmIndicator(mv)
          else
            const SizedBox(width: 48),

          // Move name
          Expanded(
            flex: 3,
            child: Text(
              moveName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Type chip
          if (mv.type.isNotEmpty)
            _buildMoveTypeChip(mv.type)
          else
            const SizedBox(width: 60),
          const SizedBox(width: 8),

          // Damage class icon
          if (mv.damageClass.isNotEmpty)
            _buildDamageClassIndicator(mv.damageClass)
          else
            const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(int level) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: baseColor, width: 2),
      ),
      child: Center(
        child: Text(
          level.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: baseColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTmIndicator(PokemonMove mv) {
    final moveColor = typeColor[mv.type.toLowerCase()] ?? Colors.grey;
    return Container(
      width: 48,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mv.tmSpriteUrl != null)
            Image.network(
              mv.tmSpriteUrl!,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.album,
                  size: 32,
                  color: moveColor,
                );
              },
            )
          else
            Icon(
              Icons.album,
              size: 32,
              color: moveColor,
            ),
          if (mv.tmLabel != null)
            Text(
              mv.tmLabel!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMoveTypeChip(String typeName) {
    final color = typeColor[typeName.toLowerCase()] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconForType(typeName.toLowerCase()),
            size: 12,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 4),
          Text(
            typeName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageClassIndicator(String damageClass) {
    final IconData icon;
    final Color color;

    switch (damageClass.toLowerCase()) {
      case 'physical':
        icon = Icons.fitness_center;
        color = Colors.orange.shade600;
        break;
      case 'special':
        icon = Icons.auto_awesome;
        color = Colors.blue.shade600;
        break;
      case 'status':
        icon = Icons.swap_horiz;
        color = Colors.grey.shade600;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey.shade400;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildPaginationControls(int safeCurrentPage, int totalPages) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: safeCurrentPage > 0
                ? () => onPageChange(safeCurrentPage - 1)
                : null,
            icon: Icon(
              Icons.chevron_left,
              color:
                  safeCurrentPage > 0 ? baseColor : Colors.grey.shade300,
            ),
            splashRadius: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Page ${safeCurrentPage + 1} of $totalPages',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          IconButton(
            onPressed: safeCurrentPage < totalPages - 1
                ? () => onPageChange(safeCurrentPage + 1)
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: safeCurrentPage < totalPages - 1
                  ? baseColor
                  : Colors.grey.shade300,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}



class PokemonOptionsModal extends StatefulWidget {
  const PokemonOptionsModal({
    Key? key,
    required this. baseColor,
    required this.secondaryColor,
    required this. initialShowShiny,
    required this.initialIsFavorite,
    required this. onlyLevelUp,
    required this.movesMethod,
    required this.movesSort,
    required this.onToggleShiny,
    required this.onToggleFavorite,
    required this.onChangeMovesMethod,
    required this.onChangeMovesSort,
    required this.onToggleOnlyLevelUp,
    this.availableForms,
    this.selectedFormId,
    this.onFormSelected,
    this.pokemonName,
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

  final List<PokemonFormVariant>? availableForms;
  final int? selectedFormId;
  final ValueChanged<PokemonFormVariant>? onFormSelected;
  final String? pokemonName;

  @override
  State<PokemonOptionsModal> createState() => _PokemonOptionsModalState();
}

class _PokemonOptionsModalState extends State<PokemonOptionsModal>
    with TickerProviderStateMixin {
  late bool _showShiny;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isFormDropdownExpanded = false;
  late AnimationController _dropdownAnimationController;
  late Animation<double> _dropdownRotationAnimation;
  late Animation<double> _dropdownHeightAnimation;

  late AnimationController _formSelectionAnimationController;
  late Animation<double> _formScaleAnimation;
  late Animation<double> _formGlowAnimation;
  int?  _animatingFormId;

  // Estado interno del selectedFormId
  late int?  _internalSelectedFormId;

  @override
  void initState() {
    super.initState();
    _showShiny = widget.initialShowShiny;
    _internalSelectedFormId = widget.selectedFormId;

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

    _dropdownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _dropdownRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _dropdownAnimationController, curve: Curves. easeInOut),
    );

    _dropdownHeightAnimation = CurvedAnimation(
      parent: _dropdownAnimationController,
      curve: Curves.easeInOut,
    );

    _formSelectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _formScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _formSelectionAnimationController,
      curve: Curves.easeInOut,
    ));

    _formGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _formSelectionAnimationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dropdownAnimationController.dispose();
    _formSelectionAnimationController.dispose();
    super. dispose();
  }

  void _handleToggleShiny() {
    setState(() {
      _showShiny = !_showShiny;
    });
    _animationController. forward(from: 0);
    widget.onToggleShiny();
  }

  void _toggleFormDropdown() {
    setState(() {
      _isFormDropdownExpanded = !_isFormDropdownExpanded;
    });
    if (_isFormDropdownExpanded) {
      _dropdownAnimationController.forward();
    } else {
      _dropdownAnimationController.reverse();
    }
  }

  void _selectForm(PokemonFormVariant form) {
    if (form.id == _internalSelectedFormId) {
      _toggleFormDropdown();
      return;
    }

    setState(() {
      _animatingFormId = form.id;
    });

    _formSelectionAnimationController.forward(from: 0). then((_) {
      setState(() {
        _internalSelectedFormId = form.id;
        _animatingFormId = null;
      });

      widget.onFormSelected?.call(form);
      _toggleFormDropdown();
    });
  }

  PokemonFormVariant?  get _selectedForm {
    if (widget.availableForms == null || _internalSelectedFormId == null) {
      return null;
    }
    try {
      return widget.availableForms!.firstWhere((f) => f.id == _internalSelectedFormId);
    } catch (_) {
      return widget.availableForms!.isNotEmpty ? widget.availableForms!.first : null;
    }
  }

  Map<PokemonFormCategory, List<PokemonFormVariant>> get _groupedForms {
    if (widget.availableForms == null) return {};
    final Map<PokemonFormCategory, List<PokemonFormVariant>> grouped = {};
    for (final form in widget.availableForms!) {
      if (! grouped.containsKey(form. category)) {
        grouped[form.category] = [];
      }
      grouped[form.category]!.add(form);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMultipleForms = widget.availableForms != null && widget.availableForms!.length > 1;

    return SafeArea(
        child: Container(
            decoration: BoxDecoration(
              color: theme.dialogBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              Center(
              child: Container(
              width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
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
            if (hasMultipleForms)...[
        _buildFormDropdown(),
    const SizedBox(height: 12),
    ],
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
    color: widget.baseColor.withOpacity(0.3 * _glowAnimation.value),
    blurRadius: 12 * _glowAnimation.value,
    spreadRadius: 2 * _glowAnimation.value,
    ),
    ]
        : null,
    ),
    child: Row(
    children: [
    ScaleTransition(
    scale: _scaleAnimation,
    child: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: widget.baseColor. withOpacity(0.15),
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
    fontWeight: FontWeight.w700,
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
    inactiveThumbColor: Colors. grey.shade400,
    inactiveTrackColor: Colors. grey.shade300,
    splashRadius: 20,
    onChanged: (_) => _handleToggleShiny(),
    ),
    ),
    ],
    ),
    );
    },
    ),
    const SizedBox(height: 28),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildFormDropdown() {
    final selectedForm = _selectedForm;
    final groupedForms = _groupedForms;

    if (selectedForm == null) return const SizedBox. shrink();

    final categoryColor = selectedForm.category.color;
    final categoryIcon = selectedForm.category.icon;
    final formsCount = widget.availableForms?.length ??  0;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _formSelectionAnimationController,
          builder: (context, child) {
            final isAnimating = _animatingFormId != null;
            final glowValue = isAnimating ? _formGlowAnimation.value : 0.0;

            return GestureDetector(
            onTap: _toggleFormDropdown,
            child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            gradient: LinearGradient(
            colors: [
            categoryColor.withOpacity(0.1 + (glowValue * 0.1)),
            categoryColor.withOpacity(0.05 + (glowValue * 0.1)),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
            color: categoryColor.withOpacity(0.3 + (glowValue * 0.4)),
            width: 1.5 + (glowValue * 0.5),
            ),
            boxShadow: [
            BoxShadow(
            color: categoryColor. withOpacity(0.1 + (glowValue * 0.2)),
            blurRadius: 8 + (glowValue * 8),
            offset: const Offset(0, 2),
            spreadRadius: glowValue * 2,
            ),
            ],
            ),
            child: Row(
            children: [
            Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
            categoryIcon,
            color: categoryColor,
            size: 22,
            ),
            ),
            const SizedBox(width: 12),
            Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
            children: [
            Expanded(
            child: Text(
            selectedForm. displayName,
            style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
            ),
            ),
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
            '$formsCount forms',
            style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: categoryColor,
            ),
            ),
            ),
            ],
            ),
            const SizedBox(height: 6),
            _buildTypeChips(selectedForm.types),
            ],
            ),
            ),
            const SizedBox(width: 8),
            RotationTransition(
            turns: _dropdownRotationAnimation,
            child: Icon(
            Icons.keyboard_arrow_down,
            color: categoryColor,
            size: 28,
            ),
            ),
            ],
            ),
            ),
            );
          },
        ),
        SizeTransition(
          sizeFactor: _dropdownHeightAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors. black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in groupedForms.entries)...[
                      _buildCategoryHeader(entry.key),
                      for (final form in entry.value)
                        _buildFormItem(form, form.id == _internalSelectedFormId),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChips(List<String> types) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: types.map((type) {
        final color = _getTypeColor(type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            type. toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryHeader(PokemonFormCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              category.icon,
              size: 14,
              color: category.color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: category.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    category.color.withOpacity(0.3),
                    category.color. withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormItem(PokemonFormVariant form, bool isSelected) {
    final categoryColor = form.category.color;
    final isAnimating = _animatingFormId == form.id;

    return AnimatedBuilder(
      animation: _formSelectionAnimationController,
      builder: (context, child) {
        final scale = isAnimating ? _formScaleAnimation.value : 1.0;
        final glowValue = isAnimating ? _formGlowAnimation.value : 0.0;

        return Transform. scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _selectForm(form),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected || isAnimating
                    ? categoryColor.withOpacity(0.1 + (glowValue * 0.15))
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected || isAnimating
                      ? categoryColor.withOpacity(0.4 + (glowValue * 0.4))
                      : Colors.transparent,
                  width: 1.5 + (glowValue * 0.5),
                ),
                boxShadow: isAnimating
                    ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3 * glowValue),
                    blurRadius: 12 * glowValue,
                    spreadRadius: 2 * glowValue,
                  ),
                ]
                    : null,
              ),
              child: Row(
                children: [
                  Transform.scale(
                    scale: isAnimating ? 1.0 + (glowValue * 0.1) : 1.0,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isAnimating
                                ? categoryColor. withOpacity(0.3 * glowValue)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: isAnimating ?  8 * glowValue : 4,
                            offset: const Offset(0, 2),
                            spreadRadius: isAnimating ? glowValue : 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: form.spriteUrl != null
                            ?  Image.network(
                          form.spriteUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons. catching_pokemon, color: Colors.grey.shade400),
                        )
                            : Icon(Icons.catching_pokemon, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isAnimating || isSelected
                                ? categoryColor
                                : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTypeChips(form.types),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24 + (isAnimating ? glowValue * 4 : 0),
                    height: 24 + (isAnimating ? glowValue * 4 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected || isAnimating ?  categoryColor : Colors.grey.shade200,
                      border: Border.all(
                        color: isSelected || isAnimating ?  categoryColor : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isAnimating
                          ? [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.5 * glowValue),
                          blurRadius: 8 * glowValue,
                          spreadRadius: 2 * glowValue,
                        ),
                      ]
                          : null,
                    ),
                    child: isSelected || isAnimating
                        ?  Icon(
                      Icons.check,
                      size: 14 + (isAnimating ? glowValue * 2 : 0),
                      color: Colors. white,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    const Map<String, Color> typeColors = {
      "normal": Color(0xFF9BA0A8),
      "fire": Color(0xFFFF6B3D),
      "water": Color(0xFF4C90FF),
      "electric": Color(0xFFFFD037),
      "grass": Color(0xFF6BD64A),
      "ice": Color(0xFF64DDF8),
      "fighting": Color(0xFFE34343),
      "poison": Color(0xFFB24ADD),
      "ground": Color(0xFFE2B36B),
      "flying": Color(0xFFA890F7),
      "psychic": Color(0xFFFF4888),
      "bug": Color(0xFF88C12F),
      "rock": Color(0xFFC9B68B),
      "ghost": Color(0xFF6F65D8),
      "dragon": Color(0xFF7366FF),
      "dark": Color(0xFF5A5A5A),
      "steel": Color(0xFF8AA4C1),
      "fairy": Color(0xFFFF78D5),
    };
    return typeColors[type. toLowerCase()] ?? Colors.grey;
  }
}


/// Card layout used for sharing a Pokémon as an image.
class PokemonShareCard extends StatelessWidget {
  /// The Pokémon detail data.
  final PokemonDetail detail;

  /// Primary gradient color.
  final Color baseColor;

  /// Secondary gradient color.
  final Color secondaryColor;

  /// Image URL displayed on the card.
  final String? imageUrl;

  /// Whether the shiny sprite is being shown.
  final bool showShiny;

  /// Key used to capture the card as an image.
  final GlobalKey repaintBoundaryKey;

  const PokemonShareCard({
    super.key,
    required this.detail,
    required this.baseColor,
    required this.secondaryColor,
    required this.repaintBoundaryKey,
    this.imageUrl,
    this.showShiny = false,
  });

  int _statValue(String name) {
    if (detail.stats.isEmpty) return 0;

    return detail.stats
       .firstWhere(
          (s) => s.name == name,
          orElse: () => detail.stats.first,
        )
       .value;
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = imageUrl ??
        (showShiny
            ? artworkShinyUrlForId(detail.id)
            : artworkUrlForId(detail.id));

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [baseColor, secondaryColor],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 26,
              offset: const Offset(0, 18),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Decorative pokeball
            Positioned(
              right: -40,
              top: -40,
              child: Icon(
                Icons.catching_pokemon,
                size: 200,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.displayName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ) ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            detail.formattedId,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Altura', '${detail.heightMeters.toStringAsFixed(1)} m'),
                          const SizedBox(height: 4),
                          _infoRow('Peso', '${detail.weightKg.toStringAsFixed(1)} kg'),
                          const SizedBox(height: 4),
                          _infoRow('Base EXP', detail.baseExperience.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.types
                     .map((t) => TypeChipDetail(
                            typeName: t,
                            scale: 1.1,
                          ))
                     .toList(),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Habilidades',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: detail.abilities
                                 .map(
                                    (a) => _pill(
                                      a.name,
                                      a.isHidden ? Icons.visibility_off : Icons.auto_awesome,
                                    ),
                                  )
                                 .toList(),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Stats clave',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _statBadge('HP', _statValue('hp')),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _statBadge('ATK', _statValue('attack')),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _statBadge('DEF', _statValue('defense')),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _statBadge('SPD', _statValue('speed')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            displayImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Egg Groups',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          children: detail.eggGroups
                             .map(
                                (g) => Text(
                                  g.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                             .toList(),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            '${detail.totalStats} TOTAL',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _pill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}



/// A chip widget displaying a Pokemon type with icon.
class TypeChipDetail extends StatelessWidget {
  /// The type name (e.g., 'fire', 'water').
  final String typeName;

  /// Optional scale factor for sizing.
  final double scale;

  const TypeChipDetail({
    super.key,
    required this.typeName,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeColor[typeName.toLowerCase()] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconForType(typeName),
            size: 14 * scale,
            color: Colors.white.withOpacity(0.9),
          ),
          SizedBox(width: 6 * scale),
          Text(
            typeName.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 11 * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A type column with icon circle and label (for the image section).
class TypeColumn extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The background color.
  final Color color;

  /// The type label.
  final String label;

  /// Scale factor.
  final double scale;

  const TypeColumn({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypeChipCircle(icon: icon, color: color, scale: scale),
        SizedBox(height: 8 * scale),
        _TypeLabelChip(label: label, scale: scale),
      ],
    );
  }
}

class _TypeChipCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double scale;

  const _TypeChipCircle({
    required this.icon,
    required this.color,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final outerSize = 62.0 * scale;
    final innerSize = 44.0 * scale;
    final iconSize = 22.0 * scale;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}

class _TypeLabelChip extends StatelessWidget {
  final String label;
  final double scale;

  const _TypeLabelChip({required this.label, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 2 * scale,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: (14.0 * scale).clamp(10.0, 14.0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// A small type icon circle (used in evolution chain).
class TypeIconCircle extends StatelessWidget {
  /// The type name.
  final String type;

  const TypeIconCircle({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = typeColor[type.toLowerCase()] ?? typeColor['normal']!;

    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(
            iconForType(type),
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

