import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokédex Carbonica'**
  String get appTitle;

  /// No description provided for @whoIsPokemonTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is this Pokémon?'**
  String get whoIsPokemonTitle;

  /// No description provided for @whoIsPokemonDescription.
  ///
  /// In en, this message translates to:
  /// **'Guess the Pokémon\nby its silhouette!'**
  String get whoIsPokemonDescription;

  /// No description provided for @whoIsPokemonRules.
  ///
  /// In en, this message translates to:
  /// **'10 questions • 15 seconds each\n+10 points per correct answer • Speed bonus'**
  String get whoIsPokemonRules;

  /// No description provided for @highScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Best score: {score}'**
  String highScoreLabel(Object score);

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get startGame;

  /// No description provided for @viewRanking.
  ///
  /// In en, this message translates to:
  /// **'View Ranking'**
  String get viewRanking;

  /// No description provided for @resultCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get resultCorrect;

  /// No description provided for @resultIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get resultIncorrect;

  /// No description provided for @resultAnswer.
  ///
  /// In en, this message translates to:
  /// **'It\'s {pokemonName}'**
  String resultAnswer(Object pokemonName);

  /// No description provided for @answerOption.
  ///
  /// In en, this message translates to:
  /// **'Answer option {pokemonName}'**
  String answerOption(Object pokemonName);

  /// No description provided for @timeBonus.
  ///
  /// In en, this message translates to:
  /// **'Time bonus! +5 points'**
  String get timeBonus;

  /// No description provided for @timeElapsed.
  ///
  /// In en, this message translates to:
  /// **'Time: {seconds}s'**
  String timeElapsed(Object seconds);

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'VIEW RESULTS'**
  String get showResults;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get nextQuestion;

  /// No description provided for @exitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit the game?'**
  String get exitGameTitle;

  /// No description provided for @exitGameMessage.
  ///
  /// In en, this message translates to:
  /// **'You will lose the current game progress.'**
  String get exitGameMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get exit;

  /// No description provided for @timerLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timerLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get scoreLabel;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @statsGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get statsGames;

  /// No description provided for @statsHits.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get statsHits;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get statsBestStreak;

  /// No description provided for @statsAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get statsAchievements;

  /// No description provided for @achievementsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading achievements'**
  String get achievementsError;

  /// No description provided for @progressUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Progress: {unlocked}/{total} achievements unlocked'**
  String progressUnlocked(Object unlocked, Object total);

  /// No description provided for @rankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get rankingTitle;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsTitle;

  /// No description provided for @newRecord.
  ///
  /// In en, this message translates to:
  /// **'NEW RECORD!'**
  String get newRecord;

  /// No description provided for @gameFinished.
  ///
  /// In en, this message translates to:
  /// **'GAME FINISHED'**
  String get gameFinished;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get pointsLabel;

  /// No description provided for @statsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsAccuracy;

  /// No description provided for @unlockedAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlocked achievements'**
  String get unlockedAchievementsTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get menu;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @rankingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'RANKING'**
  String get rankingSectionTitle;

  /// No description provided for @errorLoadingRanking.
  ///
  /// In en, this message translates to:
  /// **'Error loading ranking'**
  String get errorLoadingRanking;

  /// No description provided for @noScores.
  ///
  /// In en, this message translates to:
  /// **'No scores yet'**
  String get noScores;

  /// No description provided for @playToRank.
  ///
  /// In en, this message translates to:
  /// **'Play to enter the ranking!'**
  String get playToRank;

  /// No description provided for @scorePoints.
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String scorePoints(Object points);

  /// No description provided for @unlockedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Unlocked on {date}'**
  String unlockedOnDate(Object date);

  /// No description provided for @achievementUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENT UNLOCKED!'**
  String get achievementUnlockTitle;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'AWESOME!'**
  String get great;

  /// No description provided for @languageButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageButtonTooltip;

  /// No description provided for @languageButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Language selector. Current: {language}'**
  String languageButtonLabel(Object language);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @achievementNoviceTrainerName.
  ///
  /// In en, this message translates to:
  /// **'Rookie Trainer'**
  String get achievementNoviceTrainerName;

  /// No description provided for @achievementConnoisseurName.
  ///
  /// In en, this message translates to:
  /// **'Connoisseur'**
  String get achievementConnoisseurName;

  /// No description provided for @achievementPokemonMasterName.
  ///
  /// In en, this message translates to:
  /// **'Pokémon Master'**
  String get achievementPokemonMasterName;

  /// No description provided for @achievementSpeedsterName.
  ///
  /// In en, this message translates to:
  /// **'Speedster'**
  String get achievementSpeedsterName;

  /// No description provided for @achievementOnFireName.
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get achievementOnFireName;

  /// No description provided for @achievementLegendName.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get achievementLegendName;

  /// No description provided for @achievementNoviceTrainerDescription.
  ///
  /// In en, this message translates to:
  /// **'First completed game'**
  String get achievementNoviceTrainerDescription;

  /// No description provided for @achievementConnoisseurDescription.
  ///
  /// In en, this message translates to:
  /// **'50 points in one game'**
  String get achievementConnoisseurDescription;

  /// No description provided for @achievementPokemonMasterDescription.
  ///
  /// In en, this message translates to:
  /// **'100 points in one game'**
  String get achievementPokemonMasterDescription;

  /// No description provided for @achievementSpeedsterDescription.
  ///
  /// In en, this message translates to:
  /// **'5 correct answers under 3 seconds'**
  String get achievementSpeedsterDescription;

  /// No description provided for @achievementOnFireDescription.
  ///
  /// In en, this message translates to:
  /// **'10 correct answers in a row'**
  String get achievementOnFireDescription;

  /// No description provided for @achievementLegendDescription.
  ///
  /// In en, this message translates to:
  /// **'200 points in one game'**
  String get achievementLegendDescription;

  /// No description provided for @silhouetteHiddenLabel.
  ///
  /// In en, this message translates to:
  /// **'Pokémon silhouette hidden'**
  String get silhouetteHiddenLabel;

  /// No description provided for @silhouetteRevealedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pokémon image revealed'**
  String get silhouetteRevealedLabel;

  /// No description provided for @languageToggle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageToggle;

  /// No description provided for @speedBonusLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed bonus'**
  String get speedBonusLabel;

  /// No description provided for @streakMultiplier.
  ///
  /// In en, this message translates to:
  /// **'x1.5'**
  String get streakMultiplier;

  /// No description provided for @pokedexRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional Pokédex'**
  String get pokedexRegional;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @whoIsPokemonGame.
  ///
  /// In en, this message translates to:
  /// **'Who is this Pokémon?'**
  String get whoIsPokemonGame;

  /// No description provided for @triviaGame.
  ///
  /// In en, this message translates to:
  /// **'Trivia game'**
  String get triviaGame;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get configuration;

  /// No description provided for @generation.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get generation;

  /// No description provided for @showingGeneration.
  ///
  /// In en, this message translates to:
  /// **'Showing: Generation {generation}'**
  String showingGeneration(Object generation);

  /// No description provided for @searchByNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Search by name or #ID'**
  String get searchByNameOrId;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPokemonFound.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon found'**
  String get noPokemonFound;

  /// No description provided for @pokemonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} favorite Pokémon{plural}'**
  String pokemonCount(Object count, Object plural);

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet!'**
  String get noFavoritesYet;

  /// No description provided for @exploreFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Explore the Pokédex and mark your favorite Pokémon by tapping the heart on the details screen.'**
  String get exploreFavoritesHint;

  /// No description provided for @tapHeartToAddFavorites.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart to add favorites'**
  String get tapHeartToAddFavorites;

  /// No description provided for @shareBeforeLoading.
  ///
  /// In en, this message translates to:
  /// **'Load the Pokémon before sharing its card.'**
  String get shareBeforeLoading;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Could not share the card. Please try again.'**
  String get shareError;

  /// No description provided for @pokemonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Pokémon not found'**
  String get pokemonNotFound;

  /// No description provided for @typeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get typeNormal;

  /// No description provided for @typeFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get typeFire;

  /// No description provided for @typeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get typeWater;

  /// No description provided for @typeGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get typeGrass;

  /// No description provided for @typeElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get typeElectric;

  /// No description provided for @typeIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get typeIce;

  /// No description provided for @typeFighting.
  ///
  /// In en, this message translates to:
  /// **'Fighting'**
  String get typeFighting;

  /// No description provided for @typePoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get typePoison;

  /// No description provided for @typeGround.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get typeGround;

  /// No description provided for @typeFlying.
  ///
  /// In en, this message translates to:
  /// **'Flying'**
  String get typeFlying;

  /// No description provided for @typePsychic.
  ///
  /// In en, this message translates to:
  /// **'Psychic'**
  String get typePsychic;

  /// No description provided for @typeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get typeBug;

  /// No description provided for @typeRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get typeRock;

  /// No description provided for @typeGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost'**
  String get typeGhost;

  /// No description provided for @typeDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get typeDragon;

  /// No description provided for @typeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get typeDark;

  /// No description provided for @typeSteel.
  ///
  /// In en, this message translates to:
  /// **'Steel'**
  String get typeSteel;

  /// No description provided for @typeFairy.
  ///
  /// In en, this message translates to:
  /// **'Fairy'**
  String get typeFairy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Pokémon info copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @noEvolutionData.
  ///
  /// In en, this message translates to:
  /// **'No evolution data available'**
  String get noEvolutionData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
