import 'package:pokedex_carbonica/gen/l10n/app_localizations.dart';

import 'game_achievement.dart';

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
