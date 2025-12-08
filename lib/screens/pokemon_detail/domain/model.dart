/// Domain models for the pokemon_detail feature.
///
/// This file contains all entities, value objects, and domain models.

import 'package:flutter/material.dart';

/// Enum for Pokemon form categories.
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
    if (lowerName.contains('alola') || lowerName.contains('alolan')) {
      return PokemonFormCategory.alolan;
    } else if (lowerName.contains('galar') || lowerName.contains('galarian')) {
      return PokemonFormCategory.galarian;
    } else if (lowerName.contains('hisui') || lowerName.contains('hisuian')) {
      return PokemonFormCategory.hisuian;
    } else if (lowerName.contains('paldea') || lowerName.contains('paldean')) {
      return PokemonFormCategory.paldean;
    } else if (lowerName.contains('mega') || lowerName.contains('-mega')) {
      return PokemonFormCategory.mega;
    } else if (lowerName.contains('gmax') || lowerName.contains('gigantamax')) {
      return PokemonFormCategory.gigantamax;
    } else if (formName.isEmpty ||
        lowerName == 'default' ||
        lowerName == 'normal') {
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
}\n\n/// Domain entity representing a Pokemon in the evolution chain.
class PokemonEvolution {
  /// The species ID in the chain.
  final int speciesId;

  /// The name of the Pokemon.
  final String name;

  /// The minimum level to evolve to this stage (null if not level-based).
  final int? minLevel;

  /// The evolution trigger (level-up, trade, use-item, etc.).
  final String? trigger;

  /// The item required to evolve (null if not item-based).
  final String? item;

  /// The types of this Pokemon in the evolution chain.
  final List<String> types;

  const PokemonEvolution({
    required this.speciesId,
    required this.name,
    this.minLevel,
    this.trigger,
    this.item,
    required this.types,
  });

  /// Gets a user-friendly trigger label.
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

  /// Whether this evolution requires a specific item.
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
}\n\n/// Barrel file for Pokemon detail domain entities.
export 'pokemon_detail.dart';
export 'pokemon_ability.dart';
export 'pokemon_stat.dart';
export 'pokemon_move.dart';
export 'pokemon_form_variant.dart';
export 'pokemon_evolution.dart';\n\n/// Domain entity representing a Pokemon's stat.
class PokemonStat {
  /// The name of the stat (e.g., 'hp', 'attack').
  final String name;

  /// The base stat value (0-255).
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
}\n\n/// Domain entity representing a Pokemon's move.
class PokemonMove {
  /// The name of the move.
  final String name;

  /// The type of the move (e.g., 'fire', 'water').
  final String type;

  /// The damage class (physical, special, or status).
  final String damageClass;

  /// The level at which this move is learned (null if not level-up).
  final int? level;

  /// The method by which this move is learned (level-up, machine, egg, tutor).
  final String learnMethod;

  /// The TM/HM name if learned by machine (e.g., 'tm01').
  final String? tmName;

  /// The TM/HM number if learned by machine.
  final int? tmNumber;

  /// URL to the TM/HM sprite image.
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

  /// Whether this move is learned by level-up.
  bool get isLevelUp => learnMethod == 'level-up';

  /// Whether this move is learned by TM/HM.
  bool get isMachine => learnMethod == 'machine';

  /// Whether this move is learned by breeding (egg move).
  bool get isEgg => learnMethod == 'egg';

  /// Whether this move is learned from a move tutor.
  bool get isTutor => learnMethod == 'tutor';

  /// Gets the TM/HM label (e.g., 'TM01', 'HM03').
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
}\n\n/// Domain entity representing a Pokemon's ability.
class PokemonAbility {
  /// The name of the ability.
  final String name;

  /// Whether this is a hidden ability.
  final bool isHidden;

  /// Short description of the ability's effect.
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
}\n\n\n\n