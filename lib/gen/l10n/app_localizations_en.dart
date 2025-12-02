// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pokédex Carbonica';

  @override
  String get whoIsPokemonTitle => 'Who is this Pokémon?';

  @override
  String get whoIsPokemonDescription => 'Guess the Pokémon\nby its silhouette!';

  @override
  String get whoIsPokemonRules =>
      '10 questions • 15 seconds each\n+10 points per correct answer • Speed bonus';

  @override
  String highScoreLabel(Object score) {
    return 'Best score: $score';
  }

  @override
  String get startGame => 'START GAME';

  @override
  String get viewRanking => 'View Ranking';

  @override
  String get resultCorrect => 'Correct!';

  @override
  String get resultIncorrect => 'Incorrect';

  @override
  String resultAnswer(Object pokemonName) {
    return 'It\'s $pokemonName';
  }

  @override
  String answerOption(Object pokemonName) {
    return 'Answer option $pokemonName';
  }

  @override
  String get timeBonus => 'Time bonus! +5 points';

  @override
  String timeElapsed(Object seconds) {
    return 'Time: ${seconds}s';
  }

  @override
  String get showResults => 'VIEW RESULTS';

  @override
  String get nextQuestion => 'NEXT';

  @override
  String get exitGameTitle => 'Exit the game?';

  @override
  String get exitGameMessage => 'You will lose the current game progress.';

  @override
  String get cancel => 'CANCEL';

  @override
  String get exit => 'EXIT';

  @override
  String get timerLabel => 'Time';

  @override
  String get scoreLabel => 'Points';

  @override
  String get questionLabel => 'Question';

  @override
  String get streakLabel => 'Streak';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get statsGames => 'Games';

  @override
  String get statsHits => 'Correct';

  @override
  String get statsBestStreak => 'Best streak';

  @override
  String get statsAchievements => 'Achievements';

  @override
  String get achievementsError => 'Error loading achievements';

  @override
  String progressUnlocked(Object unlocked, Object total) {
    return 'Progress: $unlocked/$total achievements unlocked';
  }

  @override
  String get rankingTitle => 'Ranking';

  @override
  String get resultsTitle => 'Results';

  @override
  String get newRecord => 'NEW RECORD!';

  @override
  String get gameFinished => 'GAME FINISHED';

  @override
  String get pointsLabel => 'POINTS';

  @override
  String get statsAccuracy => 'Accuracy';

  @override
  String get unlockedAchievementsTitle => 'Unlocked achievements';

  @override
  String get menu => 'MENU';

  @override
  String get play => 'PLAY';

  @override
  String get rankingSectionTitle => 'RANKING';

  @override
  String get errorLoadingRanking => 'Error loading ranking';

  @override
  String get noScores => 'No scores yet';

  @override
  String get playToRank => 'Play to enter the ranking!';

  @override
  String scorePoints(Object points) {
    return '$points points';
  }

  @override
  String unlockedOnDate(Object date) {
    return 'Unlocked on $date';
  }

  @override
  String get achievementUnlockTitle => 'ACHIEVEMENT UNLOCKED!';

  @override
  String get great => 'AWESOME!';

  @override
  String get languageButtonTooltip => 'Change language';

  @override
  String languageButtonLabel(Object language) {
    return 'Language selector. Current: $language';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get achievementNoviceTrainerName => 'Rookie Trainer';

  @override
  String get achievementConnoisseurName => 'Connoisseur';

  @override
  String get achievementPokemonMasterName => 'Pokémon Master';

  @override
  String get achievementSpeedsterName => 'Speedster';

  @override
  String get achievementOnFireName => 'On Fire';

  @override
  String get achievementLegendName => 'Legend';

  @override
  String get achievementNoviceTrainerDescription => 'First completed game';

  @override
  String get achievementConnoisseurDescription => '50 points in one game';

  @override
  String get achievementPokemonMasterDescription => '100 points in one game';

  @override
  String get achievementSpeedsterDescription =>
      '5 correct answers under 3 seconds';

  @override
  String get achievementOnFireDescription => '10 correct answers in a row';

  @override
  String get achievementLegendDescription => '200 points in one game';

  @override
  String get silhouetteHiddenLabel => 'Pokémon silhouette hidden';

  @override
  String get silhouetteRevealedLabel => 'Pokémon image revealed';

  @override
  String get languageToggle => 'Language';

  @override
  String get speedBonusLabel => 'Speed bonus';

  @override
  String get streakMultiplier => 'x1.5';
}
