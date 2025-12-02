/// Domain entity representing a Pokemon's ability.
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
}
