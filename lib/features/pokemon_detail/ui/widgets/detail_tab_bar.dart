import 'package:flutter/material.dart';

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
