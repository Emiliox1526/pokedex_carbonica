// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pokédex Carbonica';

  @override
  String get whoIsPokemonTitle => '¿Quién es este Pokémon?';

  @override
  String get whoIsPokemonDescription => '¡Adivina el Pokémon\npor su silueta!';

  @override
  String get whoIsPokemonRules =>
      '10 preguntas • 15 segundos cada una\n+10 puntos por acierto • Bonus por velocidad';

  @override
  String highScoreLabel(Object score) {
    return 'Mejor puntuación: $score';
  }

  @override
  String get startGame => 'INICIAR PARTIDA';

  @override
  String get viewRanking => 'Ver Ranking';

  @override
  String get resultCorrect => '¡Correcto!';

  @override
  String get resultIncorrect => 'Incorrecto';

  @override
  String resultAnswer(Object pokemonName) {
    return 'Es $pokemonName';
  }

  @override
  String answerOption(Object pokemonName) {
    return 'Opción de respuesta $pokemonName';
  }

  @override
  String get timeBonus => '¡Bonus de tiempo! +5 puntos';

  @override
  String timeElapsed(Object seconds) {
    return 'Tiempo: ${seconds}s';
  }

  @override
  String get showResults => 'VER RESULTADOS';

  @override
  String get nextQuestion => 'SIGUIENTE';

  @override
  String get exitGameTitle => '¿Salir del juego?';

  @override
  String get exitGameMessage => 'Perderás el progreso de la partida actual.';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get exit => 'SALIR';

  @override
  String get timerLabel => 'Tiempo';

  @override
  String get scoreLabel => 'Puntos';

  @override
  String get questionLabel => 'Pregunta';

  @override
  String get streakLabel => 'Racha';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String get statsGames => 'Partidas';

  @override
  String get statsHits => 'Aciertos';

  @override
  String get statsBestStreak => 'Mejor racha';

  @override
  String get statsAchievements => 'Logros';

  @override
  String get achievementsError => 'Error al cargar logros';

  @override
  String progressUnlocked(Object unlocked, Object total) {
    return 'Progreso: $unlocked/$total logros desbloqueados';
  }

  @override
  String get rankingTitle => 'Ranking';

  @override
  String get resultsTitle => 'Resultados';

  @override
  String get newRecord => '¡NUEVO RÉCORD!';

  @override
  String get gameFinished => 'PARTIDA FINALIZADA';

  @override
  String get pointsLabel => 'PUNTOS';

  @override
  String get statsAccuracy => 'Precisión';

  @override
  String get unlockedAchievementsTitle => 'Logros desbloqueados';

  @override
  String get menu => 'MENÚ';

  @override
  String get play => 'JUGAR';

  @override
  String get rankingSectionTitle => 'RANKING';

  @override
  String get errorLoadingRanking => 'Error al cargar ranking';

  @override
  String get noScores => 'No hay puntuaciones aún';

  @override
  String get playToRank => '¡Juega para entrar en el ranking!';

  @override
  String scorePoints(Object points) {
    return '$points puntos';
  }

  @override
  String unlockedOnDate(Object date) {
    return 'Desbloqueado el $date';
  }

  @override
  String get achievementUnlockTitle => '¡LOGRO DESBLOQUEADO!';

  @override
  String get great => '¡GENIAL!';

  @override
  String get languageButtonTooltip => 'Cambiar idioma';

  @override
  String languageButtonLabel(Object language) {
    return 'Selector de idioma. Actual: $language';
  }

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get achievementNoviceTrainerName => 'Entrenador Novato';

  @override
  String get achievementConnoisseurName => 'Conocedor';

  @override
  String get achievementPokemonMasterName => 'Maestro Pokémon';

  @override
  String get achievementSpeedsterName => 'Velocista';

  @override
  String get achievementOnFireName => 'En Racha';

  @override
  String get achievementLegendName => 'Leyenda';

  @override
  String get achievementNoviceTrainerDescription =>
      'Primera partida completada';

  @override
  String get achievementConnoisseurDescription => '50 puntos en una partida';

  @override
  String get achievementPokemonMasterDescription => '100 puntos en una partida';

  @override
  String get achievementSpeedsterDescription =>
      '5 respuestas correctas en menos de 3 segundos';

  @override
  String get achievementOnFireDescription => '10 respuestas correctas seguidas';

  @override
  String get achievementLegendDescription => '200 puntos en una partida';

  @override
  String get silhouetteHiddenLabel => 'Silueta de Pokémon oculta';

  @override
  String get silhouetteRevealedLabel => 'Imagen del Pokémon revelada';

  @override
  String get languageToggle => 'Idioma';

  @override
  String get speedBonusLabel => 'Bonus de velocidad';

  @override
  String get streakMultiplier => 'x1.5';
}
