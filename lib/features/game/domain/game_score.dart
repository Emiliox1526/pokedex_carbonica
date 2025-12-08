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
