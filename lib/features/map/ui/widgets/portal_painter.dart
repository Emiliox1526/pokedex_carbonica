import 'package:flutter/material.dart';
import '../../data/models.dart';

/// Custom painter for drawing portal connections on the map
class PortalPainter extends CustomPainter {
  final List<MapPortalGroup> portalGroups;
  final double scale;
  final Offset offset;

  PortalPainter({
    required this.portalGroups,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final group in portalGroups) {
      final paint = Paint()
        ..color = _parseColor(group.color).withOpacity(0.6)
        ..strokeWidth = 3.0 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (final portal in group.portals) {
        // Convert portal coordinates to screen coordinates
        final p1 = Offset(
          (portal.portal1.x * scale) + offset.dx,
          (portal.portal1.y * scale) + offset.dy,
        );
        final p2 = Offset(
          (portal.portal2.x * scale) + offset.dx,
          (portal.portal2.y * scale) + offset.dy,
        );

        // Draw the line
        canvas.drawLine(p1, p2, paint);

        // Draw endpoint circles
        final circleRadius = 6.0 * scale;
        final circlePaint = Paint()
          ..color = _parseColor(group.color)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(p1, circleRadius, circlePaint);
        canvas.drawCircle(p2, circleRadius, circlePaint);

        // Draw white border for circles
        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0 * scale
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(p1, circleRadius, borderPaint);
        canvas.drawCircle(p2, circleRadius, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(PortalPainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.offset != offset;
  }

  /// Parse hex color string to Color object
  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.grey;
  }
}

/// Widget for displaying portals on the map
class PortalOverlay extends StatelessWidget {
  final List<MapPortalGroup> portalGroups;
  final double scale;
  final Offset offset;

  const PortalOverlay({
    super.key,
    required this.portalGroups,
    required this.scale,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PortalPainter(
        portalGroups: portalGroups,
        scale: scale,
        offset: offset,
      ),
      child: Container(),
    );
  }
}

/// Marker widget for portal endpoints
class PortalMarker extends StatelessWidget {
  final PortalPoint point;
  final String area;
  final String color;
  final VoidCallback onTap;
  final double scale;

  const PortalMarker({
    super.key,
    required this.point,
    required this.area,
    required this.color,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20 * scale,
        height: 20 * scale,
        decoration: BoxDecoration(
          color: _parseColor(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.location_on,
            size: 12 * scale,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.grey;
  }
}

/// Shows detailed information about a portal in a bottom sheet
void showPortalDetails(BuildContext context, MapPortalGroup group, Portal portal) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _parseColorStatic(group.color),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.area,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Portal Connection',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Point 1',
            value: 'X: ${portal.portal1.x.toInt()}, Y: ${portal.portal1.y.toInt()}',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Point 2',
            value: 'X: ${portal.portal2.x.toInt()}, Y: ${portal.portal2.y.toInt()}',
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Color _parseColorStatic(String hexColor) {
  final hex = hexColor.replaceAll('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  } else if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return Colors.grey;
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
