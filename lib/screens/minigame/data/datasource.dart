/// Data sources and DTOs for this feature.
///
/// Consolidates all data transfer objects, local and remote data sources.

import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/model.dart';

part 'datasource.g.dart';




/// Data Transfer Object para persistir logros con Hive.
///
/// Esta clase mapea la entidad GameAchievement para almacenamiento local.
@HiveType(typeId: GameAchievementDTO.hiveTypeId)
class GameAchievementDTO {
  /// Hive type ID for this DTO.
  static const int hiveTypeId = 2;

  /// Tipo de logro (como string para persistencia).
  @HiveField(0)
  final String type;

  /// Indica si el logro está desbloqueado.
  @HiveField(1)
  final bool isUnlocked;

  /// Timestamp de desbloqueo en milisegundos (null si no desbloqueado).
  @HiveField(2)
  final int? unlockedDateTimestamp;

  /// Constructor del DTO.
  const GameAchievementDTO({
    required this.type,
    required this.isUnlocked,
    this.unlockedDateTimestamp,
  });

  /// Crea un DTO a partir de una entidad de dominio.
  factory GameAchievementDTO.fromEntity(GameAchievement entity) {
    return GameAchievementDTO(
      type: entity.type.name,
      isUnlocked: entity.isUnlocked,
      unlockedDateTimestamp: entity.unlockedDate?.millisecondsSinceEpoch,
    );
  }

  /// Convierte el DTO a una entidad de dominio.
  GameAchievement toEntity() {
    return GameAchievement(
      type: _parseAchievementType(type),
      isUnlocked: isUnlocked,
      unlockedDate: unlockedDateTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(unlockedDateTimestamp!)
          : null,
    );
  }

  /// Parsea el string a AchievementType.
  /// Throws [ArgumentError] if the type is unknown to aid debugging.
  static AchievementType _parseAchievementType(String type) {
    switch (type) {
      case 'noviceTrainer':
        return AchievementType.noviceTrainer;
      case 'connoisseur':
        return AchievementType.connoisseur;
      case 'pokemonMaster':
        return AchievementType.pokemonMaster;
      case 'speedster':
        return AchievementType.speedster;
      case 'onFire':
        return AchievementType.onFire;
      case 'legend':
        return AchievementType.legend;
      default:
        // Log warning for unknown types but don't crash the app
        assert(() {
          debugPrint('Warning: Unknown achievement type: $type');
          return true;
        }());
        return AchievementType.noviceTrainer;
    }
  }

  /// Convierte el DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'isUnlocked': isUnlocked,
      'unlockedDateTimestamp': unlockedDateTimestamp,
    };
  }

  /// Crea un DTO a partir de un mapa JSON.
  factory GameAchievementDTO.fromJson(Map<String, dynamic> json) {
    return GameAchievementDTO(
      type: json['type'] as String,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedDateTimestamp: json['unlockedDateTimestamp'] as int?,
    );
  }

  @override
  String toString() =>
      'GameAchievementDTO(type: $type, unlocked: $isUnlocked)';
}




/// Data Transfer Object para persistir puntuaciones con Hive.
///
/// Esta clase mapea la entidad GameScore para almacenamiento local.
@HiveType(typeId: GameScoreDTO.hiveTypeId)
class GameScoreDTO {
  /// Hive type ID for this DTO.
  static const int hiveTypeId = 1;

  /// Identificador único de la puntuación.
  @HiveField(0)
  final String id;

  /// Puntuación total obtenida.
  @HiveField(1)
  final int score;

  /// Número de respuestas correctas.
  @HiveField(2)
  final int correctAnswers;

  /// Número total de preguntas.
  @HiveField(3)
  final int totalQuestions;

  /// Mejor racha de aciertos consecutivos.
  @HiveField(4)
  final int bestStreak;

  /// Timestamp de la partida en milisegundos.
  @HiveField(5)
  final int dateTimestamp;

  /// Tiempo total de juego en segundos.
  @HiveField(6)
  final int totalTimeSeconds;

  /// Constructor del DTO.
  const GameScoreDTO({
    required this.id,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.bestStreak,
    required this.dateTimestamp,
    required this.totalTimeSeconds,
  });

  /// Crea un DTO a partir de una entidad de dominio.
  factory GameScoreDTO.fromEntity(GameScore entity) {
    return GameScoreDTO(
      id: entity.id,
      score: entity.score,
      correctAnswers: entity.correctAnswers,
      totalQuestions: entity.totalQuestions,
      bestStreak: entity.bestStreak,
      dateTimestamp: entity.date.millisecondsSinceEpoch,
      totalTimeSeconds: entity.totalTimeSeconds,
    );
  }

  /// Convierte el DTO a una entidad de dominio.
  GameScore toEntity() {
    return GameScore(
      id: id,
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      bestStreak: bestStreak,
      date: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
      totalTimeSeconds: totalTimeSeconds,
    );
  }

