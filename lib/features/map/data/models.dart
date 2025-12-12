/// Data models for the interactive FRLG map

/// Position where tooltip should appear relative to marker
enum TooltipPosition {
  top,
  bottom,
  left,
  right,
}

/// Type of item on the map
enum ItemType {
  normal,
  hidden,
  tm,
}

/// Trainer data with location and metadata
class TrainerData {
  final String name;
  final int numPokemon;
  final List<int> pokemonLevels;
  final double x;
  final double y;
  final bool? spinner;
  final bool? walker;
  final TooltipPosition? tooltipPosition;

  const TrainerData({
    required this.name,
    required this.numPokemon,
    required this.pokemonLevels,
    required this.x,
    required this.y,
    this.spinner,
    this.walker,
    this.tooltipPosition,
  });

  String get levelsString => pokemonLevels.join(', ');
  
  bool get isSpinner => spinner ?? false;
  bool get isWalker => walker ?? false;
}

/// Item data with location and type
class ItemData {
  final double x;
  final double y;
  final ItemType type;
  final String? spawnInfo;

  const ItemData({
    required this.x,
    required this.y,
    required this.type,
    this.spawnInfo,
  });
}

/// A single portal endpoint
class PortalPoint {
  final double x;
  final double y;

  const PortalPoint({
    required this.x,
    required this.y,
  });
}

/// A portal connection between two points
class Portal {
  final PortalPoint portal1;
  final PortalPoint portal2;

  const Portal({
    required this.portal1,
    required this.portal2,
  });
}

/// Group of portals for a specific area with a color
class MapPortalGroup {
  final String color;
  final String area;
  final List<Portal> portals;

  const MapPortalGroup({
    required this.color,
    required this.area,
    required this.portals,
  });
}
