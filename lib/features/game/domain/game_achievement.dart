/// Tipos de logros disponibles en el juego.
enum AchievementType {
  /// Primera partida completada.
  noviceTrainer,

  /// 50 puntos en una partida.
  connoisseur,

  /// 100 puntos en una partida.
  pokemonMaster,

  /// 5 respuestas correctas en menos de 3 segundos cada una.
  speedster,

  /// 10 respuestas correctas seguidas.
  onFire,

  /// 200 puntos en una partida.
  legend,
}

/// Entidad de dominio que representa un logro del juego.
///
/// Los logros se desbloquean al cumplir ciertas condiciones
/// durante las partidas del juego "¿Quién es este Pokémon?".
class GameAchievement {
  /// Tipo de logro.
  final AchievementType type;

  /// Indica si el logro está desbloqueado.
  final bool isUnlocked;

  /// Fecha de desbloqueo (null si no está desbloqueado).
  final DateTime? unlockedDate;

  /// Constructor de la entidad GameAchievement.
  const GameAchievement({
    required this.type,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  /// Nombre del logro para mostrar.
  String get name {
    switch (type) {
      case AchievementType.noviceTrainer:
        return 'Entrenador Novato';
      case AchievementType.connoisseur:
        return 'Conocedor';
      case AchievementType.pokemonMaster:
        return 'Maestro Pokémon';
      case AchievementType.speedster:
        return 'Velocista';
      case AchievementType.onFire:
        return 'En Racha';
      case AchievementType.legend:
        return 'Leyenda';
    }
  }

  /// Descripción del logro.
  String get description {
    switch (type) {
      case AchievementType.noviceTrainer:
        return 'Primera partida completada';
      case AchievementType.connoisseur:
        return '50 puntos en una partida';
      case AchievementType.pokemonMaster:
        return '100 puntos en una partida';
      case AchievementType.speedster:
        return '5 respuestas correctas en menos de 3 segundos';
      case AchievementType.onFire:
        return '10 respuestas correctas seguidas';
      case AchievementType.legend:
        return '200 puntos en una partida';
    }
  }

  /// Emoji/icono del logro.
  String get icon {
    switch (type) {
      case AchievementType.noviceTrainer:
        return '🥉';
      case AchievementType.connoisseur:
        return '🥈';
      case AchievementType.pokemonMaster:
        return '🥇';
      case AchievementType.speedster:
        return '⚡';
      case AchievementType.onFire:
        return '🔥';
      case AchievementType.legend:
        return '👑';
    }
  }

  /// Puntos requeridos para el logro (si aplica).
  int? get requiredScore {
    switch (type) {
      case AchievementType.connoisseur:
        return 50;
      case AchievementType.pokemonMaster:
        return 100;
      case AchievementType.legend:
        return 200;
      default:
        return null;
    }
  }

  /// Crea una copia del logro con el estado desbloqueado.
  GameAchievement unlock() {
    return GameAchievement(
      type: type,
      isUnlocked: true,
      unlockedDate: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAchievement &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'GameAchievement(type: $type, unlocked: $isUnlocked)';
}
