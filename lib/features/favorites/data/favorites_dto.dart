import '../../pokemon_list/data/pokemon_dto.dart';

/// Data Transfer Object for favorites.
///
/// Currently, the favorites feature reuses PokemonDTO from the pokemon_list
/// feature since favorites are just Pokemon marked as favorites.
/// This file documents this design decision and provides a central
/// reference point for any future changes to favorites data structure.
///
/// Design rationale:
/// - Favorites store complete Pokemon data for offline access
/// - Avoids data duplication by reusing existing PokemonDTO
/// - Maintains consistency with the pokemon_list feature
/// - Simplifies data management and reduces code duplication
///
/// If in the future favorites need additional fields (e.g., date added,
/// user notes, custom tags), a dedicated FavoritesDTO can be created
/// that wraps or extends PokemonDTO.

/// Type alias to make favorites DTO usage explicit in code.
typedef FavoritesDTO = PokemonDTO;

/// Extension on PokemonDTO to add favorites-specific functionality.
extension FavoritesDTOExtension on PokemonDTO {
  /// Converts a PokemonDTO to a format suitable for favorites storage.
  ///
  /// Currently this is a pass-through, but provides a hook for
  /// future favorites-specific transformations.
  PokemonDTO toFavoritesDTO() => this;
}
