import 'package:flutter/material.dart';
import '../../data/models.dart';
import 'map_utils.dart';

/// Marker widget for displaying items on the map
class ItemMarker extends StatelessWidget {
  final ItemData item;
  final VoidCallback onTap;
  final double scale;

  const ItemMarker({
    super.key,
    required this.item,
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
          color: _getItemColor(),
          shape: item.type == ItemType.hidden ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: item.type != ItemType.hidden
              ? BorderRadius.circular(4 * scale)
              : null,
          border: Border.all(
            color: item.type == ItemType.hidden
                ? Colors.white.withOpacity(0.6)
                : Colors.white,
            width: item.type == ItemType.hidden ? 1.5 * scale : 2 * scale,
            style: item.type == ItemType.hidden
                ? BorderStyle.solid
                : BorderStyle.solid,
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
            _getItemIcon(),
            size: 12 * scale,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getItemColor() {
    switch (item.type) {
      case ItemType.normal:
        return Colors.blue;
      case ItemType.hidden:
        return Colors.teal.withOpacity(0.7);
      case ItemType.tm:
        return Colors.deepPurple;
    }
  }

  IconData _getItemIcon() {
    switch (item.type) {
      case ItemType.normal:
        return Icons.inventory_2;
      case ItemType.hidden:
        return Icons.visibility_off;
      case ItemType.tm:
        return Icons.stars;
    }
  }
}

/// Shows detailed information about an item in a bottom sheet
void showItemDetails(BuildContext context, ItemData item) {
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
                  color: _getItemColorStatic(item.type),
                  shape: item.type == ItemType.hidden
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: item.type != ItemType.hidden
                      ? BorderRadius.circular(8)
                      : null,
                ),
                child: Icon(
                  _getItemIconStatic(item.type),
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
                      _getItemTypeName(item.type),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getItemTypeDescription(item.type),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (item.spawnInfo != null) ...[
            InfoRow(
              label: 'Spawn Info',
              value: item.spawnInfo!,
              labelWidth: 100,
            ),
            const SizedBox(height: 8),
          ],
          InfoRow(
            label: 'Location',
            value: 'X: ${item.x.toInt()}, Y: ${item.y.toInt()}',
            labelWidth: 100,
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

String _getItemTypeName(ItemType type) {
  switch (type) {
    case ItemType.normal:
      return 'Normal Item';
    case ItemType.hidden:
      return 'Hidden Item';
    case ItemType.tm:
      return 'TM/HM';
  }
}

String _getItemTypeDescription(ItemType type) {
  switch (type) {
    case ItemType.normal:
      return 'Visible on the ground';
    case ItemType.hidden:
      return 'Requires Item Finder';
    case ItemType.tm:
      return 'Technical or Hidden Machine';
  }
}

Color _getItemColorStatic(ItemType type) {
  switch (type) {
    case ItemType.normal:
      return Colors.blue;
    case ItemType.hidden:
      return Colors.teal;
    case ItemType.tm:
      return Colors.deepPurple;
  }
}

IconData _getItemIconStatic(ItemType type) {
  switch (type) {
    case ItemType.normal:
      return Icons.inventory_2;
    case ItemType.hidden:
      return Icons.visibility_off;
    case ItemType.tm:
      return Icons.stars;
  }
}
