/// Domain models and entities for this feature.
///
/// Contains all business objects, value objects, and domain entities.

import 'package:flutter/material.dart';

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


extension GameAchievementLocalizations on GameAchievement {
  String localizedName(AppLocalizations l10n) {
    switch (type) {
      case AchievementType.noviceTrainer:
        return l10n.achievementNoviceTrainerName;
      case AchievementType.connoisseur:
        return l10n.achievementConnoisseurName;
      case AchievementType.pokemonMaster:
        return l10n.achievementPokemonMasterName;
      case AchievementType.speedster:
        return l10n.achievementSpeedsterName;
      case AchievementType.onFire:
        return l10n.achievementOnFireName;
      case AchievementType.legend:
        return l10n.achievementLegendName;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (type) {
      case AchievementType.noviceTrainer:
        return l10n.achievementNoviceTrainerDescription;
      case AchievementType.connoisseur:
        return l10n.achievementConnoisseurDescription;
      case AchievementType.pokemonMaster:
        return l10n.achievementPokemonMasterDescription;
      case AchievementType.speedster:
        return l10n.achievementSpeedsterDescription;
      case AchievementType.onFire:
        return l10n.achievementOnFireDescription;
      case AchievementType.legend:
        return l10n.achievementLegendDescription;
    }
  }
}

/// Entidad de dominio que representa una puntuación de partida.
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
}


/// Estado del juego "¿Quién es este Pokémon?".
enum GameStatus {
  /// Estado inicial, mostrando menú principal.
  initial,

  /// Partida en curso.
  playing,

  /// Esperando respuesta del usuario.
  waitingAnswer,

  /// Mostrando resultado de la respuesta.
  showingResult,

  /// Partida finalizada.
  finished,
}

/// Entidad que representa el estado actual de una partida.
///
/// Contiene toda la información necesaria para renderizar
/// la pantalla del juego y gestionar la lógica de la partida.
class GameState {
  /// Estado actual del juego.
  final GameStatus status;

  /// Pokémon actual a adivinar.
  final Pokemon? currentPokemon;

  /// Lista de opciones de respuesta (4 nombres de Pokémon).
  final List<Pokemon> answerOptions;

  /// Índice de la respuesta seleccionada (-1 si no hay selección).
  final int selectedAnswerIndex;

  /// Puntuación actual de la partida.
  final int score;

  /// Número de pregunta actual (1-10).
  final int currentQuestion;

  /// Total de preguntas por partida.
  final int totalQuestions;

  /// Número de respuestas correctas.
  final int correctAnswers;

  /// Racha actual de aciertos consecutivos.
  final int currentStreak;

  /// Mejor racha de la partida.
  final int bestStreak;

  /// Tiempo restante en segundos para la pregunta actual.
  final int remainingTimeSeconds;

  /// Tiempo máximo por pregunta.
  final int maxTimeSeconds;

  /// Si la última respuesta fue correcta.
  final bool? lastAnswerCorrect;

  /// Tiempo que tardó en responder la última pregunta.
  final double? lastAnswerTimeSeconds;

  /// Logros desbloqueados en esta partida.
  final List<GameAchievement> newlyUnlockedAchievements;

  /// Mejor puntuación histórica.
  final int highScore;

  /// Contador de respuestas rápidas (menos de 3 segundos).
  final int fastAnswersCount;

  /// Constructor del estado de juego.
  const GameState({
    this.status = GameStatus.initial,
    this.currentPokemon,
    this.answerOptions = const [],
    this.selectedAnswerIndex = -1,
    this.score = 0,
    this.currentQuestion = 0,
    this.totalQuestions = 10,
    this.correctAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.remainingTimeSeconds = 15,
    this.maxTimeSeconds = 15,
    this.lastAnswerCorrect,
    this.lastAnswerTimeSeconds,
    this.newlyUnlockedAchievements = const [],
    this.highScore = 0,
    this.fastAnswersCount = 0,
  });

  /// Crea una copia del estado con valores actualizados.
  GameState copyWith({
    GameStatus? status,
    Pokemon? currentPokemon,
    List<Pokemon>? answerOptions,
    int? selectedAnswerIndex,
    int? score,
    int? currentQuestion,
    int? totalQuestions,
    int? correctAnswers,
    int? currentStreak,
    int? bestStreak,
    int? remainingTimeSeconds,
    int? maxTimeSeconds,
    bool? lastAnswerCorrect,
    double? lastAnswerTimeSeconds,
    List<GameAchievement>? newlyUnlockedAchievements,
    int? highScore,
    int? fastAnswersCount,
    bool clearCurrentPokemon = false,
    bool clearLastAnswer = false,
  }) {
    return GameState(
      status: status ?? this.status,
      currentPokemon:
          clearCurrentPokemon ? null : (currentPokemon ?? this.currentPokemon),
      answerOptions: answerOptions ?? this.answerOptions,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
      score: score ?? this.score,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      remainingTimeSeconds: remainingTimeSeconds ?? this.remainingTimeSeconds,
      maxTimeSeconds: maxTimeSeconds ?? this.maxTimeSeconds,
      lastAnswerCorrect:
          clearLastAnswer ? null : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      lastAnswerTimeSeconds: clearLastAnswer
          ? null
          : (lastAnswerTimeSeconds ?? this.lastAnswerTimeSeconds),
      newlyUnlockedAchievements:
          newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
      highScore: highScore ?? this.highScore,
      fastAnswersCount: fastAnswersCount ?? this.fastAnswersCount,
    );
  }

  /// Indica si el juego está en curso.
  bool get isPlaying =>
      status == GameStatus.playing || status == GameStatus.waitingAnswer;

  /// Indica si se puede mostrar el resultado.
  bool get canShowResult => status == GameStatus.showingResult;

  /// Indica si la partida ha terminado.
  bool get isFinished => status == GameStatus.finished;

  /// Progreso de la partida (0.0 - 1.0).
  double get progress =>
      totalQuestions > 0 ? currentQuestion / totalQuestions : 0;

  /// Progreso del tiempo restante (0.0 - 1.0).
  double get timeProgress =>
      maxTimeSeconds > 0 ? remainingTimeSeconds / maxTimeSeconds : 0;

  /// Multiplicador de puntuación actual.
  double get streakMultiplier => currentStreak >= 3 ? 1.5 : 1.0;

  /// Indica si hay bonus de tiempo disponible.
  bool get hasTimeBonus =>
      lastAnswerTimeSeconds != null && lastAnswerTimeSeconds! < 5;

  /// Índice de la respuesta correcta.
  int get correctAnswerIndex {
    if (currentPokemon == null) return -1;
    return answerOptions
        .indexWhere((p) => p.id == currentPokemon!.id);
  }

  /// Estado inicial del juego.
  factory GameState.initial({int highScore = 0}) {
    return GameState(highScore: highScore);
  }

  @override
  String toString() =>
      'GameState(status: $status, question: $currentQuestion/$totalQuestions, score: $score)';
}

