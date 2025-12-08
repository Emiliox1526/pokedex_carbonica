/// Domain entity representing a Pokemon's stat.
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
}
