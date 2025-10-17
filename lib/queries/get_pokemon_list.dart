const String getPokemonListQuery = r'''
query GenerationOnePokemons {
  pokemon_v2_pokemon(
    where: {id: {_lte: 151}}
    order_by: {id: asc}
  ) {
    id
    name
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }
    pokemon_v2_pokemonsprites {
      sprites
    }
  }
}
''';
