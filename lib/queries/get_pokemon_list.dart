/// Consulta GraphQL para obtener lista paginada de Pokémon.
/// 
/// Esta consulta utiliza paginación basada en offset con un límite máximo
/// de 20 Pokémon por página según los requisitos de Clean Architecture.
/// 
/// Variables:
/// - `$limit`: Número máximo de Pokémon a obtener (recomendado: 20)
/// - `$offset`: Desplazamiento para la paginación
/// - `$where`: Condiciones de filtrado (generación, tipos, búsqueda)
const String paginatedPokemonListQuery = r'''
  query PokemonList($limit: Int!, $offset: Int!, $where: pokemon_v2_pokemon_bool_exp) {
    pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: {id: asc}, where: $where) {
      id
      name
      pokemon_v2_pokemonabilities(limit: 2) {
        pokemon_v2_ability { name }
      }
      pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      pokemon_v2_pokemonsprites { sprites }
    }
  }
''';

/// Consulta GraphQL para obtener el conteo total de Pokémon.
/// 
/// Útil para calcular el número total de páginas en la paginación.
/// 
/// Variables:
/// - `$where`: Condiciones de filtrado (debe coincidir con paginatedPokemonListQuery)
const String pokemonCountQuery = r'''
  query PokemonCount($where: pokemon_v2_pokemon_bool_exp) {
    pokemon_v2_pokemon_aggregate(where: $where) {
      aggregate {
        count
      }
    }
  }
''';