/// Domain entity representing a Pokemon's move.
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
}
