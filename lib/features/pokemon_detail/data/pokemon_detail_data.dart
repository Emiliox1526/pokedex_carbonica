import 'dart:convert';

import '../../../core/utils/sprite_utils.dart';
import '../../../core/utils/string_utils.dart';
import 'package:flutter/material.dart';
//------------------------- DTO PRINCIPAL Y DOMINIO RESUMIDO -------------------------
class PokemonDTO {
  final int id;
  final String name;
  final List<String> types;
  final String? imageUrl;
  final List<String> abilities;

  const PokemonDTO({
    required this.id,
    required this.name,
    required this.types,
    this.imageUrl,
    this.abilities = const [],
  });

  factory PokemonDTO.fromGraphQL(Map<String, dynamic> json) {
    final int id = json['id'] as int? ?? 0;
    final String name = json['name'] as String? ?? '';
    final typesRaw = json['pokemon_v2_pokemontypes'] as List? ?? [];
    final List<String> types = typesRaw
        .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
        .where((e) => e.isNotEmpty)
        .toList();
    final abilitiesRaw = json['pokemon_v2_pokemonabilities'] as List? ?? [];
    final List<String> abilities = abilitiesRaw
        .take(2)
        .map((a) => (a['pokemon_v2_ability']?['name'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    String? imageUrl;
    final spritesList = json['pokemon_v2_pokemonsprites'] as List?;
    if (spritesList != null && spritesList.isNotEmpty) {
      try {
        final dynamic raw = spritesList.first['sprites'];
        Map<String, dynamic>? map;
        if (raw is String) {
          map = jsonDecode(raw) as Map<String, dynamic>;
        } else if (raw is Map) {
          map = Map<String, dynamic>.from(raw);
        }
        imageUrl =
            (map?['other']?['official-artwork']?['front_default'] as String?) ??
                (map?['front_default'] as String?);
      } catch (_) {
        imageUrl = null;
      }
    }
    return PokemonDTO(
      id: id,
      name: name,
      types: types,
      imageUrl: imageUrl,
      abilities: abilities,
    );
  }

  Pokemon toEntity() => Pokemon(
    id: id,
    name: name,
    types: types,
    imageUrl: imageUrl,
    abilities: abilities,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'types': types,
    'imageUrl': imageUrl,
    'abilities': abilities,
  };

  factory PokemonDTO.fromJson(Map<String, dynamic> json) => PokemonDTO(
    id: json['id'] as int,
    name: json['name'] as String,
    types: (json['types'] as List).cast<String>(),
    imageUrl: json['imageUrl'] as String?,
    abilities: (json['abilities'] as List?)?.cast<String>() ?? [],
  );

  @override
  String toString() => 'PokemonDTO(id: $id, name: $name, types: $types)';
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final String? imageUrl;
  final List<String> abilities;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    this.imageUrl,
    required this.abilities,
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
  String get displayName => name.toUpperCase();
  String get primaryType => types.isNotEmpty ? types.first : 'normal';
  String get heroTag => 'pokemon-image-$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pokemon &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Pokemon(id: $id, name: $name, types: $types)';
}

//------------------------- DTO DETALLE COMPLETO Y DOMINIO DETALLE -------------------------
class PokemonDetailDTO {
  final int id;
  final String name;
  final int heightDm;
  final int weightHg;
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

  factory PokemonDetailDTO.fromGraphQL(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final name = json['name'] as String? ?? '';
    final typesRaw = json['pokemon_v2_pokemontypes'] as List? ?? [];
    final types = typesRaw
        .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
        .where((t) => t.isNotEmpty)
        .cast<String>()
        .toList();

    final abilities = _parseAbilities(json['pokemon_v2_pokemonabilities'] as List? ?? []);
    final stats = _parseStats(json['pokemon_v2_pokemonstats'] as List? ?? []);
    final moves = _parseMoves(json['pokemon_v2_pokemonmoves'] as List? ?? []);
    final spriteUrls = _extractPokemonSprites(json);
    final speciesObj = json['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
    final speciesId = speciesObj?['id'] as int?;
    final speciesName = speciesObj?['name'] as String?;
    final eggGroups = _parseEggGroups(speciesObj);
    final evolutionChain = _parseEvolutionChain(speciesObj);
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

  // ------------------------ Métodos privados de parseo ------------------------
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
    final Map<String, PokemonMove> uniqueMovesMap = {};
    for (final m in movesRaw) {
      final mv = m['pokemon_v2_move'] as Map<String, dynamic>?;
      if (mv == null) continue;
      final moveName = mv['name'] as String? ?? '';
      if (moveName.isEmpty) continue;
      final moveType = mv['pokemon_v2_type']?['name'] as String? ?? '';
      final method = m['pokemon_v2_movelearnmethod']?['name'] as String? ?? '';
      final key = '$moveName|$method';
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
            final itemSprites = (item['pokemon_v2_itemsprites'] as List?) ?? [];
            if (itemSprites.isNotEmpty) {
              final spritesData = itemSprites.first['sprites'];
              tmSpriteUrl = _extractItemSpriteUrl(spritesData);
            }
          }
        }
      }
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
      final types = _extractTypesFromSpecies(speciesMap);
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
      final variantTypes = ((variant['pokemon_v2_pokemontypes'] as List?) ?? [])
          .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
          .where((t) => t.isNotEmpty)
          .cast<String>()
          .toList();
      final variantSprites = _extractVariantSprites(variant);

      for (final form in variantForms) {
        final formId = (form['id'] as int?) ?? variantId;
        final formName = (form['form_name'] as String?) ?? '';
        final isDefault = (form['is_default'] as bool?) ?? false;
        final isMega = (form['is_mega'] as bool?) ?? false;
        final formTypes = ((form['pokemon_v2_pokemonformtypes'] as List?) ?? [])
            .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? '')
            .where((t) => t.isNotEmpty)
            .cast<String>()
            .toList();
        final formSprites = _extractFormSpritesFromData(form);
        PokemonFormCategory category;
        if (isMega) {
          category = PokemonFormCategory.mega;
        } else {
          category = PokemonFormVariant.getCategoryFromName(
              formName.isNotEmpty ? formName : variantName);
        }
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

//------------------------- MODELOS DE DOMINIO COMPLETOS -------------------------
class PokemonDetail {
  final int id;
  final String name;
  final double heightMeters;
  final double weightKg;
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

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.heightMeters,
    required this.weightKg,
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

  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  String get displayName {
    return name
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  String get primaryType => types.isNotEmpty ? types.first : 'normal';
  String get secondaryType => types.length > 1 ? types[1] : primaryType;
  int get totalStats => stats.fold(0, (sum, s) => sum + s.value);
  String get heroTag => 'pokemon-detail-$id';

  List<PokemonAbility> get visibleAbilities =>
      abilities.where((a) => !a.isHidden).toList();

  List<PokemonAbility> get hiddenAbilities =>
      abilities.where((a) => a.isHidden).toList();

  List<PokemonMove> getMovesByMethod(String method) {
    return moves.where((m) => m.learnMethod == method).toList();
  }

  List<PokemonMove> get levelUpMoves {
    final filtered = getMovesByMethod('level-up');
    filtered.sort((a, b) {
      final levelA = a.level ?? 9999;
      final levelB = b.level ?? 9999;
      if (levelA != levelB) return levelA.compareTo(levelB);
      return a.name.compareTo(b.name);
    });
    return filtered;
  }

  List<PokemonMove> get machineMoves {
    final filtered = getMovesByMethod('machine');
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  List<PokemonMove> get eggMoves {
    final filtered = getMovesByMethod('egg');
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  List<PokemonMove> get tutorMoves {
    final filtered = getMovesByMethod('tutor');
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  PokemonDetail copyWith({
    int? id,
    String? name,
    double? heightMeters,
    double? weightKg,
    int? baseExperience,
    List<String>? types,
    List<PokemonAbility>? abilities,
    List<PokemonStat>? stats,
    List<PokemonMove>? moves,
    List<PokemonFormVariant>? forms,
    List<PokemonEvolution>? evolutionChain,
    String? defaultSpriteUrl,
    String? shinySpriteUrl,
    List<String>? eggGroups,
    int? speciesId,
    String? speciesName,
  }) {
    return PokemonDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      heightMeters: heightMeters ?? this.heightMeters,
      weightKg: weightKg ?? this.weightKg,
      baseExperience: baseExperience ?? this.baseExperience,
      types: types ?? this.types,
      abilities: abilities ?? this.abilities,
      stats: stats ?? this.stats,
      moves: moves ?? this.moves,
      forms: forms ?? this.forms,
      evolutionChain: evolutionChain ?? this.evolutionChain,
      defaultSpriteUrl: defaultSpriteUrl ?? this.defaultSpriteUrl,
      shinySpriteUrl: shinySpriteUrl ?? this.shinySpriteUrl,
      eggGroups: eggGroups ?? this.eggGroups,
      speciesId: speciesId ?? this.speciesId,
      speciesName: speciesName ?? this.speciesName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PokemonDetail &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PokemonDetail(id: $id, name: $name, types: $types, stats: $totalStats)';
}

class PokemonAbility {
  final String name;
  final bool isHidden;
  final String shortEffect;

  const PokemonAbility({
    required this.name,
    required this.isHidden,
    required this.shortEffect,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PokemonAbility &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              isHidden == other.isHidden;

  @override
  int get hashCode => name.hashCode ^ isHidden.hashCode;

  @override
  String toString() =>
      'PokemonAbility(name: $name, isHidden: $isHidden, effect: ${shortEffect.length > 30 ? '${shortEffect.substring(0, 30)}...' : shortEffect})';
}

class PokemonEvolution {
  final int speciesId;
  final String name;
  final int? minLevel;
  final String? trigger;
  final String? item;
  final List<String> types;

  const PokemonEvolution({
    required this.speciesId,
    required this.name,
    this.minLevel,
    this.trigger,
    this.item,
    required this.types,
  });

  String get triggerLabel {
    if (trigger == null) return '—';
    switch (trigger) {
      case 'level-up':
        return minLevel != null ? 'Lv.$minLevel' : 'Level Up';
      case 'trade':
        return 'Trade';
      case 'use-item':
        return item != null ? 'Item' : 'Use Item';
      case 'shed':
        return 'Shed';
      default:
        return trigger!;
    }
  }

  bool get requiresItem => trigger == 'use-item' && item != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PokemonEvolution &&
              runtimeType == other.runtimeType &&
              speciesId == other.speciesId;

  @override
  int get hashCode => speciesId.hashCode;

  @override
  String toString() =>
      'PokemonEvolution(speciesId: $speciesId, name: $name, trigger: $trigger, minLevel: $minLevel)';
}

class PokemonMove {
  final String name;
  final String type;
  final String damageClass;
  final int? level;
  final String learnMethod;
  final String? tmName;
  final int? tmNumber;
  final String? tmSpriteUrl;

  const PokemonMove({
    required this.name,
    required this.type,
    required this.damageClass,
    this.level,
    required this.learnMethod,
    this.tmName,
    this.tmNumber,
    this.tmSpriteUrl,
  });

  bool get isLevelUp => learnMethod == 'level-up';
  bool get isMachine => learnMethod == 'machine';
  bool get isEgg => learnMethod == 'egg';
  bool get isTutor => learnMethod == 'tutor';

  String? get tmLabel {
    if (!isMachine || tmNumber == null) return null;
    final isHm = tmName?.toLowerCase().startsWith('hm') ?? false;
    final prefix = isHm ? 'HM' : 'TM';
    return '$prefix${tmNumber.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PokemonMove &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              learnMethod == other.learnMethod;

  @override
  int get hashCode => name.hashCode ^ learnMethod.hashCode;

  @override
  String toString() =>
      'PokemonMove(name: $name, type: $type, learnMethod: $learnMethod, level: $level)';
}

class PokemonStat {
  final String name;
  final int value;

  const PokemonStat({
    required this.name,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PokemonStat &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  @override
  String toString() => 'PokemonStat(name: $name, value: $value)';
}

// --------------------------------- FORMAS Y CATEGORÍA ---------------------------------
enum PokemonFormCategory {
  defaultForm,
  alolan,
  galarian,
  hisuian,
  paldean,
  mega,
  gigantamax,
  special,
}

/// Extension to add helper methods to PokemonFormCategory.
extension PokemonFormCategoryExtension on PokemonFormCategory {
  /// Gets the display name for this category.
  String get displayName {
    switch (this) {
      case PokemonFormCategory.defaultForm:
        return 'Default';
      case PokemonFormCategory.alolan:
        return 'Alolan';
      case PokemonFormCategory.galarian:
        return 'Galarian';
      case PokemonFormCategory.hisuian:
        return 'Hisuian';
      case PokemonFormCategory.paldean:
        return 'Paldean';
      case PokemonFormCategory.mega:
        return 'Mega';
      case PokemonFormCategory.gigantamax:
        return 'Gigantamax';
      case PokemonFormCategory.special:
        return 'Special';
    }
  }

  /// Gets the color associated with this category.
  Color get color {
    switch (this) {
      case PokemonFormCategory.defaultForm:
        return const Color(0xFF78909C);
      case PokemonFormCategory.alolan:
        return const Color(0xFF4FC3F7);
      case PokemonFormCategory.galarian:
        return const Color(0xFF7E57C2);
      case PokemonFormCategory.hisuian:
        return const Color(0xFF8D6E63);
      case PokemonFormCategory.paldean:
        return const Color(0xFFFFB74D);
      case PokemonFormCategory.mega:
        return const Color(0xFFE91E63);
      case PokemonFormCategory.gigantamax:
        return const Color(0xFFFF5722);
      case PokemonFormCategory.special:
        return const Color(0xFFFFD700);
    }
  }

  /// Gets the icon associated with this category.
  IconData get icon {
    switch (this) {
      case PokemonFormCategory.defaultForm:
        return Icons.catching_pokemon;
      case PokemonFormCategory.alolan:
        return Icons.beach_access;
      case PokemonFormCategory.galarian:
        return Icons.shield;
      case PokemonFormCategory.hisuian:
        return Icons.landscape;
      case PokemonFormCategory.paldean:
        return Icons.castle;
      case PokemonFormCategory.mega:
        return Icons.flash_on;
      case PokemonFormCategory.gigantamax:
        return Icons.height;
      case PokemonFormCategory.special:
        return Icons.star;
    }
  }
}

/// Domain entity representing a Pokemon form variant.
class PokemonFormVariant {
  /// The form ID.
  final int id;

  /// The internal form name.
  final String name;

  /// The display name for the form.
  final String displayName;

  /// The Pokemon ID this form belongs to.
  final int pokemonId;

  /// URL to the form's default sprite.
  final String? spriteUrl;

  /// URL to the form's shiny sprite.
  final String? shinySpriteUrl;

  /// The types of this form.
  final List<String> types;

  /// Whether this is the default form.
  final bool isDefault;

  /// The category of this form.
  final PokemonFormCategory category;

  const PokemonFormVariant({
    required this.id,
    required this.name,
    required this.displayName,
    required this.pokemonId,
    this.spriteUrl,
    this.shinySpriteUrl,
    required this.types,
    this.isDefault = false,
    required this.category,
  });

  /// Determines the category from a form name.
  static PokemonFormCategory getCategoryFromName(String formName) {
    final lowerName = formName.toLowerCase();
    // MEGA primero, para evitar solapamiento con alola/galar
    if (lowerName.contains('mega') || lowerName.contains('-mega')) {
      return PokemonFormCategory.mega;
    } else if (lowerName.contains('alolan') || lowerName.contains('alola')) {
      return PokemonFormCategory.alolan;
    } else if (lowerName.contains('galarian') || lowerName.contains('galar')) {
      return PokemonFormCategory.galarian;
    } else if (lowerName.contains('hisuian') || lowerName.contains('hisui')) {
      return PokemonFormCategory.hisuian;
    } else if (lowerName.contains('paldean') || lowerName.contains('paldea')) {
      return PokemonFormCategory.paldean;
    } else if (lowerName.contains('gmax') || lowerName.contains('gigantamax')) {
      return PokemonFormCategory.gigantamax;
    } else if (formName.isEmpty || lowerName == 'default' || lowerName == 'normal') {
      return PokemonFormCategory.defaultForm;
    } else {
      return PokemonFormCategory.special;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PokemonFormVariant &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PokemonFormVariant(id: $id, name: $name, displayName: $displayName, isDefault: $isDefault)';
}

// --------------------------------- FILTROS Y PAGINACIÓN ---------------------------------
class PokemonFilter {
  final int page;
  final int pageSize;
  final String? searchText;
  final int? generation;
  final Set<String> types;
  int get offset => (page - 1) * pageSize;

  PokemonFilter({
    this.page = 1,
    this.pageSize = 20,
    this.searchText,
    this.generation,
    this.types = const {},
  });

  PokemonFilter copyWith({
    int? page,
    int? pageSize,
    String? searchText,
    int? generation,
    Set<String>? types,
  }) =>
      PokemonFilter(
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        searchText: searchText ?? this.searchText,
        generation: generation ?? this.generation,
        types: types ?? this.types,
      );
}

class PaginatedPokemonList {
  final List<Pokemon> pokemons;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPreviousPage;
  PaginatedPokemonList({
    required this.pokemons,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedPokemonList.empty() => PaginatedPokemonList(
    pokemons: [],
    currentPage: 1,
    totalPages: 0,
    totalCount: 0,
    hasNextPage: false,
    hasPreviousPage: false,
  );
}

// --------------------------------- CONTRATO REPOSITORIO ---------------------------------
abstract class PokemonRepository {
  Future<PaginatedPokemonList> getPokemonList(PokemonFilter filter);
  Future<int> getTotalPokemonCount(PokemonFilter filter);
  Future<void> clearCache();
  Future<bool> hasCachedData();
  Future<List<Pokemon>> getRandomPokemonsForGame(int count);
}

// --------------------------------- EXCEPCIONES ---------------------------------
enum PokemonRemoteExceptionType { noConnection, timeout, rateLimit, serverError }

class PokemonRemoteException implements Exception {
  final String message;
  final PokemonRemoteExceptionType type;
  PokemonRemoteException({required this.message, required this.type});
  @override
  String toString() => 'PokemonRemoteException: $message (type: $type)';
}

enum PokemonDetailExceptionType {
  noConnection,
  timeout,
  rateLimit,
  serverError,
  notFound,
}

class PokemonDetailException implements Exception {
  final String message;
  final PokemonDetailExceptionType type;
  PokemonDetailException({
    required this.message,
    required this.type,
  });
  @override
  String toString() => 'PokemonDetailException: $message (type: $type)';
}
