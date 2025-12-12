# Testing Guide for Interactive FRLG Map

## Prerequisites

Before testing the interactive map feature, ensure you have:
- Flutter SDK installed (version 3.9.2 or higher)
- An Android emulator, iOS simulator, or physical device connected
- All dependencies installed

## Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run code generation (if needed):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running the App

### Mobile (Android/iOS)
```bash
flutter run
```

### Web
```bash
flutter run -d chrome
```

### Desktop (Linux/macOS/Windows)
```bash
flutter run -d linux    # or macos, windows
```

## Testing the Interactive Map

### Accessing the Map

The interactive map can be accessed in two ways:

1. **Via the existing map route**: The app already has a `/map` route that shows the basic map
2. **Via the new interactive map route**: Navigate to `/interactive-map`

To test from within the app, you can:
- Add a button to navigate: `Navigator.pushNamed(context, '/interactive-map');`
- Or modify the existing map button to use the new screen

### Test Cases

#### 1. Basic Display
- [ ] Map image loads correctly
- [ ] All trainers are visible on the map
- [ ] All items are visible on the map
- [ ] Portal lines are drawn correctly

#### 2. Pan and Zoom
- [ ] Can pan the map by dragging
- [ ] Can zoom in using pinch gesture (mobile) or zoom controls
- [ ] Can zoom out using pinch gesture (mobile) or zoom controls
- [ ] Zoom indicator updates correctly
- [ ] Markers remain properly positioned at all zoom levels

#### 3. Marker Interactions
- [ ] Tapping a trainer marker shows trainer details in bottom sheet
  - [ ] Shows trainer name
  - [ ] Shows number of Pokémon
  - [ ] Shows Pokémon levels
  - [ ] Shows spinner/walker status if applicable
- [ ] Tapping an item marker shows item details
  - [ ] Shows item type (Normal/Hidden/TM)
  - [ ] Shows item description
  - [ ] Shows location coordinates
- [ ] Tapping near a portal shows portal details
  - [ ] Shows portal area name
  - [ ] Shows both endpoint coordinates

#### 4. Filters
- [ ] Filter chips are visible at bottom-left
- [ ] Tapping "Trainers" chip toggles trainer visibility
- [ ] Tapping "Items" chip toggles item visibility
- [ ] Tapping "Portals" chip toggles portal line visibility
- [ ] Filter button in app bar opens filter dialog
- [ ] Switch toggles in filter dialog work correctly

#### 5. Visual Appearance
- [ ] Trainer markers have correct colors:
  - [ ] Red for regular trainers
  - [ ] Purple for spinner trainers
  - [ ] Orange for walker trainers
- [ ] Item markers have correct colors:
  - [ ] Blue for normal items
  - [ ] Teal (semi-transparent) for hidden items
  - [ ] Purple for TM items
- [ ] Portal lines have different colors for different areas
- [ ] Markers have proper shadows and borders

#### 6. Performance
- [ ] App runs smoothly with all markers visible
- [ ] Zooming and panning is responsive
- [ ] No lag when toggling filters
- [ ] No memory issues with large number of markers

## Expected Results

### Trainer Count
The sample data includes approximately 40 trainers across Kanto, including:
- Gym Leaders (Brock, Misty, Lt. Surge, Erika, Koga, Sabrina, Blaine, Giovanni)
- Elite Four members (Lorelei, Bruno, Agatha, Lance)
- Champion
- Various route trainers

### Item Count
The sample data includes approximately 100 items across Kanto, including:
- Normal items (visible on ground)
- Hidden items (require Item Finder)
- TM/HM locations

### Portal Count
The sample data includes approximately 20 portal groups connecting different areas.

## Troubleshooting

### Map doesn't load
- Check that `lib/assets/maps/FullMap.png` exists
- Verify `pubspec.yaml` includes the asset:
  ```yaml
  assets:
    - lib/assets/maps/FullMap.png
  ```
- Run `flutter clean` and `flutter pub get`

### Markers not visible
- Check that sample data files are properly imported
- Verify coordinates are within image bounds (0-7700 for X, 0-6400 for Y)
- Try zooming out to see more of the map

### Performance issues
- Reduce the number of markers in sample data
- Test on a physical device instead of emulator
- Enable release mode: `flutter run --release`

### Portal lines not showing
- Check that portal data is properly imported
- Verify portal filter is enabled
- Check that portal colors are valid hex values

## Modifying Test Data

To test with different data:

1. Edit `lib/features/map/data/trainers_data.dart` to add/remove/modify trainers
2. Edit `lib/features/map/data/items_data.dart` to add/remove/modify items
3. Edit `lib/features/map/data/portals_data.dart` to add/remove/modify portals
4. Hot reload the app to see changes

## Screenshots

After testing, take screenshots of:
- [ ] Full map view showing all markers
- [ ] Zoomed-in view showing marker details
- [ ] Trainer detail bottom sheet
- [ ] Item detail bottom sheet
- [ ] Filter controls in action
- [ ] Different zoom levels

Save screenshots in a `screenshots/` directory for documentation.

## Reporting Issues

If you encounter issues:
1. Check console output for error messages
2. Verify Flutter version matches requirements
3. Ensure all dependencies are installed
4. Check that the map image file exists and is accessible
5. Report issues with:
   - Flutter version
   - Platform (Android/iOS/Web/Desktop)
   - Steps to reproduce
   - Error messages or screenshots
