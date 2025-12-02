import 'pokemon_ability.dart';
import 'pokemon_stat.dart';
import 'pokemon_move.dart';
import 'pokemon_form_variant.dart';
import 'pokemon_evolution.dart';

/// Domain entity representing detailed Pokemon information.
///
/// This is the main entity for the Pokemon detail screen, containing
/// all information about a specific Pokemon.
class PokemonDetail {
  /// The Pokemon's ID.
  final int id;

  /// The Pokemon's name.
  final String name;

  /// The Pokemon's height in meters.
  final double heightMeters;

  /// The Pokemon's weight in kilograms.
  final double weightKg;

  /// Base experience yield when defeated.
  final int baseExperience;

  /// List of the Pokemon's types.
  final List<String> types;

  /// List of the Pokemon's abilities.
  final List<PokemonAbility> abilities;

  /// List of the Pokemon's base stats.
  final List<PokemonStat> stats;

  /// List of moves the Pokemon can learn.
  final List<PokemonMove> moves;

  /// List of available form variants.
  final List<PokemonFormVariant> forms;

  /// The Pokemon's evolution chain.
  final List<PokemonEvolution> evolutionChain;

  /// URL to the default sprite image.
  final String? defaultSpriteUrl;

  /// URL to the shiny sprite image.
  final String? shinySpriteUrl;

  /// List of egg groups the Pokemon belongs to.
  final List<String> eggGroups;

  /// Species ID for evolution chain lookups.
  final int? speciesId;

  /// Species name for display purposes.
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

  /// Formatted ID with leading zeros (e.g., '#001').
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  /// Formatted name with proper capitalization.
  String get displayName {
    return name
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  /// The primary type of this Pokemon.
  String get primaryType => types.isNotEmpty ? types.first : 'normal';

  /// The secondary type of this Pokemon (same as primary if only one type).
  String get secondaryType => types.length > 1 ? types[1] : primaryType;

  /// Total base stat value.
  int get totalStats => stats.fold(0, (sum, s) => sum + s.value);

  /// Unique Hero tag for animations.
  String get heroTag => 'pokemon-detail-$id';

  /// Non-hidden abilities only.
  List<PokemonAbility> get visibleAbilities =>
      abilities.where((a) => !a.isHidden).toList();

  /// Hidden abilities only.
  List<PokemonAbility> get hiddenAbilities =>
      abilities.where((a) => a.isHidden).toList();

  /// Gets moves filtered by learn method.
  List<PokemonMove> getMovesByMethod(String method) {
    return moves.where((m) => m.learnMethod == method).toList();
  }

  /// Gets level-up moves sorted by level.
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

  /// Gets TM/HM moves sorted by name.
  List<PokemonMove> get machineMoves {
    final filtered = getMovesByMethod('machine');
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  /// Gets egg moves sorted by name.
  List<PokemonMove> get eggMoves {
    final filtered = getMovesByMethod('egg');
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  /// Gets tutor moves sorted by name.
  List<PokemonMove> get tutorMoves {
    final filtered = getMovesByMethod('tutor');
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  /// Creates a copy with updated values.
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
