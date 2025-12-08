/// Domain models for the minigame feature.
///
/// This file contains all entities, value objects, and domain models.

\n\n/// Tipos de logros disponibles en el juego.
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
}\n\n\n\n/// Entidad de dominio que representa una puntuación de partida.
///
/// Esta clase almacena los resultados de una partida del juego
/// "¿Quién es este Pokémon?" incluyendo puntuación, aciertos y fecha.
class GameScore {
  /// Identificador único de la puntuación.
  final String id;

  /// Puntuación total obtenida.
  final int score;

  /// Número de respuestas correctas.
  final int correctAnswers;

  /// Número total de preguntas.
  final int totalQuestions;

  /// Mejor racha de aciertos consecutivos.
  final int bestStreak;

  /// Fecha y hora de la partida.
  final DateTime date;

  /// Tiempo total de juego en segundos.
  final int totalTimeSeconds;

  /// Constructor de la entidad GameScore.
  const GameScore({
    required this.id,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.bestStreak,
    required this.date,
    required this.totalTimeSeconds,
  });

  /// Porcentaje de aciertos.
  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  /// Fecha formateada para mostrar.
  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  /// Tiempo formateado en formato mm:ss.
  String get formattedTime {
    final minutes = totalTimeSeconds ~/ 60;
    final seconds = totalTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameScore && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GameScore(id: $id, score: $score, correct: $correctAnswers/$totalQuestions)';
}\n\n