import '../../entities/detail/pokemon_detail.dart';
import '../../repositories/detail/pokemon_detail_repository.dart';

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
