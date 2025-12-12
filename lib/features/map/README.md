# Interactive FRLG Map

This directory contains the implementation of an interactive Fire Red/Leaf Green style map for the Pokédex Carbonica application.

## Features

- **Interactive Map Navigation**: Pan and zoom with pinch-to-zoom gestures using InteractiveViewer
- **Trainer Markers**: Display trainers with different visual indicators for:
  - Regular trainers (red circle with person icon)
  - Spinner trainers (purple circle with refresh icon)
  - Walker trainers (orange circle with walk icon)
- **Item Markers**: Display items with different types:
  - Normal items (blue square with inventory icon)
  - Hidden items (teal semi-transparent circle with hidden icon)
  - TM/HM items (purple square with star icon)
- **Portal Connections**: Visual lines connecting different areas of the map
- **Filtering**: Toggle visibility of trainers, items, and portals
- **Details**: Tap any marker to see detailed information in a bottom sheet

## Structure

```
lib/features/map/
├── data/
│   ├── models.dart          # Data models for trainers, items, and portals
│   ├── trainers_data.dart   # Sample trainer locations and metadata
│   ├── items_data.dart      # Sample item locations and types
│   └── portals_data.dart    # Portal connections between areas
└── ui/
    ├── map_screen.dart           # Original FlutterMap implementation
    ├── interactive_map_screen.dart # New InteractiveViewer implementation
    └── widgets/
        ├── trainer_marker.dart   # Trainer marker widget and details
        ├── item_marker.dart      # Item marker widget and details
        └── portal_painter.dart   # Custom painter for portal lines
```

## Coordinate System

All coordinates in the data files are in **pixels** relative to the base map image:
- Image size: **7700 x 6400 pixels**
- Origin (0, 0) is at the top-left corner
- X increases to the right
- Y increases downward

## Usage

### Accessing the Interactive Map

The interactive map can be accessed via the route `/interactive-map`:

```dart
Navigator.pushNamed(context, '/interactive-map');
```

### Adding New Data

#### Adding Trainers

Edit `lib/features/map/data/trainers_data.dart`:

```dart
const TrainerData(
  name: 'Trainer Name',
  numPokemon: 3,
  pokemonLevels: [15, 16, 18],
  x: 4500,  // X coordinate in pixels
  y: 3200,  // Y coordinate in pixels
  spinner: false,  // Optional: true for spinning trainers
  walker: true,    // Optional: true for walking trainers
  tooltipPosition: TooltipPosition.top, // Optional: tooltip direction
),
```

#### Adding Items

Edit `lib/features/map/data/items_data.dart`:

```dart
const ItemData(
  x: 5000,
  y: 4000,
  type: ItemType.normal,  // or ItemType.hidden, ItemType.tm
  spawnInfo: 'Additional info', // Optional
),
```

#### Adding Portals

Edit `lib/features/map/data/portals_data.dart`:

```dart
const MapPortalGroup(
  color: '#FF5722',  // Hex color for the portal line
  area: 'Area Name',
  portals: [
    Portal(
      portal1: PortalPoint(x: 3000, y: 4000),
      portal2: PortalPoint(x: 5000, y: 4000),
    ),
  ],
),
```

## Customization

### Marker Appearance

Markers automatically scale based on zoom level to remain visible. You can customize:
- Colors in the respective marker widgets
- Icons in the marker widgets
- Size and styling in the widget implementations

### Filter Options

The filter chips at the bottom-left allow toggling:
- Trainers visibility
- Items visibility
- Portals visibility

### Zoom Controls

- Zoom buttons in the app bar
- Pinch-to-zoom gesture
- Zoom indicator in the bottom-right shows current zoom level

## Converting TypeScript Data

If you have TypeScript data files from other sources:

1. Convert enum values to Dart enums (e.g., `TooltipPosition.Top` → `TooltipPosition.top`)
2. Convert boolean values (`true`/`false` remain the same)
3. Convert arrays to Dart lists (`[]` syntax remains the same)
4. Ensure all coordinates match the pixel space of your map image

## Map Image

The base map image is located at:
- `lib/assets/maps/FullMap.png`
- Size: 7700 x 6400 pixels
- Declared in `pubspec.yaml` under assets

If you replace the map image:
1. Update the `_imageSize` constant in `interactive_map_screen.dart`
2. Adjust all coordinate data proportionally
3. Test that all markers appear in correct locations

## Performance Considerations

- Portal lines are drawn using a CustomPainter for better performance
- Markers use const constructors where possible
- Data lists are const for compile-time optimization
- Large numbers of markers (hundreds) may impact performance on lower-end devices

## Future Enhancements

Potential improvements:
- Search functionality for specific trainers or items
- Routing between locations
- Integration with Pokédex data to show which Pokémon trainers have
- User-added markers or notes
- Multiple map regions (Johto, Hoenn, etc.)
- Battle simulation with trainers
