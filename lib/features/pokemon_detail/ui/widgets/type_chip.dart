import 'package:flutter/material.dart';

import 'package:pokedex_carbonica/core/utils/type_utils.dart';

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
