const String getPokemonDetailQuery = r'''
query PokemonDetail($id: Int!) {
  pokemon_v2_pokemon_by_pk(id: $id) {
    id
    name
    height
    weight
    base_experience
    pokemon_v2_pokemonabilities {
      pokemon_v2_ability { name }
    }
    pokemon_v2_pokemontypes { pokemon_v2_type { name } }
    pokemon_v2_pokemonsprites { sprites }
    pokemon_v2_pokemonstats(order_by: {pokemon_v2_stat: {id: asc}}) {
      base_stat
      pokemon_v2_stat { name }
    }
    pokemon_v2_pokemonmoves(limit: 12, order_by: {level: asc_nulls_last, pokemon_v2_move: {name: asc}}) {
      level
      pokemon_v2_move { name }
    }
  }
}
''';
