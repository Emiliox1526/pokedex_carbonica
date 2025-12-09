import 'pokemon.dart';
import 'pokemon_repository.dart';

/// Caso de uso para obtener la lista paginada de Pokémon.
class GetPokemonListUseCase {
  /// Repositorio de Pokémon.
  final PokemonRepository _repository;

  /// Rango válido de IDs (solo pokémon 1–1025).
  static const int _minValidId = 1;
  static const int _maxValidId = 1025;

  /// Constructor que inyecta el repositorio.
  GetPokemonListUseCase(this._repository);

  bool _isValidPokemon(Pokemon pokemon) {
    return pokemon.id >= _minValidId && pokemon.id <= _maxValidId;
  }

  Future<PaginatedPokemonList> execute(PokemonFilter filter) async {
    final result = await _repository.getPokemonList(filter);

    // Filtramos las formas especiales (IDs fuera de 1–1025)
    final filteredPokemons =
    result.pokemons.where(_isValidPokemon).toList();

    // Construimos una nueva lista paginada con los pokémon filtrados
    return PaginatedPokemonList(
      pokemons: filteredPokemons,
      currentPage: result.currentPage,
      totalPages: result.totalPages,
      // Si quieres que el total refleje solo los que se muestran en esta página
      totalCount: filteredPokemons.length,
      hasNextPage: result.hasNextPage,
      hasPreviousPage: result.hasPreviousPage,
    );
  }

  /// Obtiene solo el conteo total de Pokémon.
  ///
  /// Útil para calcular el número de páginas sin cargar los datos.
  Future<int> getTotalCount(PokemonFilter filter) async {
    // Si quieres ignorar por completo los especiales y solo contar 1–1025:
    return _maxValidId;

    // Alternativa (si el repo ya devuelve un total global):
    // final total = await _repository.getTotalPokemonCount(filter);
    // return total.clamp(_minValidId, _maxValidId);
  }
}
