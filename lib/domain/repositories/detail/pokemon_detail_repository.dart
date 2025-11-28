import '../../entities/detail/pokemon_detail.dart';

/// Abstract repository interface for Pokemon detail operations.
///
/// Defines the contract that any implementation must follow for
/// fetching Pokemon detail information.
abstract class PokemonDetailRepository {
  /// Gets detailed information for a Pokemon by ID.
  ///
  /// [id] is the Pokemon's ID.
  ///
  /// Returns a [PokemonDetail] with all information about the Pokemon.
  ///
  /// Throws an exception if the Pokemon cannot be found or there's
  /// a network error.
  Future<PokemonDetail> getPokemonDetail(int id);

  /// Gets detailed information for a specific Pokemon form variant.
  ///
  /// [pokemonId] is the ID of the Pokemon variant (not the form ID).
  ///
  /// Returns a [PokemonDetail] with information specific to that form.
  Future<PokemonDetail> getFormDetail(int pokemonId);

  /// Clears the cached Pokemon detail data.
  Future<void> clearCache();

  /// Checks if there is cached data available for a Pokemon.
  ///
  /// [id] is the Pokemon's ID.
  ///
  /// Returns true if cached data exists and is valid.
  Future<bool> hasCachedData(int id);

  /// Gets cached Pokemon detail data if available.
  ///
  /// [id] is the Pokemon's ID.
  ///
  /// Returns null if no valid cache exists.
  Future<PokemonDetail?> getCachedDetail(int id);
}
