import '../../entities/detail/pokemon_detail.dart';
import '../../repositories/detail/pokemon_detail_repository.dart';

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
