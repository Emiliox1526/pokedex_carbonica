/// Use cases and repository contracts for this feature.
///
/// Contains all business logic use cases and repository interfaces.

import 'model.dart';


/// Parámetros de filtro para la consulta de Pokémon.
/// 
/// Esta clase encapsula todos los posibles filtros que se pueden aplicar
/// a una consulta de lista de Pokémon.
class PokemonFilter {
  /// Texto de búsqueda (puede ser nombre o ID).
  final String? searchText;
  
  /// Generación del Pokémon (1-9).
  final int? generation;
  
  /// Tipos seleccionados para filtrar.
  final Set<String> types;
  
  /// Número de página actual (base 1).
  final int page;
  
  /// Cantidad de Pokémon por página.
  final int pageSize;

  /// Constructor del filtro.
  const PokemonFilter({
    this.searchText,
    this.generation,
    this.types = const {},
    this.page = 1,
    this.pageSize = 20,
  });

  /// Crea una copia del filtro con los valores especificados.
  PokemonFilter copyWith({
    String? searchText,
    int? generation,
    Set<String>? types,
    int? page,
    int? pageSize,
  }) {
    return PokemonFilter(
      searchText: searchText ?? this.searchText,
      generation: generation ?? this.generation,
      types: types ?? this.types,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Calcula el offset para la consulta basado en la página actual.
  int get offset => (page - 1) * pageSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonFilter &&
          runtimeType == other.runtimeType &&
          searchText == other.searchText &&
          generation == other.generation &&
          types.length == other.types.length &&
          types.containsAll(other.types) &&
          page == other.page &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      searchText.hashCode ^
      generation.hashCode ^
      types.length.hashCode ^
      page.hashCode ^
      pageSize.hashCode;
}

/// Interfaz abstracta del repositorio de Pokémon.
/// 
/// Define el contrato que debe cumplir cualquier implementación de
/// repositorio para obtener datos de Pokémon. Sigue el principio de
/// Inversión de Dependencias (DIP) de SOLID.
abstract class PokemonRepository {
  /// Obtiene una lista paginada de Pokémon con los filtros especificados.
  /// 
  /// [filter] contiene los parámetros de filtrado y paginación.
  /// 
  /// Retorna un [Future] con [PaginatedPokemonList] que contiene
  /// los Pokémon y la información de paginación.
  /// 
  /// Puede lanzar excepciones en caso de error de red, timeout, etc.
  Future<PaginatedPokemonList> getPokemonList(PokemonFilter filter);

  /// Obtiene el conteo total de Pokémon que coinciden con los filtros.
  /// 
  /// Útil para calcular el número total de páginas.
  Future<int> getTotalPokemonCount(PokemonFilter filter);

  /// Limpia el cache local de Pokémon.
  Future<void> clearCache();

  /// Verifica si hay datos en el cache local.
  Future<bool> hasCachedData();

  /// Obtiene una lista de Pokémon aleatorios para el juego.
  /// 
  /// [count] es la cantidad de Pokémon a obtener.
  /// 
  /// Retorna un [Future] con una lista de [Pokemon].
  Future<List<Pokemon>> getRandomPokemonsForGame(int count);
}


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

