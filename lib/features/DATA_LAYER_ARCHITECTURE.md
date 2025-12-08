# Data Layer Architecture - Pokedex Carbonica

## Overview
This document describes the unified data layer architecture across all features in the Pokedex Carbonica application.

## Standard File Structure

Each feature's data layer follows this consistent structure:

```
lib/features/{feature_name}/data/
├── {feature_name}_dto.dart           # Data Transfer Objects for serialization
├── {feature_name}_dto.g.dart         # Generated code (if using json_serializable/Hive)
├── {feature_name}_local_datasource.dart   # Local storage implementation
├── {feature_name}_remote_datasource.dart  # Remote API implementation
└── {feature_name}_repository_impl.dart    # Repository implementation (if applicable)
```

**Note on Naming:** Some features use shortened names (e.g., `pokemon_local_datasource.dart` instead of 
`pokemon_list_local_datasource.dart`). Both patterns are acceptable as long as they're consistent 
within a feature and clearly identifiable.

## Shared Helpers

Common functionality has been extracted to shared helpers to avoid code duplication:

### GraphQL Error Handler
**Location:** `lib/features/common/data/helpers/graphql_error_handler.dart`

**Purpose:** Centralizes GraphQL error parsing and exception type determination.

**Usage:**
```dart
import '../../common/data/helpers/graphql_error_handler.dart';

if (result.hasException) {
  throw CustomException(
    message: GraphQLErrorHandler.parseException(result.exception!),
    type: GraphQLErrorHandler.getExceptionType(result.exception!),
  );
}
```

### Cache Helper
**Location:** `lib/features/common/data/helpers/cache_helper.dart`

**Purpose:** Provides reusable methods for cache validation and key generation.

**Usage:**
```dart
import '../../common/data/helpers/cache_helper.dart';

// Validate cache timestamp
bool isValid = CacheHelper.isCacheValid(timestampMillis);

// Get current timestamp
int now = CacheHelper.getCurrentTimestamp();

// Build cache keys
String key = CacheHelper.buildCacheKey(['pokemon', id.toString()]);
```

## Feature-Specific Implementations

### pokemon_list
- **DTO:** Uses Hive type adapter for local persistence and GraphQL deserialization
- **Remote:** GraphQL queries with pagination, filtering by generation/type/search
- **Local:** Hive-based caching with 24-hour expiration
- **Repository:** Combines remote and local data sources with fallback logic

### pokemon_detail
- **DTO:** Manual JSON serialization (complex nested structures)
- **Remote:** GraphQL queries for detailed Pokemon data and form variants
- **Local:** JSON string-based caching in Hive
- **Repository:** Prioritizes cache, falls back to remote on cache miss

### game
- **DTOs:** `game_score_dto.dart` and `game_achievement_dto.dart` with Hive adapters
- **Remote:** Stub implementation for future online features (leaderboards, cloud sync)
- **Local:** Full implementation for scores, achievements, and statistics

### favorites
- **DTO:** Reuses `PokemonDTO` from pokemon_list (documented in `favorites_dto.dart`)
- **Remote:** Stub implementation for future sync features
- **Local:** Stores complete Pokemon data using Hive, with SharedPreferences compatibility

## Design Principles

1. **Consistency:** All features follow the same naming and organizational patterns
2. **DRY (Don't Repeat Yourself):** Common logic is extracted to shared helpers
3. **Separation of Concerns:** DTOs handle serialization, datasources handle I/O, repositories coordinate
4. **Future-Ready:** Stub implementations maintain structure for easy future expansion
5. **Offline-First:** Local caching prioritized for better UX

## DTO Serialization Patterns

### Hive Type Adapter (Recommended for simple types)
Used by: pokemon_list, game

Advantages:
- Automatic code generation
- Type-safe
- Fast serialization

### Manual JSON (For complex nested structures)
Used by: pokemon_detail

Advantages:
- Full control over serialization
- Better for complex transformations
- No build_runner dependency for these files

## Cache Strategy

All local datasources implement a consistent caching strategy:

- **Duration:** 24 hours by default (configurable via `CacheHelper`)
- **Validation:** Timestamp-based using `CacheHelper.isCacheValid()`
- **Keys:** Structured keys using `CacheHelper.buildCacheKey()`
- **Expiration:** Automatic via timestamp comparison

## Error Handling

All remote datasources use the shared `GraphQLErrorHandler` for consistent error types:

- `noConnection`: Network/connection errors
- `timeout`: Query timeouts
- `rateLimit`: API rate limiting
- `serverError`: Server-side errors
- `notFound`: Resource not found (when applicable)

## Future Enhancements

### Potential Additions
1. **Pagination Helper:** Extract common pagination logic if patterns emerge
2. **Network Status Helper:** Centralize connectivity checks
3. **Retry Logic Helper:** Add exponential backoff for failed requests
4. **Analytics Helper:** Track data layer operations for monitoring

### Migration Path
If you need to add new features:

1. Create the feature directory: `lib/features/new_feature/data/`
2. Copy the structure from an existing feature (pokemon_list is recommended)
3. Update imports to use shared helpers
4. Implement feature-specific logic
5. Add stub remote datasource if not needed initially
6. Document any deviations from standard patterns

## Testing Recommendations

When adding tests:
- Test DTOs: Serialization/deserialization round-trips
- Test Local Datasources: Cache hit/miss scenarios, expiration
- Test Remote Datasources: Error handling, GraphQL response parsing
- Test Repositories: Fallback logic, data coordination

## Maintenance Notes

- Keep shared helpers backward compatible
- Document breaking changes in this file
- Update all features when modifying shared patterns
- Run `dart run build_runner build --delete-conflicting-outputs` after DTO changes
- Run `flutter analyze` before committing changes

---

Last Updated: 2025-12-08
Maintained by: Development Team
