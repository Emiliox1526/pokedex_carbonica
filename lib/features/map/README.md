# Area Encounters Modal Feature

## Overview
This feature adds a modal bottom sheet that displays Pokémon encounters for location areas when tapping on routes in the map screen. It integrates with the PokeAPI to fetch real-time encounter data.

## Architecture

### Components

#### 1. Domain Models (`lib/features/map/domain/`)
- **`location_area_models.dart`**: Data models for PokeAPI responses
  - `LocationAreaResponse`: Main response wrapper
  - `PokemonEncounter`: Individual Pokémon encounter data
  - `PokemonSummary`: Basic Pokémon info with ID and sprite URL
  - `VersionDetail`: Game version-specific encounter data
  - `EncounterDetail`: Specific encounter method, level range, and chance
  - `EncounterMethod`: Method info with Spanish translations

- **`route_area_mapping.dart`**: Maps route IDs to PokeAPI area identifiers
  - Handles Kanto routes 1-23
  - Includes alternative areas for routes with multiple sub-areas

#### 2. Data Layer (`lib/features/map/data/`)
- **`pokeapi_location_area_service.dart`**: Service for fetching location data
  - In-memory caching per area
  - Retry logic for transient errors
  - 30-second timeout
  - Custom exceptions for error handling

#### 3. UI Layer (`lib/features/map/ui/widgets/`)
- **`area_encounters_modal.dart`**: Modal widget implementation
  - Loading, error, and success states
  - Expandable Pokémon cards
  - Sprite display with cached network images
  - Spanish localization
  - Dark mode compatible design

#### 4. Integration (`lib/features/map/ui/map_screen.dart`)
- Modified `_showRouteSheet()` to open encounters modal
- Uses `RouteAreaMapping` to convert route IDs to API identifiers
- Fallback to simple info sheet for unmapped routes

## API Integration

### Endpoint
```
GET https://pokeapi.co/api/v2/location-area/{identifier}
```

### Response Structure
```json
{
  "name": "kanto-route-1-area",
  "pokemon_encounters": [
    {
      "pokemon": {
        "name": "pidgey",
        "url": "https://pokeapi.co/api/v2/pokemon/16/"
      },
      "version_details": [
        {
          "version": { "name": "red" },
          "encounter_details": [
            {
              "min_level": 2,
              "max_level": 5,
              "chance": 40,
              "method": { "name": "walk" }
            }
          ]
        }
      ]
    }
  ]
}
```

## Localization

### New Strings (Spanish)
- `encountersInArea`: "Apariciones en"
- `loadingEncounters`: "Cargando apariciones..."
- `errorLoadingEncounters`: "Error al cargar las apariciones"
- `areaNotFound`: "Área no encontrada"
- `retry`: "Reintentar"
- `noEncountersData`: "Sin datos de apariciones para esta área"

## Testing

### Unit Tests
- **`location_area_models_test.dart`**: Tests JSON parsing for all models
  - Valid response parsing
  - Empty arrays handling
  - Missing fields handling
  - ID extraction from URLs
  - Sprite URL generation
  - Level range formatting
  - Method name translation

- **`route_area_mapping_test.dart`**: Tests route-to-area mapping
  - Individual route lookups
  - All 23 Kanto routes coverage
  - Sea routes (19-21) special naming
  - Alternative areas handling
  - Unmapped routes handling

### Widget Tests
- **`area_encounters_modal_test.dart`**: Tests modal UI behavior
  - Loading state display
  - Header rendering
  - Close button functionality
  - Modal dismissal

### Running Tests
```bash
flutter test test/features/map/
```

## Usage

### User Flow
1. User opens map screen
2. User taps on a colored route area
3. Modal bottom sheet opens showing:
   - Area name in header
   - Loading indicator (if fetching data)
   - List of Pokémon with sprites
   - Expandable cards showing:
     - Game versions
     - Encounter methods (translated to Spanish)
     - Level ranges
     - Encounter chances
4. User can scroll through Pokémon list
5. User can tap Pokémon cards to expand/collapse details
6. User closes modal by tapping X or dragging down

### Error Handling
- **Network errors**: Shows error message with retry button
- **Area not found**: Shows specific "Area not found" message
- **Empty encounters**: Shows "No encounter data" message
- **Timeout**: Retries once automatically, then shows error

## Caching Strategy
- In-memory cache per area identifier
- Cache persists for app session lifetime
- Cache cleared on app restart
- No persistent storage to ensure fresh data on new sessions

## Performance Considerations
- Async data fetching with FutureBuilder (non-blocking UI)
- Image caching via `cached_network_image`
- Lazy loading of sprites (loaded only when visible)
- 30-second timeout prevents hanging requests
- Automatic retry (1 attempt) for transient errors

## Dark Mode Support
- All colors use dark theme palette
- Gradient backgrounds: `#0F1420` → `#0B0E16`
- Card backgrounds: `#1A1D26` → `#151821`
- White text with appropriate opacity levels
- Border colors with low opacity for subtle separation

## Future Enhancements
- [ ] Add filtering by encounter method
- [ ] Show rarity indicators (common/uncommon/rare based on chance)
- [ ] Link to full Pokémon detail screen on tap
- [ ] Support for location-area sub-areas selection
- [ ] Offline mode with persistent cache
- [ ] Show encounter data for multiple game versions side-by-side
- [ ] Add sorting options (by name, level, chance)
- [ ] Show time of day for encounters (if available in API)

## Dependencies Added
- `http: ^1.1.0` - For REST API calls to PokeAPI

## Notes for Developers

### Updating Route Mappings
If route identifiers need updating, edit `route_area_mapping.dart`:
```dart
static const Map<int, String> routeToAreaId = {
  1: 'kanto-route-1-area',
  // Add or modify mappings here
};
```

### Adding New Encounter Methods
To add Spanish translations for new methods, edit the `EncounterMethod.spanishName` getter in `location_area_models.dart`:
```dart
String get spanishName {
  switch (name.toLowerCase()) {
    case 'new-method':
      return 'Nuevo Método';
    // Add new cases here
  }
}
```

### Adjusting Cache Behavior
To clear cache programmatically:
```dart
final service = PokeApiLocationAreaService();
service.clearCache(); // Clears all cached data
```

### Changing Timeout Duration
Edit the constant in `pokeapi_location_area_service.dart`:
```dart
static const Duration _timeout = Duration(seconds: 30); // Change as needed
```
