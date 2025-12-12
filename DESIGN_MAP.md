# Interactive FRLG Map - Visual Design & Layout

## Overview

The interactive map provides a fully navigable view of the Kanto region with overlays for trainers, items, and portals.

## Screen Layout

```
┌─────────────────────────────────────────┐
│  ← Map               🔍+ 🔍- ☰         │ <- AppBar with zoom & filter
├─────────────────────────────────────────┤
│                                         │
│        [Map Image Area]                 │
│                                         │
│    🔴 <- Trainer (red circle)           │
│    🟣 <- Trainer (purple = spinner)     │
│    🟠 <- Trainer (orange = walker)      │
│                                         │
│    🔵 <- Item (blue square)             │
│    🟢 <- Hidden Item (teal circle)      │
│    🟪 <- TM (purple square)             │
│                                         │
│    ──────── <- Portal line              │
│                                         │
│                                         │
│  ┌─────────────────────┐   ┌──────┐   │
│  │ 👤 Trainers          │   │ 150% │   │ <- Filter chips & zoom %
│  │ 📦 Items             │   └──────┘   │
│  │ 📍 Portals           │              │
│  └─────────────────────┘              │
└─────────────────────────────────────────┘
```

## Marker Types

### Trainers
```
┌────────────────────────────────────────┐
│ Regular Trainer                        │
│   🔴  Red circle with person icon      │
│                                        │
│ Spinner Trainer                        │
│   🟣  Purple circle with refresh icon  │
│                                        │
│ Walker Trainer                         │
│   🟠  Orange circle with walk icon     │
└────────────────────────────────────────┘
```

### Items
```
┌────────────────────────────────────────┐
│ Normal Item                            │
│   🔵  Blue square with inventory icon  │
│                                        │
│ Hidden Item                            │
│   🟢  Teal translucent circle          │
│        with hidden icon                │
│                                        │
│ TM/HM                                  │
│   🟪  Purple square with star icon     │
└────────────────────────────────────────┘
```

### Portals
```
┌────────────────────────────────────────┐
│ Portal Connection                      │
│   ●─────────● Colored line             │
│                                        │
│ Different colors for different areas:  │
│   - Green: Route 1                     │
│   - Blue: Route 2                      │
│   - Orange: Route 3-4                  │
│   - Purple: Route 5-6                  │
│   - etc.                               │
└────────────────────────────────────────┘
```

## Bottom Sheet (Trainer Details)

When tapping a trainer marker:

```
┌─────────────────────────────────────────┐
│                                         │
│  🔴  Youngster                          │
│      Walker                             │
│                                         │
│  Pokémon:  1                            │
│  Levels:   3                            │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

## Bottom Sheet (Item Details)

When tapping an item marker:

```
┌─────────────────────────────────────────┐
│                                         │
│  🔵  Normal Item                        │
│      Visible on the ground              │
│                                         │
│  Location:  X: 3850, Y: 5800            │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

## Bottom Sheet (Portal Details)

When tapping a portal endpoint:

```
┌─────────────────────────────────────────┐
│                                         │
│  🟢  Route 1                            │
│      Portal Connection                  │
│                                         │
│  Point 1:  X: 3850, Y: 6100             │
│  Point 2:  X: 3850, Y: 5700             │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

## Filter Dialog

When tapping the filter button (☰):

```
┌─────────────────────────────────────────┐
│  Map Filters                            │
├─────────────────────────────────────────┤
│                                         │
│  👤  Show Trainers          [ON]        │
│                                         │
│  📦  Show Items             [ON]        │
│                                         │
│  📍  Show Portals           [ON]        │
│                                         │
├─────────────────────────────────────────┤
│                            [Close]      │
└─────────────────────────────────────────┘
```

## Gesture Controls

```
┌─────────────────────────────────────────┐
│ Pan/Scroll                              │
│   👆 Drag to move around the map        │
│                                         │
│ Zoom                                    │
│   🤏 Pinch to zoom in/out               │
│   🔍+ Button to zoom in                 │
│   🔍- Button to zoom out                │
│                                         │
│ Tap                                     │
│   👆 Tap marker for details             │
│                                         │
│ Filter                                  │
│   👆 Tap filter chips to toggle         │
└─────────────────────────────────────────┘
```

## Color Scheme

### Trainers
- Regular: `#F44336` (Red)
- Spinner: `#9C27B0` (Purple)
- Walker: `#FF9800` (Orange)

### Items
- Normal: `#2196F3` (Blue)
- Hidden: `#009688` (Teal, 70% opacity)
- TM: `#673AB7` (Deep Purple)

### Portals
- Various colors from the hex values in portal data
- Examples:
  - Route 1: `#4CAF50` (Green)
  - Route 2: `#2196F3` (Blue)
  - Route 3-4: `#FF9800` (Orange)
  - Underground Path: `#795548` (Brown)
  - etc.

## Zoom Levels

```
┌─────────────────────────────────────────┐
│ 0.1x - Very zoomed out                  │
│   - See entire Kanto region             │
│   - Markers appear larger               │
│                                         │
│ 1.0x - Default view                     │
│   - Balanced view                       │
│   - Standard marker size                │
│                                         │
│ 4.0x - Maximum zoom                     │
│   - See fine details                    │
│   - Markers appear smaller              │
└─────────────────────────────────────────┘
```

## Marker Scaling

Markers automatically adjust their visual size based on zoom:
- At < 0.5x zoom: Markers scale up 1.5x
- At 0.5x - 2.0x zoom: Normal marker size (1.0x)
- At > 2.0x zoom: Markers scale down 0.8x

This ensures markers remain visible at all zoom levels.

## Responsive Design

The map adapts to different screen sizes:
- Mobile: Compact filter chips, touch-friendly markers
- Tablet: Larger view area, more visible markers
- Desktop: Full-size display, mouse wheel zoom

## Performance Optimizations

1. **Portal Lines**: Drawn with CustomPainter for efficiency
2. **Const Data**: All data lists use const for compile-time optimization
3. **Conditional Rendering**: Only visible markers are rendered based on filters
4. **Transform Caching**: InteractiveViewer efficiently handles transformations

## Accessibility

- All markers have semantic labels
- Bottom sheets provide detailed text descriptions
- Zoom controls accessible via buttons (not just gestures)
- High contrast colors for visibility
- Clear icons with text labels

## Sample Data Coverage

The sample data covers key locations in Kanto:

### Cities/Towns
- Pallet Town
- Viridian City (+ Gym)
- Pewter City (+ Gym)
- Cerulean City (+ Gym)
- Vermilion City (+ Gym)
- Lavender Town
- Celadon City (+ Gym)
- Saffron City (+ Gym)
- Fuchsia City (+ Gym)
- Cinnabar Island (+ Gym)
- Indigo Plateau (+ Elite Four)

### Routes
- Routes 1-25
- Victory Road
- Viridian Forest
- Mt. Moon
- Rock Tunnel
- Pokemon Tower
- Safari Zone
- Pokemon Mansion
- Cerulean Cave

This provides comprehensive coverage of the Kanto region from Fire Red/Leaf Green.
