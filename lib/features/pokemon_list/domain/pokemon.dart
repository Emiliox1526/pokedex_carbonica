/// Entidad de dominio que representa un Pokémon.
/// 
/// Esta clase es una representación limpia de un Pokémon sin dependencias
/// de frameworks o fuentes de datos específicas. Se utiliza en la capa
/// de dominio y presentación.
class Pokemon {
  /// Identificador único del Pokémon.
  final int id;
  
  /// Nombre del Pokémon.
  final String name;
  
  /// Lista de tipos del Pokémon (ej: ['fire', 'flying']).
  final List<String> types;
  
  /// URL de la imagen oficial del Pokémon.
  final String? imageUrl;
  
  /// Lista de habilidades del Pokémon.
  final List<String> abilities;

  /// Constructor de la entidad Pokemon.
  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
    this.imageUrl,
    this.abilities = const [],
  });

  /// Identificador formateado con ceros a la izquierda (ej: #001).
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  /// Nombre formateado con la primera letra en mayúscula.
  String get displayName => name.toUpperCase();

  /// Tipo primario del Pokémon.
  String get primaryType => types.isNotEmpty ? types.first : 'normal';

  /// Tag único para animaciones Hero.
  String get heroTag => 'pokemon-image-$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pokemon && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Pokemon(id: $id, name: $name, types: $types)';
}

/// Clase que representa el resultado paginado de una lista de Pokémon.
/// 
/// Incluye información sobre la paginación basada en cursor para
/// optimizar las consultas GraphQL.
class PaginatedPokemonList {
  /// Lista de Pokémon en la página actual.
  final List<Pokemon> pokemons;
  
  /// Página actual (base 1).
  final int currentPage;
  
  /// Número total de páginas disponibles.
  final int totalPages;
  
  /// Número total de Pokémon que coinciden con los filtros.
  final int totalCount;
  
  /// Indica si hay más páginas disponibles.
  final bool hasNextPage;
  
  /// Indica si hay páginas anteriores.
  final bool hasPreviousPage;

  /// Constructor de la lista paginada.
  const PaginatedPokemonList({
    required this.pokemons,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Crea una instancia vacía para estados iniciales.
  factory PaginatedPokemonList.empty() => const PaginatedPokemonList(
        pokemons: [],
        currentPage: 1,
        totalPages: 0,
        totalCount: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
}
