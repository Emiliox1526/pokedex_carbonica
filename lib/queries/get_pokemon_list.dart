const String getPokemonListQuery = r'''
query GenerationOnePokemons {
  pokemon_v2_pokemon(order_by: {id: asc}) {
    id
    name
    height
    weight
    base_experience
    pokemon_v2_pokemonabilities(limit: 2) {
      pokemon_v2_ability { name }
    }
    pokemon_v2_pokemontypes { pokemon_v2_type { name } }
    pokemon_v2_pokemonsprites { sprites }
  }
}
''';
