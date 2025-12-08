import 'package:hive/hive.dart';

import '../domain/game_score.dart';

part 'game_score_dto.g.dart';

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
