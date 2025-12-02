import 'dart:convert';

import '../../../domain/entities/detail/pokemon_detail.dart';
import '../../../domain/entities/detail/pokemon_ability.dart';
import '../../../domain/entities/detail/pokemon_stat.dart';
import '../../../domain/entities/detail/pokemon_move.dart';
import '../../../domain/entities/detail/pokemon_form_variant.dart';
import '../../../domain/entities/detail/pokemon_evolution.dart';
import '../../../core/utils/sprite_utils.dart';
import '../../../core/utils/string_utils.dart';

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
