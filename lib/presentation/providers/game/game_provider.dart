import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/game/game_local_datasource.dart';
import '../../../domain/entities/game/game_state.dart';
import '../../../domain/entities/game/game_score.dart';
import '../../../domain/entities/game/game_achievement.dart';
import '../../../domain/entities/pokemon.dart';
import '../pokemon_list_provider.dart';

/// Provider para el data source local del juego.
final gameLocalDataSourceProvider = Provider<GameLocalDataSource>((ref) {
  return GameLocalDataSource();
});

/// Provider para el estado del juego "¿Quién es este Pokémon?".
final gameProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final dataSource = ref.watch(gameLocalDataSourceProvider);
  final pokemonState = ref.watch(pokemonListProvider);
  return GameNotifier(dataSource, pokemonState.pokemons);
});

/// Provider para la lista de logros.
final achievementsProvider = FutureProvider<List<GameAchievement>>((ref) async {
  final dataSource = ref.watch(gameLocalDataSourceProvider);
  await dataSource.initialize();
  return dataSource.getAchievements();
});

/// Provider para el ranking de puntuaciones.
final rankingProvider = FutureProvider<List<GameScore>>((ref) async {
  final dataSource = ref.watch(gameLocalDataSourceProvider);
  await dataSource.initialize();
  return dataSource.getRanking();
});

/// Provider para la mejor puntuación.
final highScoreProvider = FutureProvider<int>((ref) async {
  final dataSource = ref.watch(gameLocalDataSourceProvider);
  await dataSource.initialize();
  return dataSource.getHighScore();
});

/// Provider para estadísticas del juego.
final gameStatsProvider = FutureProvider<GameStats>((ref) async {
  final dataSource = ref.watch(gameLocalDataSourceProvider);
  await dataSource.initialize();
  
  final totalGames = await dataSource.getTotalGames();
  final totalCorrect = await dataSource.getTotalCorrect();
  final bestStreak = await dataSource.getBestStreakEver();
  final highScore = await dataSource.getHighScore();
  final unlockedCount = await dataSource.getUnlockedAchievementsCount();
  
  return GameStats(
    totalGames: totalGames,
    totalCorrect: totalCorrect,
    bestStreak: bestStreak,
    highScore: highScore,
    unlockedAchievements: unlockedCount,
  );
});

/// Clase que contiene las estadísticas del juego.
class GameStats {
  final int totalGames;
  final int totalCorrect;
  final int bestStreak;
  final int highScore;
  final int unlockedAchievements;

  const GameStats({
    required this.totalGames,
    required this.totalCorrect,
    required this.bestStreak,
    required this.highScore,
    required this.unlockedAchievements,
  });
}

/// Notifier para manejar el estado del juego.
class GameNotifier extends StateNotifier<GameState> {
  final GameLocalDataSource _dataSource;
  final List<Pokemon> _availablePokemons;
  final Random _random = Random();
  
  Timer? _timer;
  final Stopwatch _questionStopwatch = Stopwatch();
  
  /// Total de preguntas por partida.
  static const int _questionsPerGame = 10;
  
  /// Tiempo máximo por pregunta en segundos.
  static const int _maxTimePerQuestion = 15;
  
  /// Puntos por respuesta correcta.
  static const int _pointsPerCorrect = 10;
  
  /// Bonus por respuesta rápida (menos de 5 segundos).
  static const int _timeBonusPoints = 5;
  
  /// Threshold para bonus de tiempo en segundos.
  static const double _timeBonusThreshold = 5.0;
  
  /// Threshold para logro de respuesta rápida en segundos.
  static const double _fastAnswerThreshold = 3.0;

  GameNotifier(this._dataSource, this._availablePokemons)
      : super(const GameState());

  /// Inicializa el juego cargando datos persistidos.
  Future<void> initialize() async {
    await _dataSource.initialize();
    final highScore = await _dataSource.getHighScore();
    state = GameState.initial(highScore: highScore);
  }

  /// Inicia una nueva partida.
  Future<void> startGame() async {
    await _dataSource.initialize();
    final highScore = await _dataSource.getHighScore();
    
    state = GameState(
      status: GameStatus.playing,
      currentQuestion: 0,
      totalQuestions: _questionsPerGame,
      score: 0,
      correctAnswers: 0,
      currentStreak: 0,
      bestStreak: 0,
      remainingTimeSeconds: _maxTimePerQuestion,
      maxTimeSeconds: _maxTimePerQuestion,
      highScore: highScore,
      fastAnswersCount: 0,
    );
    
    await _nextQuestion();
  }

  /// Avanza a la siguiente pregunta.
  Future<void> _nextQuestion() async {
    _stopTimer();
    
    if (state.currentQuestion >= state.totalQuestions) {
      await _endGame();
      return;
    }
    
    // Seleccionar un Pokémon aleatorio
    final pokemon = _selectRandomPokemon();
    if (pokemon == null) {
      // Si no hay Pokémon disponibles, terminar el juego
      await _endGame();
      return;
    }
    
    // Generar opciones de respuesta
    final options = _generateAnswerOptions(pokemon);
    
    state = state.copyWith(
      status: GameStatus.waitingAnswer,
      currentPokemon: pokemon,
      answerOptions: options,
      selectedAnswerIndex: -1,
      currentQuestion: state.currentQuestion + 1,
      remainingTimeSeconds: _maxTimePerQuestion,
      clearLastAnswer: true,
    );
    
    _questionStopwatch.reset();
    _questionStopwatch.start();
    _startTimer();
  }

