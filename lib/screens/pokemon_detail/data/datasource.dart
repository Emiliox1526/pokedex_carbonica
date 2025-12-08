/// Data sources and DTOs for this feature.
///
/// Consolidates all data transfer objects, local and remote data sources.

import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/model.dart';



/// Data Transfer Object for Pokemon detail data from GraphQL.
///
/// Handles parsing and transformation of raw GraphQL responses
/// into domain entities.
class PokemonDetailDTO {
  final int id;
  final String name;
  final int heightDm; // Height in decimeters
  final int weightHg; // Weight in hectograms
  final int baseExperience;
  final List<String> types;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final List<PokemonMove> moves;
  final List<PokemonFormVariant> forms;
  final List<PokemonEvolution> evolutionChain;
  final String? defaultSpriteUrl;
  final String? shinySpriteUrl;
  final List<String> eggGroups;
  final int? speciesId;
  final String? speciesName;

  const PokemonDetailDTO({
    required this.id,
    required this.name,
    required this.heightDm,
    required this.weightHg,
    required this.baseExperience,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.moves,
    required this.forms,
    required this.evolutionChain,
    this.defaultSpriteUrl,
    this.shinySpriteUrl,
    this.eggGroups = const [],
    this.speciesId,
    this.speciesName,
  });

  /// Creates a DTO from GraphQL response data.
  factory PokemonDetailDTO.fromGraphQL(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final name = json['name'] as String? ?? '';

    // Extract types
    final typesRaw = json['pokemon_v2_pokemontypes'] as List? ?? [];
    final types = typesRaw
.map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
.where((t) => t.isNotEmpty)
.cast<String>()
.toList();

    // Extract abilities
    final abilities = _parseAbilities(json['pokemon_v2_pokemonabilities'] as List? ?? []);

    // Extract stats
    final stats = _parseStats(json['pokemon_v2_pokemonstats'] as List? ?? []);

    // Extract moves
    final moves = _parseMoves(json['pokemon_v2_pokemonmoves'] as List? ?? []);

    // Extract sprite URLs
    final spriteUrls = _extractPokemonSprites(json);

    // Extract species data
    final speciesObj = json['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
    final speciesId = speciesObj?['id'] as int?;
    final speciesName = speciesObj?['name'] as String?;

    // Extract egg groups
    final eggGroups = _parseEggGroups(speciesObj);

    // Extract evolution chain
    final evolutionChain = _parseEvolutionChain(speciesObj);

    // Extract forms
    final forms = _parseForms(json, speciesObj, speciesName ?? name);

    return PokemonDetailDTO(
      id: id,
      name: name,
      heightDm: json['height'] as int? ?? 0,
      weightHg: json['weight'] as int? ?? 0,
      baseExperience: json['base_experience'] as int? ?? 0,
      types: types,
      abilities: abilities,
      stats: stats,
      moves: moves,
      forms: forms,
      evolutionChain: evolutionChain,
      defaultSpriteUrl: spriteUrls.defaultUrl,
      shinySpriteUrl: spriteUrls.shinyUrl,
      eggGroups: eggGroups,
      speciesId: speciesId,
      speciesName: speciesName,
    );
  }

  /// Converts the DTO to a domain entity.
  PokemonDetail toEntity() {
    return PokemonDetail(
      id: id,
      name: name,
      heightMeters: heightDm / 10.0,
      weightKg: weightHg / 10.0,
      baseExperience: baseExperience,
      types: types,
      abilities: abilities,
      stats: stats,
      moves: moves,
      forms: forms,
      evolutionChain: evolutionChain,
      defaultSpriteUrl: defaultSpriteUrl,
      shinySpriteUrl: shinySpriteUrl,
      eggGroups: eggGroups,
      speciesId: speciesId,
      speciesName: speciesName,
    );
  }

  // Private parsing methods

  static List<PokemonAbility> _parseAbilities(List<dynamic> abilitiesRaw) {
    return abilitiesRaw.map((a) {
      final ability = a['pokemon_v2_ability'] as Map<String, dynamic>?;
      final effectList = (ability?['pokemon_v2_abilityeffecttexts'] as List?) ?? [];
      
      String shortEffect = '';
      for (final ef in effectList) {
        final lang = ef['pokemon_v2_language']?['name'] as String? ?? '';
        if (lang == 'en') {
          shortEffect = (ef['short_effect'] as String? ?? '').replaceAll('\n', ' ').trim();
          break;
        }
      }
      if (shortEffect.length > 160) {
        shortEffect = '${shortEffect.substring(0, 157)}...';
      }

      return PokemonAbility(
        name: ability?['name'] as String? ?? '',
        isHidden: a['is_hidden'] as bool? ?? false,
        shortEffect: shortEffect,
      );
    }).toList();
  }

  static List<PokemonStat> _parseStats(List<dynamic> statsRaw) {
    return statsRaw.map((s) {
      final statObj = s['pokemon_v2_stat'];
      final statName = statObj?['name'] as String? ?? '';
      final baseStat = s['base_stat'] as int? ?? 0;
      
      return PokemonStat(
        name: formatStatName(statName),
        value: baseStat,
      );
    }).where((s) => s.name.isNotEmpty).toList();
  }

  static List<PokemonMove> _parseMoves(List<dynamic> movesRaw) {
    // Use a map to deduplicate moves by name + method combination
    final Map<String, PokemonMove> uniqueMovesMap = {};

    for (final m in movesRaw) {
      final mv = m['pokemon_v2_move'] as Map<String, dynamic>?;
      if (mv == null) continue;

      final moveName = mv['name'] as String? ?? '';
      if (moveName.isEmpty) continue;

      final moveType = mv['pokemon_v2_type']?['name'] as String? ?? '';
      final method = m['pokemon_v2_movelearnmethod']?['name'] as String? ?? '';
      final key = '$moveName|$method';

      // Extract TM/HM information
      String? tmName;
      int? tmNumber;
      String? tmSpriteUrl;
      final machines = (mv['pokemon_v2_machines'] as List?) ?? [];
      if (machines.isNotEmpty) {
        final machine = machines.first as Map<String, dynamic>?;
        if (machine != null) {
          tmNumber = machine['machine_number'] as int?;
          final item = machine['pokemon_v2_item'] as Map<String, dynamic>?;
          if (item != null) {
            tmName = item['name'] as String?;
            // Try to get sprite from item sprites
            final itemSprites = (item['pokemon_v2_itemsprites'] as List?) ?? [];
            if (itemSprites.isNotEmpty) {
              final spritesData = itemSprites.first['sprites'];
              tmSpriteUrl = _extractItemSpriteUrl(spritesData);
            }
          }
        }
      }
      // Fallback sprite URL based on move type
      tmSpriteUrl ??= moveType.isNotEmpty ? getTmSpriteUrl(moveType) : null;

      final move = PokemonMove(
        name: moveName,
        type: moveType,
        damageClass: mv['pokemon_v2_movedamageclass']?['name'] as String? ?? '',
        level: m['level'] as int?,
        learnMethod: method,
        tmName: tmName,
        tmNumber: tmNumber,
        tmSpriteUrl: tmSpriteUrl,
      );

      // Keep the move with the lowest level for level-up moves
      if (!uniqueMovesMap.containsKey(key)) {
        uniqueMovesMap[key] = move;
      } else {
        final existingLevel = uniqueMovesMap[key]!.level ?? 9999;
        final newLevel = move.level ?? 9999;
        if (newLevel < existingLevel) {
          uniqueMovesMap[key] = move;
        }
      }
    }

    return uniqueMovesMap.values.toList();
  }

  static String? _extractItemSpriteUrl(dynamic spritesData) {
    if (spritesData == null) return null;
    
    Map<String, dynamic>? spritesMap;
    if (spritesData is String) {
      try {
        spritesMap = json.decode(spritesData) as Map<String, dynamic>?;
      } catch (_) {
        return null;
      }
    } else if (spritesData is Map<String, dynamic>) {
      spritesMap = spritesData;
    }
    
    return spritesMap?['default'] as String?;
  }

  static List<String> _parseEggGroups(Map<String, dynamic>? speciesObj) {
    if (speciesObj == null) return [];
    
    final eggGroupsRaw = (speciesObj['pokemon_v2_pokemonegggroups'] as List?) ?? [];
    return eggGroupsRaw
.map((e) => (e['pokemon_v2_egggroup']?['name'] as String?) ?? '')
.where((e) => e.isNotEmpty)
.toList();
  }

  static List<PokemonEvolution> _parseEvolutionChain(Map<String, dynamic>? speciesObj) {
    if (speciesObj == null) return [];

    final evolutionSpeciesRaw = (speciesObj['pokemon_v2_evolutionchain']
        ?['pokemon_v2_pokemonspecies'] as List?) ?? [];

    return evolutionSpeciesRaw.map((species) {
      final speciesMap = species as Map<String, dynamic>;
      
      // Extract types from the first Pokemon of this species
      final types = _extractTypesFromSpecies(speciesMap);
      
      // Extract evolution data
      final evolutions = (speciesMap['pokemon_v2_pokemonevolutions'] as List?) ?? [];
      int? minLevel;
      String? trigger;
      String? item;
      
      if (evolutions.isNotEmpty) {
        final evo = evolutions.first as Map<String, dynamic>;
        minLevel = evo['min_level'] as int?;
        trigger = evo['pokemon_v2_evolutiontrigger']?['name'] as String?;
        item = evo['pokemon_v2_item']?['name'] as String?;
      }

      return PokemonEvolution(
        speciesId: speciesMap['id'] as int? ?? 0,
        name: speciesMap['name'] as String? ?? '',
        minLevel: minLevel,
        trigger: trigger,
        item: item,
        types: types,
      );
    }).toList();
  }

  static List<String> _extractTypesFromSpecies(Map<String, dynamic> species) {
    final pokemons = (species['pokemon_v2_pokemons'] as List?) ?? [];
    if (pokemons.isEmpty) return ['normal'];
    
    final pokemonTypes = (pokemons.first['pokemon_v2_pokemontypes'] as List?) ?? [];
    final types = pokemonTypes
.map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
.where((t) => t.isNotEmpty)
.toList();
    
    return types.isNotEmpty ? types : ['normal'];
  }

  static List<PokemonFormVariant> _parseForms(
    Map<String, dynamic> pokemon,
    Map<String, dynamic>? speciesObj,
    String speciesName,
  ) {
    final List<PokemonFormVariant> forms = [];
    
    if (speciesObj == null) return forms;

    final pokemonId = pokemon['id'] as int? ?? 0;
    final pokemonVariants = (speciesObj['pokemon_v2_pokemons'] as List?) ?? [];

    for (final variant in pokemonVariants) {
      final variantId = (variant['id'] as int?) ?? 0;
      final variantName = (variant['name'] as String?) ?? '';
      final variantForms = (variant['pokemon_v2_pokemonforms'] as List?) ?? [];

      // Get types from the variant
      final variantTypes = ((variant['pokemon_v2_pokemontypes'] as List?) ?? [])
.map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
.where((t) => t.isNotEmpty)
.cast<String>()
.toList();

      // Get sprites from variant
      final variantSprites = _extractVariantSprites(variant);

      for (final form in variantForms) {
        final formId = (form['id'] as int?) ?? variantId;
        final formName = (form['form_name'] as String?) ?? '';
        final isDefault = (form['is_default'] as bool?) ?? false;
        final isMega = (form['is_mega'] as bool?) ?? false;

        // Get form-specific types if available
        final formTypes = ((form['pokemon_v2_pokemonformtypes'] as List?) ?? [])
.map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? '')
.where((t) => t.isNotEmpty)
.cast<String>()
.toList();

        // Get form-specific sprites if available
        final formSprites = _extractFormSpritesFromData(form);

        // Determine the category
        PokemonFormCategory category;
        if (isMega) {
          category = PokemonFormCategory.mega;
        } else {
          category = PokemonFormVariant.getCategoryFromName(
              formName.isNotEmpty ? formName : variantName);
        }

        // Build display name
        String displayName;
        if (formName.isEmpty || isDefault) {
          displayName = capitalize(speciesName);
        } else {
          displayName = '${category.displayName} ${capitalize(speciesName)}';
        }

        forms.add(PokemonFormVariant(
          id: formId,
          name: formName.isNotEmpty ? formName : variantName,
          displayName: displayName,
          category: category,
          pokemonId: variantId,
          spriteUrl: formSprites.defaultUrl ?? variantSprites.defaultUrl ?? artworkUrlForId(variantId),
          shinySpriteUrl: formSprites.shinyUrl ?? variantSprites.shinyUrl ?? artworkShinyUrlForId(variantId),
          types: formTypes.isNotEmpty ? formTypes : variantTypes,
          isDefault: isDefault,
        ));
      }

      // If no forms, add the variant itself
      if (variantForms.isEmpty) {
        final category = PokemonFormVariant.getCategoryFromName(variantName);
        String displayName;
        if (variantName == speciesName) {
          displayName = capitalize(speciesName);
        } else {
          displayName = '${category.displayName} ${capitalize(speciesName)}';
        }

        forms.add(PokemonFormVariant(
          id: variantId,
          name: variantName,
          displayName: displayName,
          category: category,
          pokemonId: variantId,
          spriteUrl: variantSprites.defaultUrl ?? artworkUrlForId(variantId),
          shinySpriteUrl: variantSprites.shinyUrl ?? artworkShinyUrlForId(variantId),
          types: variantTypes,
        ));
      }
    }

    // Sort forms: selected pokemon first, then default, then by category
    forms.sort((a, b) {
      final aIsSelected = a.pokemonId == pokemonId;
      final bIsSelected = b.pokemonId == pokemonId;

      if (aIsSelected && !bIsSelected) return -1;
      if (bIsSelected && !aIsSelected) return 1;

      if (a.category == PokemonFormCategory.defaultForm &&
          b.category != PokemonFormCategory.defaultForm) {
        return -1;
      }
      if (b.category == PokemonFormCategory.defaultForm &&
          a.category != PokemonFormCategory.defaultForm) {
        return 1;
      }

      return a.category.index.compareTo(b.category.index);
    });

    return forms;
  }

