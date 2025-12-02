import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale) : localeName = Intl.canonicalizedLocale(locale.languageCode);

  final Locale locale;
  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  bool get _isSpanish => localeName.startsWith('es');

  String get appTitle => 'Pokédex Carbonica';

  String get whoIsPokemonTitle =>
      _isSpanish ? '¿Quién es este Pokémon?' : 'Who is this Pokémon?';

  String get whoIsPokemonDescription =>
      _isSpanish ? '¡Adivina el Pokémon\npor su silueta!' : 'Guess the Pokémon\nby its silhouette!';

  String get whoIsPokemonRules => _isSpanish
      ? '10 preguntas • 15 segundos cada una\n+10 puntos por acierto • Bonus por velocidad'
      : '10 questions • 15 seconds each\n+10 points per correct answer • Speed bonus';

  String highScoreLabel(Object score) =>
      _isSpanish ? 'Mejor puntuación: $score' : 'Best score: $score';

  String get startGame => _isSpanish ? 'INICIAR PARTIDA' : 'START GAME';

  String get viewRanking => _isSpanish ? 'Ver Ranking' : 'View Ranking';

  String get resultCorrect => _isSpanish ? '¡Correcto!' : 'Correct!';

  String get resultIncorrect => _isSpanish ? 'Incorrecto' : 'Incorrect';

  String resultAnswer(Object pokemonName) =>
      _isSpanish ? 'Es $pokemonName' : "It's $pokemonName";

  String answerOption(Object pokemonName) =>
      _isSpanish ? 'Opción de respuesta $pokemonName' : 'Answer option $pokemonName';

  String get timeBonus =>
      _isSpanish ? '¡Bonus de tiempo! +5 puntos' : 'Time bonus! +5 points';

  String timeElapsed(Object seconds) =>
      _isSpanish ? 'Tiempo: ${seconds}s' : 'Time: ${seconds}s';

  String get showResults => _isSpanish ? 'VER RESULTADOS' : 'VIEW RESULTS';

  String get nextQuestion => _isSpanish ? 'SIGUIENTE' : 'NEXT';

  String get exitGameTitle =>
      _isSpanish ? '¿Salir del juego?' : 'Exit the game?';

  String get exitGameMessage => _isSpanish
      ? 'Perderás el progreso de la partida actual.'
      : 'You will lose the current game progress.';

  String get cancel => _isSpanish ? 'CANCELAR' : 'CANCEL';

  String get exit => _isSpanish ? 'SALIR' : 'EXIT';

  String get timerLabel => _isSpanish ? 'Tiempo' : 'Time';

  String get scoreLabel => _isSpanish ? 'Puntos' : 'Points';

  String get questionLabel => _isSpanish ? 'Pregunta' : 'Question';

  String get streakLabel => _isSpanish ? 'Racha' : 'Streak';

  String get achievementsTitle => _isSpanish ? 'Logros' : 'Achievements';

  String get statsGames => _isSpanish ? 'Partidas' : 'Games';

  String get statsHits => _isSpanish ? 'Aciertos' : 'Correct';

  String get statsBestStreak => _isSpanish ? 'Mejor racha' : 'Best streak';

  String get statsAchievements => _isSpanish ? 'Logros' : 'Achievements';

  String get achievementsError =>
      _isSpanish ? 'Error al cargar logros' : 'Error loading achievements';

  String progressUnlocked(Object unlocked, Object total) => _isSpanish
      ? 'Progreso: $unlocked/$total logros desbloqueados'
      : 'Progress: $unlocked/$total achievements unlocked';

  String get rankingTitle => _isSpanish ? 'Ranking' : 'Ranking';

  String get resultsTitle => _isSpanish ? 'Resultados' : 'Results';

  String get newRecord => _isSpanish ? '¡NUEVO RÉCORD!' : 'NEW RECORD!';

  String get gameFinished =>
      _isSpanish ? 'PARTIDA FINALIZADA' : 'GAME FINISHED';

  String get pointsLabel => _isSpanish ? 'PUNTOS' : 'POINTS';

  String get statsAccuracy => _isSpanish ? 'Precisión' : 'Accuracy';

  String get unlockedAchievementsTitle =>
      _isSpanish ? 'Logros desbloqueados' : 'Unlocked achievements';

  String get menu => _isSpanish ? 'MENÚ' : 'MENU';

  String get play => _isSpanish ? 'JUGAR' : 'PLAY';

  String get rankingSectionTitle =>
      _isSpanish ? 'RANKING' : 'RANKING';

  String get errorLoadingRanking =>
      _isSpanish ? 'Error al cargar ranking' : 'Error loading ranking';

  String get noScores =>
      _isSpanish ? 'No hay puntuaciones aún' : 'No scores yet';

  String get playToRank =>
      _isSpanish ? '¡Juega para entrar en el ranking!' : 'Play to enter the ranking!';

  String scorePoints(Object points) =>
      _isSpanish ? '$points puntos' : '$points points';

  String unlockedOnDate(Object date) =>
      _isSpanish ? 'Desbloqueado el $date' : 'Unlocked on $date';

  String get achievementUnlockTitle =>
      _isSpanish ? '¡LOGRO DESBLOQUEADO!' : 'ACHIEVEMENT UNLOCKED!';

  String get great => _isSpanish ? '¡GENIAL!' : 'AWESOME!';

  String get languageButtonTooltip =>
      _isSpanish ? 'Cambiar idioma' : 'Change language';

  String languageButtonLabel(Object language) => _isSpanish
      ? 'Selector de idioma. Actual: $language'
      : 'Language selector. Current: $language';

  String get languageEnglish => _isSpanish ? 'Inglés' : 'English';

  String get languageSpanish => _isSpanish ? 'Español' : 'Spanish';

  String get achievementNoviceTrainerName =>
      _isSpanish ? 'Entrenador Novato' : 'Rookie Trainer';

  String get achievementConnoisseurName =>
      _isSpanish ? 'Conocedor' : 'Connoisseur';

  String get achievementPokemonMasterName =>
      _isSpanish ? 'Maestro Pokémon' : 'Pokémon Master';

  String get achievementSpeedsterName =>
      _isSpanish ? 'Velocista' : 'Speedster';

  String get achievementOnFireName => _isSpanish ? 'En Racha' : 'On Fire';

  String get achievementLegendName => _isSpanish ? 'Leyenda' : 'Legend';

  String get achievementNoviceTrainerDescription => _isSpanish
      ? 'Primera partida completada'
      : 'First completed game';

  String get achievementConnoisseurDescription =>
      _isSpanish ? '50 puntos en una partida' : '50 points in one game';

  String get achievementPokemonMasterDescription => _isSpanish
      ? '100 puntos en una partida'
      : '100 points in one game';

  String get achievementSpeedsterDescription => _isSpanish
      ? '5 respuestas correctas en menos de 3 segundos'
      : '5 correct answers under 3 seconds';

  String get achievementOnFireDescription => _isSpanish
      ? '10 respuestas correctas seguidas'
      : '10 correct answers in a row';

  String get achievementLegendDescription =>
      _isSpanish ? '200 puntos en una partida' : '200 points in one game';

  String get silhouetteHiddenLabel =>
      _isSpanish ? 'Silueta de Pokémon oculta' : 'Pokémon silhouette hidden';

  String get silhouetteRevealedLabel =>
      _isSpanish ? 'Imagen del Pokémon revelada' : 'Pokémon image revealed';

  String get languageToggle => _isSpanish ? 'Idioma' : 'Language';

  String get speedBonusLabel =>
      _isSpanish ? 'Bonus de velocidad' : 'Speed bonus';

  String get streakMultiplier => _isSpanish ? 'x1.5' : 'x1.5';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    Intl.defaultLocale = locale.languageCode;
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
