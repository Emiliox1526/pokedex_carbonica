import '../data/pokemon_data.dart';


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

    // Filtramos las formas especiales (IDs del 1–1025)
    final filteredPokemons =
    result.pokemons.where(_isValidPokemon).toList();

    // Lista paginada con los pokémon filtrados
    return PaginatedPokemonList(
      pokemons: filteredPokemons,
      currentPage: result.currentPage,
      totalPages: result.totalPages,
      totalCount: filteredPokemons.length,
      hasNextPage: result.hasNextPage,
      hasPreviousPage: result.hasPreviousPage,
    );
  }

  // Obtiene solo el conteo total de Pokémon.
  Future<int> getTotalCount(PokemonFilter filter) async {
    return _maxValidId;
  }
}
