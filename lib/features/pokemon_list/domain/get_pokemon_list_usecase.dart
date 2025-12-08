import 'pokemon.dart';
import 'pokemon_repository.dart';

/// Caso de uso para obtener la lista paginada de Pokémon.
/// 
/// Esta clase encapsula la lógica de negocio para obtener Pokémon
/// con paginación y filtros. Sigue el principio de Responsabilidad
/// Única (SRP) de SOLID.
class GetPokemonListUseCase {
  /// Repositorio de Pokémon.
  final PokemonRepository _repository;

  /// Constructor que inyecta el repositorio.
  GetPokemonListUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener la lista de Pokémon.
  /// 
  /// [filter] contiene los parámetros de filtrado y paginación.
  /// 
  /// Retorna un [Future] con [PaginatedPokemonList] que incluye:
  /// - Lista de Pokémon de la página actual
  /// - Información de paginación (página actual, total de páginas, etc.)
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final useCase = GetPokemonListUseCase(repository);
  /// final result = await useCase.execute(
  ///   PokemonFilter(page: 1, pageSize: 20),
  /// );
  /// ```
  Future<PaginatedPokemonList> execute(PokemonFilter filter) async {
    return _repository.getPokemonList(filter);
  }

  /// Obtiene solo el conteo total de Pokémon.
  /// 
  /// Útil para calcular el número de páginas sin cargar los datos.
  Future<int> getTotalCount(PokemonFilter filter) async {
    return _repository.getTotalPokemonCount(filter);
  }
}
