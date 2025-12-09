import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Translates Pokemon type names to the current locale.
String translateType(BuildContext context, String type) {
  final l10n = AppLocalizations.of(context)!;
  
  switch (type.toLowerCase()) {
    case 'normal':
      return l10n.typeNormal;
    case 'fire':
      return l10n.typeFire;
    case 'water':
      return l10n.typeWater;
    case 'grass':
      return l10n.typeGrass;
    case 'electric':
      return l10n.typeElectric;
    case 'ice':
      return l10n.typeIce;
    case 'fighting':
      return l10n.typeFighting;
    case 'poison':
      return l10n.typePoison;
    case 'ground':
      return l10n.typeGround;
    case 'flying':
      return l10n.typeFlying;
    case 'psychic':
      return l10n.typePsychic;
    case 'bug':
      return l10n.typeBug;
    case 'rock':
      return l10n.typeRock;
    case 'ghost':
      return l10n.typeGhost;
    case 'dragon':
      return l10n.typeDragon;
    case 'dark':
      return l10n.typeDark;
    case 'steel':
      return l10n.typeSteel;
    case 'fairy':
      return l10n.typeFairy;
    default:
      return type[0].toUpperCase() + type.substring(1);
  }
}