  /// Selecciona un Pokémon aleatorio de los disponibles.
  Pokemon? _selectRandomPokemon() {
    if (_availablePokemons.isEmpty) return null;
    return _availablePokemons[_random.nextInt(_availablePokemons.length)];
  }

  /// Genera las 4 opciones de respuesta.
  List<Pokemon> _generateAnswerOptions(Pokemon correctPokemon) {
    final options = <Pokemon>[correctPokemon];
    final availableForOptions = _availablePokemons
        .where((p) => p.id != correctPokemon.id)
        .toList();
    
    // Mezclar y tomar 3 opciones incorrectas
    availableForOptions.shuffle(_random);
    options.addAll(availableForOptions.take(3));
    
    // Mezclar todas las opciones
    options.shuffle(_random);
    
    return options;
  }

  /// Procesa la respuesta del usuario.
  Future<void> submitAnswer(int selectedIndex) async {
    if (state.status != GameStatus.waitingAnswer) return;
    if (selectedIndex < 0 || selectedIndex >= state.answerOptions.length) return;
    
    _stopTimer();
    _questionStopwatch.stop();
    
    final selectedPokemon = state.answerOptions[selectedIndex];
    final isCorrect = selectedPokemon.id == state.currentPokemon?.id;
    
    // Calcular tiempo de respuesta usando Stopwatch para mayor precisión
    final answerTime = _questionStopwatch.elapsedMilliseconds / 1000.0;
    
    // Calcular puntos
    int pointsEarned = 0;
    int newFastAnswers = state.fastAnswersCount;
    
    if (isCorrect) {
      // Puntos base
      pointsEarned = _pointsPerCorrect;
      
      // Bonus de tiempo
      if (answerTime < _timeBonusThreshold) {
        pointsEarned += _timeBonusPoints;
      }
      
      // Multiplicador por racha
      final newStreak = state.currentStreak + 1;
      if (newStreak >= 3) {
        pointsEarned = (pointsEarned * 1.5).round();
      }
      
      // Contabilizar respuesta rápida para logro
      if (answerTime < _fastAnswerThreshold) {
        newFastAnswers++;
      }
    }
    
    final newCorrectAnswers = isCorrect
        ? state.correctAnswers + 1
        : state.correctAnswers;
    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    final newBestStreak = newStreak > state.bestStreak
        ? newStreak
        : state.bestStreak;
    
    state = state.copyWith(
      status: GameStatus.showingResult,
      selectedAnswerIndex: selectedIndex,
      score: state.score + pointsEarned,
      correctAnswers: newCorrectAnswers,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastAnswerCorrect: isCorrect,
      lastAnswerTimeSeconds: answerTime,
      fastAnswersCount: newFastAnswers,
    );
  }

  /// Maneja cuando se acaba el tiempo.
  void _handleTimeout() {
    if (state.status != GameStatus.waitingAnswer) return;
    
    _questionStopwatch.stop();
    
    state = state.copyWith(
      status: GameStatus.showingResult,
      selectedAnswerIndex: -1,
      currentStreak: 0,
      lastAnswerCorrect: false,
      lastAnswerTimeSeconds: _maxTimePerQuestion.toDouble(),
    );
  }

  /// Continúa a la siguiente pregunta después de mostrar el resultado.
  Future<void> continueToNextQuestion() async {
    if (state.status != GameStatus.showingResult) return;
    await _nextQuestion();
  }

  /// Finaliza la partida y guarda los resultados.
  Future<void> _endGame() async {
    _stopTimer();
    
    // Generar ID único para la partida
    final scoreId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Calcular tiempo total (aproximado)
    final totalTime = state.currentQuestion * _maxTimePerQuestion;
    
    // Crear entidad de puntuación
    final score = GameScore(
      id: scoreId,
      score: state.score,
      correctAnswers: state.correctAnswers,
      totalQuestions: state.totalQuestions,
      bestStreak: state.bestStreak,
      date: DateTime.now(),
      totalTimeSeconds: totalTime,
    );
    
    // Guardar puntuación
    await _dataSource.saveScore(score);
    
    // Verificar si es la primera partida
    final totalGames = await _dataSource.getTotalGames();
    final isFirstGame = totalGames == 1;
    
    // Verificar y desbloquear logros
    final newlyUnlocked = await _dataSource.checkAndUnlockAchievements(
      score: state.score,
      streak: state.bestStreak,
      fastAnswers: state.fastAnswersCount,
      isFirstGame: isFirstGame,
    );
    
    // Actualizar mejor puntuación
    final newHighScore = await _dataSource.getHighScore();
    
    state = state.copyWith(
      status: GameStatus.finished,
      newlyUnlockedAchievements: newlyUnlocked,
      highScore: newHighScore,
    );
  }

  /// Reinicia el juego al estado inicial.
  Future<void> resetToMenu() async {
    _stopTimer();
    final highScore = await _dataSource.getHighScore();
    state = GameState.initial(highScore: highScore);
  }

  /// Inicia el temporizador de la pregunta.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTimeSeconds <= 1) {
        _handleTimeout();
        return;
      }
      
      state = state.copyWith(
        remainingTimeSeconds: state.remainingTimeSeconds - 1,
      );
    });
  }

  /// Detiene el temporizador.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
