import '../../pokemon_list/domain/pokemon.dart';
import 'game_achievement.dart';

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
