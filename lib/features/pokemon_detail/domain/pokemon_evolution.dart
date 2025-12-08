/// Domain entity representing a Pokemon in the evolution chain.
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
}