  /// Convierte el DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'bestStreak': bestStreak,
      'dateTimestamp': dateTimestamp,
      'totalTimeSeconds': totalTimeSeconds,
    };
  }

  /// Crea un DTO a partir de un mapa JSON.
  factory GameScoreDTO.fromJson(Map<String, dynamic> json) {
    return GameScoreDTO(
      id: json['id'] as String,
      score: json['score'] as int,
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      bestStreak: json['bestStreak'] as int,
      dateTimestamp: json['dateTimestamp'] as int,
      totalTimeSeconds: json['totalTimeSeconds'] as int,
    );
  }

  @override
  String toString() =>
      'GameScoreDTO(id: $id, score: $score, correct: $correctAnswers/$totalQuestions)';
}



/// Data source local para persistencia del juego "¿Quién es este Pokémon?".
///
/// Maneja el almacenamiento de puntuaciones, logros y estadísticas
/// utilizando Hive para persistencia local.
class GameLocalDataSource {
  /// Nombre de la caja de Hive para puntuaciones.
  static const String _scoresBoxName = 'game_scores';

  /// Nombre de la caja de Hive para logros.
  static const String _achievementsBoxName = 'game_achievements';

  /// Nombre de la caja de Hive para estadísticas.
  static const String _statsBoxName = 'game_stats';

  /// Máximo de partidas en el historial.
  static const int _maxHistorySize = 50;

  /// Máximo de puntuaciones en el ranking.
  static const int _maxRankingSize = 10;

  /// Clave para mejor puntuación.
  static const String _highScoreKey = 'high_score';

  /// Clave para total de partidas.
  static const String _totalGamesKey = 'total_games';

  /// Clave para total de aciertos.
  static const String _totalCorrectKey = 'total_correct';

  /// Clave para mejor racha histórica.
  static const String _bestStreakEverKey = 'best_streak_ever';

  /// Caja de Hive para puntuaciones.
  Box<GameScoreDTO>? _scoresBox;

  /// Caja de Hive para logros.
  Box<GameAchievementDTO>? _achievementsBox;

  /// Caja de Hive para estadísticas.
  Box<dynamic>? _statsBox;

  /// Inicializa el data source.
  ///
  /// Debe llamarse antes de usar cualquier método.
  Future<void> initialize() async {
    if (_scoresBox != null &&
        _achievementsBox != null &&
        _statsBox != null) {
      return;
    }

    // Los adaptadores se registran en main.dart
    _scoresBox = await Hive.openBox<GameScoreDTO>(_scoresBoxName);
    _achievementsBox = await Hive.openBox<GameAchievementDTO>(_achievementsBoxName);
    _statsBox = await Hive.openBox<dynamic>(_statsBoxName);

    // Inicializar logros si no existen
    await _initializeAchievements();
  }

  /// Inicializa los logros si no existen en el almacenamiento.
  Future<void> _initializeAchievements() async {
    await _ensureInitialized();

    for (final type in AchievementType.values) {
      final key = 'achievement_${type.name}';
      if (!_achievementsBox!.containsKey(key)) {
        await _achievementsBox!.put(
          key,
          GameAchievementDTO(
            type: type.name,
            isUnlocked: false,
          ),
        );
      }
    }
  }

  /// Guarda una puntuación de partida.
  ///
  /// Actualiza el historial, ranking y estadísticas globales.
  Future<void> saveScore(GameScore score) async {
    await _ensureInitialized();

    // Guardar en historial
    final dto = GameScoreDTO.fromEntity(score);
    await _scoresBox!.put('score_${score.id}', dto);

    // Limitar historial
    await _trimHistory();

    // Actualizar estadísticas globales
    await _updateGlobalStats(score);
  }

  /// Obtiene el historial de partidas (últimas 50).
  Future<List<GameScore>> getHistory() async {
    await _ensureInitialized();

    final scores = _scoresBox!.values
.map((dto) => dto.toEntity())
.toList();

    // Ordenar por fecha descendente
    scores.sort((a, b) => b.date.compareTo(a.date));

    return scores.take(_maxHistorySize).toList();
  }

  /// Obtiene el ranking de mejores puntuaciones (Top 10).
  Future<List<GameScore>> getRanking() async {
    await _ensureInitialized();

    final scores = _scoresBox!.values
.map((dto) => dto.toEntity())
.toList();

    // Ordenar por puntuación descendente
    scores.sort((a, b) => b.score.compareTo(a.score));

    return scores.take(_maxRankingSize).toList();
  }

  /// Obtiene la mejor puntuación histórica.
  Future<int> getHighScore() async {
    await _ensureInitialized();
    return _statsBox!.get(_highScoreKey, defaultValue: 0) as int;
  }

  /// Obtiene el total de partidas jugadas.
  Future<int> getTotalGames() async {
    await _ensureInitialized();
    return _statsBox!.get(_totalGamesKey, defaultValue: 0) as int;
  }

  /// Obtiene el total de respuestas correctas históricas.
  Future<int> getTotalCorrect() async {
    await _ensureInitialized();
    return _statsBox!.get(_totalCorrectKey, defaultValue: 0) as int;
  }

  /// Obtiene la mejor racha histórica.
  Future<int> getBestStreakEver() async {
    await _ensureInitialized();
    return _statsBox!.get(_bestStreakEverKey, defaultValue: 0) as int;
  }

