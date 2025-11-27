const String getPokemonDetailQuery = r'''
query PokemonDetail($id: Int!) {
  pokemon_v2_pokemon_by_pk(id: $id) {
    id
    name
    height
    weight
    base_experience

    # Sprites (raw JSON stored in DB)
    pokemon_v2_pokemonsprites {
      sprites
    }

    # Forms / Variants with extended data
    pokemon_v2_pokemonforms {
      id
      name        
      form_name
      is_default
      form_order
      is_battle_only
      is_mega
      pokemon_id
      # Form types
      pokemon_v2_pokemonformtypes {
        pokemon_v2_type {
          name
        }
      }
      # Form sprites
      pokemon_v2_pokemonformsprites {
        sprites
      }
    }

    # Abilities: include is_hidden and effect texts
    pokemon_v2_pokemonabilities {
      is_hidden
      pokemon_v2_ability {
        id
        name
        # Effect texts (short_effect) in multiple languages if available
        pokemon_v2_abilityeffecttexts {
          short_effect
          pokemon_v2_language {
            name
          }
        }
      }
    }

    # Tipos del Pokémon
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }

    # Estadísticas base (ordenadas)
    pokemon_v2_pokemonstats(order_by: {pokemon_v2_stat: {id: asc}}) {
      base_stat
      pokemon_v2_stat {
        name
      }
    }

    # Movimientos y método (si está disponible)
    pokemon_v2_pokemonmoves(order_by: {pokemon_v2_move: {name: asc}}) {
      level
      pokemon_v2_move {
        name
        pokemon_v2_type {
          name
        }
        pokemon_v2_movedamageclass {
          name
        }
        # TM/HM information
        pokemon_v2_machines {
          machine_number
          pokemon_v2_item {
            id
            name
            pokemon_v2_itemsprites {
              sprites
            }
          }
          pokemon_v2_versiongroup {
            name
            generation_id
          }
        }
      }
      pokemon_v2_movelearnmethod {
        name
      }
      version_group_id
    }

    # Species: egg groups and evolutionary chain
    pokemon_v2_pokemonspecy {
      id
      name
      # egg groups
      pokemon_v2_pokemonegggroups {
        pokemon_v2_egggroup {
          name
        }
      }
      # All Pokemon variants in this species
      pokemon_v2_pokemons {
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
        pokemon_v2_pokemonforms {
          id
          name
          form_name
          is_default
          is_mega
          pokemon_v2_pokemonformtypes {
            pokemon_v2_type {
              name
            }
          }
          pokemon_v2_pokemonformsprites {
            sprites
          }
        }
      }
      # evolution chain -> species (ascending order if possible)
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemonevolutions {
            min_level
            pokemon_v2_evolutiontrigger {
              name
            }
            pokemon_v2_item {
              name
            }
          }
          pokemon_v2_pokemons(limit: 1) {
            pokemon_v2_pokemontypes {
              pokemon_v2_type {
                name
              }
            }
          }
        }
      }
    }
  }
}
''';

/// Query to get detailed data for a specific Pokemon form/variant
const String getFormDetailQuery = r'''
query FormDetail($pokemonId: Int!) {
  pokemon_v2_pokemon_by_pk(id: $pokemonId) {
    id
    name
    height
    weight
    base_experience

    # Sprites (raw JSON stored in DB)
    pokemon_v2_pokemonsprites {
      sprites
    }

    # Abilities
    pokemon_v2_pokemonabilities {
      is_hidden
      pokemon_v2_ability {
        id
        name
        pokemon_v2_abilityeffecttexts {
          short_effect
          pokemon_v2_language {
            name
          }
        }
      }
    }

    # Types
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }

    # Stats
    pokemon_v2_pokemonstats(order_by: {pokemon_v2_stat: {id: asc}}) {
      base_stat
      pokemon_v2_stat {
        name
      }
    }

    # Moves
    pokemon_v2_pokemonmoves(order_by: {pokemon_v2_move: {name: asc}}) {
      level
      pokemon_v2_move {
        name
        pokemon_v2_type {
          name
        }
        pokemon_v2_movedamageclass {
          name
        }
        pokemon_v2_machines {
          machine_number
          pokemon_v2_item {
            id
            name
            pokemon_v2_itemsprites {
              sprites
            }
          }
          pokemon_v2_versiongroup {
            name
            generation_id
          }
        }
      }
      pokemon_v2_movelearnmethod {
        name
      }
      version_group_id
    }

    # Forms
    pokemon_v2_pokemonforms {
      id
      name
      form_name
      is_default
      is_mega
      pokemon_v2_pokemonformtypes {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonformsprites {
        sprites
      }
    }

    # Species info
    pokemon_v2_pokemonspecy {
      id
      name
      pokemon_v2_pokemonegggroups {
        pokemon_v2_egggroup {
          name
        }
      }
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemonevolutions {
            min_level
            pokemon_v2_evolutiontrigger {
              name
            }
            pokemon_v2_item {
              name
            }
          }
          pokemon_v2_pokemons(limit: 1) {
            pokemon_v2_pokemontypes {
              pokemon_v2_type {
                name
              }
            }
          }
        }
      }
    }
  }
}
''';