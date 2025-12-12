import 'package:flutter/material.dart';

/// Shared utility functions for the map feature

/// Parse a hex color string to a Color object
/// Supports both 6-digit (#RRGGBB) and 8-digit (#AARRGGBB) hex colors
Color parseHexColor(String hexColor) {
  final hex = hexColor.replaceAll('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  } else if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return Colors.grey;
}

/// A reusable info row widget for displaying label-value pairs
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
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
