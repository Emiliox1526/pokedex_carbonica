import 'package:flutter/material.dart';

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
