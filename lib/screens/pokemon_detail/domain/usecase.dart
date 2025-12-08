/// Use cases and repository contracts for this feature.
///
/// Contains all business logic use cases and repository interfaces.

import 'model.dart';


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


/// Use case for fetching Pokemon form variant details.
///
/// This class encapsulates the business logic for retrieving
/// detailed information about a specific Pokemon form variant.
class GetFormDetailUseCase {
  final PokemonDetailRepository _repository;

  /// Creates a use case with the given repository.
  GetFormDetailUseCase(this._repository);

  /// Executes the use case to get form detail.
  ///
  /// [pokemonId] is the Pokemon ID of the form variant.
  ///
  /// Returns a [PokemonDetail] with the form's specific information.
  Future<PokemonDetail> execute(int pokemonId) async {
    return _repository.getFormDetail(pokemonId);
  }
}


/// Use case for fetching Pokemon detail information.
///
/// This class encapsulates the business logic for retrieving detailed
/// Pokemon information, including cache management.
class GetPokemonDetailUseCase {
  final PokemonDetailRepository _repository;

  /// Creates a use case with the given repository.
  GetPokemonDetailUseCase(this._repository);

  /// Executes the use case to get Pokemon detail.
  ///
  /// [id] is the Pokemon's ID.
  /// [forceRefresh] if true, bypasses the cache.
  ///
  /// Returns a [PokemonDetail] with all information.
  Future<PokemonDetail> execute(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Try to get cached data first
      final cached = await _repository.getCachedDetail(id);
      if (cached != null) {
        return cached;
      }
    }

    return _repository.getPokemonDetail(id);
  }

  /// Clears the cache for Pokemon details.
  Future<void> clearCache() async {
    await _repository.clearCache();
  }
}

