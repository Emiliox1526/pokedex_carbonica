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