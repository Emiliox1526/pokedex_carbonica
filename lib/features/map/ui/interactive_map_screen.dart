import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/models.dart';
import '../data/trainers_data.dart';
import '../data/items_data.dart';
import '../data/portals_data.dart';
import 'widgets/trainer_marker.dart';
import 'widgets/item_marker.dart';
import 'widgets/portal_painter.dart';

/// Interactive map screen displaying trainers, items, and portals
class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  static const String _assetPath = 'lib/assets/maps/FullMap.png';
  static const Size _imageSize = Size(7700, 6400);

  final TransformationController _transformationController =
      TransformationController();

  bool _showTrainers = true;
  bool _showItems = true;
  bool _showPortals = true;

  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final matrix = _transformationController.value;
    setState(() {
      _currentScale = matrix.getMaxScaleOnAxis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.map),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive viewer with map and markers
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.1,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: SizedBox(
              width: _imageSize.width,
              height: _imageSize.height,
              child: Stack(
                children: [
                  // Base map image
                  Image.asset(
                    _assetPath,
                    width: _imageSize.width,
                    height: _imageSize.height,
                    fit: BoxFit.fill,
                  ),
                  
                  // Portal lines (behind markers)
                  if (_showPortals)
                    CustomPaint(
                      painter: PortalPainter(
                        portalGroups: portalsData,
                        scale: 1.0,
                        offset: Offset.zero,
                      ),
                      size: _imageSize,
                    ),
                  
                  // Trainer markers
                  if (_showTrainers)
                    ...trainersData.map((trainer) => Positioned(
                          left: trainer.x - 12,
                          top: trainer.y - 12,
                          child: TrainerMarker(
                            trainer: trainer,
                            onTap: () => showTrainerDetails(context, trainer),
                            scale: _getMarkerScale(),
                          ),
                        )),
                  
                  // Item markers
                  if (_showItems)
                    ...itemsData.map((item) => Positioned(
                          left: item.x - 10,
                          top: item.y - 10,
                          child: ItemMarker(
                            item: item,
                            onTap: () => showItemDetails(context, item),
                            scale: _getMarkerScale(),
                          ),
                        )),
                ],
              ),
            ),
          ),
          
          // Filter chips overlay
          Positioned(
            left: 16,
            bottom: 16,
            child: _buildFilterChips(),
          ),
          
          // Zoom level indicator
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildZoomIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterChip(
            label: 'Trainers',
            icon: Icons.person,
            color: Colors.red,
            isSelected: _showTrainers,
            onTap: () => setState(() => _showTrainers = !_showTrainers),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Items',
            icon: Icons.inventory_2,
            color: Colors.blue,
            isSelected: _showItems,
            onTap: () => setState(() => _showItems = !_showItems),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Portals',
            icon: Icons.location_on,
            color: Colors.green,
            isSelected: _showPortals,
            onTap: () => setState(() => _showPortals = !_showPortals),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(_currentScale * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    final scale = matrix.getMaxScaleOnAxis();
    if (scale < 4.0) {
      matrix.scale(1.2);
      _transformationController.value = matrix;
    }
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    final scale = matrix.getMaxScaleOnAxis();
    if (scale > 0.1) {
      matrix.scale(1 / 1.2);
      _transformationController.value = matrix;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Trainers'),
              value: _showTrainers,
              onChanged: (value) {
                setState(() => _showTrainers = value);
                Navigator.pop(context);
              },
              secondary: const Icon(Icons.person, color: Colors.red),
            ),
            SwitchListTile(
              title: const Text('Show Items'),
              value: _showItems,
              onChanged: (value) {
                setState(() => _showItems = value);
                Navigator.pop(context);
              },
              secondary: const Icon(Icons.inventory_2, color: Colors.blue),
            ),
            SwitchListTile(
              title: const Text('Show Portals'),
              value: _showPortals,
              onChanged: (value) {
                setState(() => _showPortals = value);
                Navigator.pop(context);
              },
              secondary: const Icon(Icons.location_on, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  double _getMarkerScale() {
    // Scale markers inversely with zoom to keep them visible but not too large
    if (_currentScale < 0.5) {
      return 1.5;
    } else if (_currentScale > 2.0) {
      return 0.8;
    }
    return 1.0;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
