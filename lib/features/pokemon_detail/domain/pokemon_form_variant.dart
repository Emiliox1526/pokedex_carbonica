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
}