  /// Obtiene todos los logros.
  Future<List<GameAchievement>> getAchievements() async {
    await _ensureInitialized();

    return _achievementsBox!.values
.map((dto) => dto.toEntity())
.toList();
  }

  /// Obtiene un logro específico.
  Future<GameAchievement?> getAchievement(AchievementType type) async {
    await _ensureInitialized();

    final dto = _achievementsBox!.get('achievement_${type.name}');
    return dto?.toEntity();
  }

  /// Desbloquea un logro.
  ///
  /// Retorna true si el logro fue desbloqueado (no estaba desbloqueado antes).
  Future<bool> unlockAchievement(AchievementType type) async {
    await _ensureInitialized();

    final key = 'achievement_${type.name}';
    final existing = _achievementsBox!.get(key);

    // Si ya está desbloqueado, no hacer nada
    if (existing != null && existing.isUnlocked) {
      return false;
    }

    // Desbloquear
    await _achievementsBox!.put(
      key,
      GameAchievementDTO(
        type: type.name,
        isUnlocked: true,
        unlockedDateTimestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    return true;
  }

  /// Verifica qué logros deben desbloquearse basado en el score.
  ///
  /// Retorna la lista de logros recién desbloqueados.
  Future<List<GameAchievement>> checkAndUnlockAchievements({
    required int score,
    required int streak,
    required int fastAnswers,
    required bool isFirstGame,
  }) async {
    await _ensureInitialized();

    final newlyUnlocked = <GameAchievement>[];

    // Primera partida completada
    if (isFirstGame) {
      if (await unlockAchievement(AchievementType.noviceTrainer)) {
        final achievement = await getAchievement(AchievementType.noviceTrainer);
        if (achievement != null) newlyUnlocked.add(achievement);
      }
    }

    // 50 puntos
    if (score >= 50) {
      if (await unlockAchievement(AchievementType.connoisseur)) {
        final achievement = await getAchievement(AchievementType.connoisseur);
        if (achievement != null) newlyUnlocked.add(achievement);
      }
    }

    // 100 puntos
    if (score >= 100) {
      if (await unlockAchievement(AchievementType.pokemonMaster)) {
        final achievement = await getAchievement(AchievementType.pokemonMaster);
        if (achievement != null) newlyUnlocked.add(achievement);
      }
    }

    // 200 puntos
    if (score >= 200) {
      if (await unlockAchievement(AchievementType.legend)) {
        final achievement = await getAchievement(AchievementType.legend);
        if (achievement != null) newlyUnlocked.add(achievement);
      }
    }

    // 10 aciertos seguidos
    if (streak >= 10) {
      if (await unlockAchievement(AchievementType.onFire)) {
        final achievement = await getAchievement(AchievementType.onFire);
        if (achievement != null) newlyUnlocked.add(achievement);
      }
    }

    // 5 respuestas rápidas
    if (fastAnswers >= 5) {
      if (await unlockAchievement(AchievementType.speedster)) {
        final achievement = await getAchievement(AchievementType.speedster);
        if (achievement != null) newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// Obtiene el número de logros desbloqueados.
  Future<int> getUnlockedAchievementsCount() async {
    await _ensureInitialized();

    return _achievementsBox!.values
.where((dto) => dto.isUnlocked)
.length;
  }

  /// Limpia todos los datos del juego.
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _scoresBox!.clear();
    await _achievementsBox!.clear();
    await _statsBox!.clear();
    await _initializeAchievements();
  }

  /// Limita el historial al tamaño máximo.
  Future<void> _trimHistory() async {
    final allKeys = _scoresBox!.keys.toList();
    if (allKeys.length <= _maxHistorySize) return;

    // Ordenar por fecha y eliminar los más antiguos
    final scores = _scoresBox!.values.toList();
    scores.sort((a, b) => a.dateTimestamp.compareTo(b.dateTimestamp));

    final toRemove = scores.take(allKeys.length - _maxHistorySize);
    for (final score in toRemove) {
      await _scoresBox!.delete('score_${score.id}');
    }
  }

  /// Actualiza las estadísticas globales con una nueva puntuación.
  Future<void> _updateGlobalStats(GameScore score) async {
    // Actualizar mejor puntuación
    final currentHigh = await getHighScore();
    if (score.score > currentHigh) {
      await _statsBox!.put(_highScoreKey, score.score);
    }

    // Actualizar total de partidas
    final totalGames = await getTotalGames();
    await _statsBox!.put(_totalGamesKey, totalGames + 1);

    // Actualizar total de aciertos
    final totalCorrect = await getTotalCorrect();
    await _statsBox!.put(_totalCorrectKey, totalCorrect + score.correctAnswers);

    // Actualizar mejor racha
    final bestStreak = await getBestStreakEver();
    if (score.bestStreak > bestStreak) {
      await _statsBox!.put(_bestStreakEverKey, score.bestStreak);
    }
  }

  /// Asegura que el data source esté inicializado.
  Future<void> _ensureInitialized() async {
    if (_scoresBox == null ||
        _achievementsBox == null ||
        _statsBox == null) {
      await initialize();
    }
  }
}

