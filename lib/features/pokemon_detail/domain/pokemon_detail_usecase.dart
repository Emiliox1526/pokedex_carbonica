import '../data/pokemon_detail_data.dart';
import 'pokemon_detail_repository.dart';

/// Use case for fetching Pokemon detail information.
///
/// This class encapsulates the business logic for retrieving detailed
/// Pokemon information, including cache management.
class GetPokemonDetailUseCase {
  final PokemonDetailRepository _repository;

  /// Creates a use case with the given repository.
  GetPokemonDetailUseCase(this._repository);

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

/// Use case for fetching Pokemon form variant details.
///
/// This class encapsulates the business logic for retrieving
/// detailed information about a specific Pokemon form variant.
class GetFormDetailUseCase {
  final PokemonDetailRepository _repository;

  /// Creates a use case with the given repository.
  GetFormDetailUseCase(this._repository);


  Future<PokemonDetail> execute(int pokemonId) async {
    return _repository.getFormDetail(pokemonId);
  }
}