  static SpriteUrls _extractPokemonSprites(Map<String, dynamic> pokemon) {
    final spriteList = pokemon['pokemon_v2_pokemonsprites'] as List?;
    if (spriteList == null || spriteList.isEmpty) {
      return const SpriteUrls();
    }
    return extractSpriteUrls(spriteList.first['sprites']);
  }

  static SpriteUrls _extractVariantSprites(Map<String, dynamic> variant) {
    final spriteList = variant['pokemon_v2_pokemonsprites'] as List?;
    if (spriteList == null || spriteList.isEmpty) {
      return const SpriteUrls();
    }
    return extractSpriteUrls(spriteList.first['sprites']);
  }

  static SpriteUrls _extractFormSpritesFromData(Map<String, dynamic> form) {
    final spritesList = form['pokemon_v2_pokemonformsprites'] as List?;
    if (spritesList == null || spritesList.isEmpty) {
      return const SpriteUrls();
    }
    return extractFormSprites(spritesList.first['sprites']);
  }
}




/// Local data source for caching Pokemon detail data with Hive.
class PokemonDetailLocalDataSource {
  /// Name of the Hive box for Pokemon detail cache.
  static const String _detailBoxName = 'pokemon_detail_cache';

  /// Name of the Hive box for metadata.
  static const String _metadataBoxName = 'pokemon_detail_metadata';

  /// Key for last cache timestamp.
  static const String _lastCacheTimeKey = 'last_cache_time';

  /// Cache duration in hours.
  static const int _cacheDurationHours = 24;

  Box<String>? _detailBox;
  Box<dynamic>? _metadataBox;

  /// Initializes the local data source.
  Future<void> initialize() async {
    if (_detailBox != null && _metadataBox != null) return;

    _detailBox = await Hive.openBox<String>(_detailBoxName);
    _metadataBox = await Hive.openBox<dynamic>(_metadataBoxName);
  }

  /// Caches Pokemon detail data.
  Future<void> cachePokemonDetail(int id, PokemonDetail detail) async {
    await _ensureInitialized();

    try {
      final jsonString = _serializePokemonDetail(detail);
      await _detailBox!.put('pokemon_$id', jsonString);
      await _metadataBox!.put(
        '${_lastCacheTimeKey}_$id',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error caching Pokemon detail for ID $id: $e');
    }
  }

  /// Gets cached Pokemon detail data.
  Future<PokemonDetail?> getCachedPokemonDetail(int id) async {
    await _ensureInitialized();

    if (!await isCacheValid(id)) return null;

    try {
      final jsonString = _detailBox!.get('pokemon_$id');
      if (jsonString == null) return null;

      return _deserializePokemonDetail(jsonString);
    } catch (e) {
      debugPrint('Error reading cached Pokemon detail for ID $id: $e');
      return null;
    }
  }

  /// Checks if cache is valid for a Pokemon.
  Future<bool> isCacheValid(int id) async {
    await _ensureInitialized();

    final lastCacheTime =
        _metadataBox!.get('${_lastCacheTimeKey}_$id') as int?;
    if (lastCacheTime == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(lastCacheTime);
    final now = DateTime.now();
    final difference = now.difference(cacheDate);

    return difference.inHours < _cacheDurationHours;
  }

  /// Checks if there is any cached data for a Pokemon.
  Future<bool> hasData(int id) async {
    await _ensureInitialized();
    return _detailBox!.containsKey('pokemon_$id');
  }

  /// Clears all cached detail data.
  Future<void> clearCache() async {
    await _ensureInitialized();
    await _detailBox!.clear();
    await _metadataBox!.clear();
  }

  /// Clears cached data for a specific Pokemon.
  Future<void> clearCacheForPokemon(int id) async {
    await _ensureInitialized();
    await _detailBox!.delete('pokemon_$id');
    await _metadataBox!.delete('${_lastCacheTimeKey}_$id');
  }

  Future<void> _ensureInitialized() async {
    if (_detailBox == null || _metadataBox == null) {
      await initialize();
    }
  }

  // Serialization/deserialization methods

  String _serializePokemonDetail(PokemonDetail detail) {
    final map = {
      'id': detail.id,
      'name': detail.name,
      'heightMeters': detail.heightMeters,
      'weightKg': detail.weightKg,
      'baseExperience': detail.baseExperience,
      'types': detail.types,
      'abilities': detail.abilities
.map((a) => {
                'name': a.name,
                'isHidden': a.isHidden,
                'shortEffect': a.shortEffect,
              })
.toList(),
      'stats': detail.stats
.map((s) => {
                'name': s.name,
                'value': s.value,
              })
.toList(),
      'moves': detail.moves
.map((m) => {
                'name': m.name,
                'type': m.type,
                'damageClass': m.damageClass,
                'level': m.level,
                'learnMethod': m.learnMethod,
                'tmName': m.tmName,
                'tmNumber': m.tmNumber,
                'tmSpriteUrl': m.tmSpriteUrl,
              })
.toList(),
      'forms': detail.forms
.map((f) => {
                'id': f.id,
                'name': f.name,
                'displayName': f.displayName,
                'pokemonId': f.pokemonId,
                'spriteUrl': f.spriteUrl,
                'shinySpriteUrl': f.shinySpriteUrl,
                'types': f.types,
                'isDefault': f.isDefault,
                'category': f.category.index,
              })
.toList(),
      'evolutionChain': detail.evolutionChain
.map((e) => {
                'speciesId': e.speciesId,
                'name': e.name,
                'minLevel': e.minLevel,
                'trigger': e.trigger,
                'item': e.item,
                'types': e.types,
              })
.toList(),
      'defaultSpriteUrl': detail.defaultSpriteUrl,
      'shinySpriteUrl': detail.shinySpriteUrl,
      'eggGroups': detail.eggGroups,
      'speciesId': detail.speciesId,
      'speciesName': detail.speciesName,
    };
    return json.encode(map);
  }

  PokemonDetail _deserializePokemonDetail(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;

    return PokemonDetail(
      id: map['id'] as int,
      name: map['name'] as String,
      heightMeters: (map['heightMeters'] as num).toDouble(),
      weightKg: (map['weightKg'] as num).toDouble(),
      baseExperience: map['baseExperience'] as int,
      types: (map['types'] as List).cast<String>(),
      abilities: (map['abilities'] as List)
.map((a) => PokemonAbility(
                name: a['name'] as String,
                isHidden: a['isHidden'] as bool,
                shortEffect: a['shortEffect'] as String,
              ))
.toList(),
      stats: (map['stats'] as List)
.map((s) => PokemonStat(
                name: s['name'] as String,
                value: s['value'] as int,
              ))
.toList(),
      moves: (map['moves'] as List)
.map((m) => PokemonMove(
                name: m['name'] as String,
                type: m['type'] as String,
                damageClass: m['damageClass'] as String,
                level: m['level'] as int?,
                learnMethod: m['learnMethod'] as String,
                tmName: m['tmName'] as String?,
                tmNumber: m['tmNumber'] as int?,
                tmSpriteUrl: m['tmSpriteUrl'] as String?,
              ))
.toList(),
      forms: (map['forms'] as List)
.map((f) => PokemonFormVariant(
                id: f['id'] as int,
                name: f['name'] as String,
                displayName: f['displayName'] as String,
                pokemonId: f['pokemonId'] as int,
                spriteUrl: f['spriteUrl'] as String?,
                shinySpriteUrl: f['shinySpriteUrl'] as String?,
                types: (f['types'] as List).cast<String>(),
                isDefault: f['isDefault'] as bool,
                category: PokemonFormCategory.values[f['category'] as int],
              ))
.toList(),
      evolutionChain: (map['evolutionChain'] as List)
.map((e) => PokemonEvolution(
                speciesId: e['speciesId'] as int,
                name: e['name'] as String,
                minLevel: e['minLevel'] as int?,
                trigger: e['trigger'] as String?,
                item: e['item'] as String?,
                types: (e['types'] as List).cast<String>(),
              ))
.toList(),
      defaultSpriteUrl: map['defaultSpriteUrl'] as String?,
      shinySpriteUrl: map['shinySpriteUrl'] as String?,
      eggGroups: (map['eggGroups'] as List?)?.cast<String>() ?? [],
      speciesId: map['speciesId'] as int?,
      speciesName: map['speciesName'] as String?,
    );
  }
}



/// GraphQL query to get detailed Pokemon information by ID.
const String _pokemonDetailQuery = r'''
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

/// GraphQL query to get detailed data for a specific Pokemon form/variant.
const String _formDetailQuery = r'''
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

/// Remote data source for fetching Pokemon detail from PokeAPI GraphQL.
class PokemonDetailRemoteDataSource {
  final GraphQLClient _client;

  /// Timeout for queries in seconds.
  static const int _queryTimeoutSeconds = 30;

  /// Creates a data source with the given GraphQL client.
  PokemonDetailRemoteDataSource(this._client);

  /// Fetches detailed Pokemon information by ID.
  ///
  /// [id] is the Pokemon's ID.
  ///
  /// Returns a [PokemonDetailDTO] with all Pokemon details.
  ///
  /// Throws [PokemonDetailException] on failure.
  Future<PokemonDetailDTO> getPokemonDetail(int id) async {
    try {
      final result = await _client
.query(
            QueryOptions(
              document: gql(_pokemonDetailQuery),
              variables: {'id': id},
              fetchPolicy: FetchPolicy.cacheFirst,
            ),
          )
.timeout(const Duration(seconds: _queryTimeoutSeconds));

      if (result.hasException) {
        throw PokemonDetailException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }

      final data = result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;
      if (data == null) {
        throw PokemonDetailException(
          message: 'Pokemon not found',
          type: PokemonDetailExceptionType.notFound,
        );
      }

      return PokemonDetailDTO.fromGraphQL(data);
    } catch (e) {
      if (e is PokemonDetailException) rethrow;
      throw PokemonDetailException(
        message: 'Connection error: ${e.toString()}',
        type: PokemonDetailExceptionType.noConnection,
      );
    }
  }

  /// Fetches detailed information for a specific Pokemon form variant.
  ///
  /// [pokemonId] is the Pokemon ID of the form variant.
  ///
  /// Returns a [PokemonDetailDTO] with the form's specific data.
  Future<PokemonDetailDTO> getFormDetail(int pokemonId) async {
    try {
      final result = await _client
.query(
            QueryOptions(
              document: gql(_formDetailQuery),
              variables: {'pokemonId': pokemonId},
              fetchPolicy: FetchPolicy.cacheFirst,
            ),
          )
.timeout(const Duration(seconds: _queryTimeoutSeconds));

      if (result.hasException) {
        throw PokemonDetailException(
          message: _parseGraphQLException(result.exception!),
          type: _getExceptionType(result.exception!),
        );
      }

      final data = result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;
      if (data == null) {
        throw PokemonDetailException(
          message: 'Pokemon form not found',
          type: PokemonDetailExceptionType.notFound,
        );
      }

      return PokemonDetailDTO.fromGraphQL(data);
    } catch (e) {
      if (e is PokemonDetailException) rethrow;
      throw PokemonDetailException(
        message: 'Connection error: ${e.toString()}',
        type: PokemonDetailExceptionType.noConnection,
      );
    }
  }

  String _parseGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      return 'Server connection error';
    }
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    return 'Unknown query error';
  }

  PokemonDetailExceptionType _getExceptionType(OperationException exception) {
    if (exception.linkException != null) {
      return PokemonDetailExceptionType.noConnection;
    }
    final errorMessage =
        exception.graphqlErrors.isEmpty ? '' : exception.graphqlErrors.first.message;
    if (errorMessage.contains('rate limit') ||
        errorMessage.contains('too many requests')) {
      return PokemonDetailExceptionType.rateLimit;
    }
    return PokemonDetailExceptionType.serverError;
  }
}

/// Types of exceptions from the Pokemon detail data source.
enum PokemonDetailExceptionType {
  /// No internet connection.
  noConnection,

  /// Query timeout.
  timeout,

  /// Rate limit exceeded.
  rateLimit,

  /// Server error.
  serverError,

  /// Pokemon not found.
  notFound,
}

/// Exception for Pokemon detail data source errors.
class PokemonDetailException implements Exception {
  /// Descriptive error message.
  final String message;

  /// Exception type.
  final PokemonDetailExceptionType type;

  /// Creates an exception with message and type.
  PokemonDetailException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'PokemonDetailException: $message (type: $type)';
}

