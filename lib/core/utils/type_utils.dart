import 'package:flutter/material.dart';

/// Map of Pokemon type names to their corresponding colors.
///
/// Used throughout the app for consistent type-based theming.
const Map<String, Color> typeColor = {
  "normal": Color(0xFF9BA0A8),
  "fire": Color(0xFFFF6B3D),
  "water": Color(0xFF4C90FF),
  "electric": Color(0xFFFFD037),
  "grass": Color(0xFF6BD64A),
  "ice": Color(0xFF64DDF8),
  "fighting": Color(0xFFE34343),
  "poison": Color(0xFFB24ADD),
  "ground": Color(0xFFE2B36B),
  "flying": Color(0xFFA890F7),
  "psychic": Color(0xFFFF4888),
  "bug": Color(0xFF88C12F),
  "rock": Color(0xFFC9B68B),
  "ghost": Color(0xFF6F65D8),
  "dragon": Color(0xFF7366FF),
  "dark": Color(0xFF5A5A5A),
  "steel": Color(0xFF8AA4C1),
  "fairy": Color(0xFFFF78D5),
};

/// Returns the Material icon for a given Pokemon type.
IconData iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'fire':
      return Icons.local_fire_department;
    case 'water':
      return Icons.water_drop;
    case 'grass':
      return Icons.eco;
    case 'electric':
      return Icons.bolt;
    case 'ice':
      return Icons.ac_unit;
    case 'fighting':
      return Icons.sports_mma;
    case 'poison':
      return Icons.coronavirus;
    case 'ground':
      return Icons.landscape;
    case 'flying':
      return Icons.air;
    case 'psychic':
      return Icons.psychology;
    case 'bug':
      return Icons.pest_control_rodent;
    case 'rock':
      return Icons.terrain;
    case 'ghost':
      return Icons.auto_awesome;
    case 'dragon':
      return Icons.adb;
    case 'dark':
      return Icons.dark_mode;
    case 'steel':
      return Icons.build;
    case 'fairy':
      return Icons.auto_fix_high;
    default:
      return Icons.circle;
  }
}

/// Full type effectiveness chart (attacker -> defender -> multiplier).
///
/// Source: standard Pokemon type chart.
const Map<String, Map<String, double>> typeChart = {
  "normal": {"rock": 0.5, "ghost": 0.0, "steel": 0.5},
  "fire": {
    "fire": 0.5,
    "water": 0.5,
    "grass": 2.0,
    "ice": 2.0,
    "bug": 2.0,
    "rock": 0.5,
    "dragon": 0.5,
    "steel": 2.0
  },
  "water": {
    "fire": 2.0,
    "water": 0.5,
    "grass": 0.5,
    "ground": 2.0,
    "rock": 2.0,
    "dragon": 0.5
  },
  "electric": {
    "water": 2.0,
    "electric": 0.5,
    "grass": 0.5,
    "ground": 0.0,
    "flying": 2.0,
    "dragon": 0.5
  },
  "grass": {
    "fire": 0.5,
    "water": 2.0,
    "grass": 0.5,
    "poison": 0.5,
    "ground": 2.0,
    "flying": 0.5,
    "bug": 0.5,
    "rock": 2.0,
    "dragon": 0.5,
    "steel": 0.5
  },
  "ice": {
    "fire": 0.5,
    "water": 0.5,
    "grass": 2.0,
    "ice": 0.5,
    "ground": 2.0,
    "flying": 2.0,
    "dragon": 2.0,
    "steel": 0.5
  },
  "fighting": {
    "normal": 2.0,
    "ice": 2.0,
    "poison": 0.5,
    "flying": 0.5,
    "psychic": 0.5,
    "bug": 0.5,
    "rock": 2.0,
    "ghost": 0.0,
    "dark": 2.0,
    "steel": 2.0,
    "fairy": 0.5
  },
  "poison": {
    "grass": 2.0,
    "poison": 0.5,
    "ground": 0.5,
    "rock": 0.5,
    "ghost": 0.5,
    "steel": 0.0,
    "fairy": 2.0
  },
  "ground": {
    "fire": 2.0,
    "electric": 2.0,
    "grass": 0.5,
    "poison": 2.0,
    "flying": 0.0,
    "bug": 0.5,
    "rock": 2.0,
    "steel": 2.0
  },
  "flying": {
    "electric": 0.5,
    "grass": 2.0,
    "fighting": 2.0,
    "bug": 2.0,
    "rock": 0.5,
    "steel": 0.5
  },
  "psychic": {
    "fighting": 2.0,
    "poison": 2.0,
    "psychic": 0.5,
    "dark": 0.0,
    "steel": 0.5
  },
  "bug": {
    "fire": 0.5,
    "grass": 2.0,
    "fighting": 0.5,
    "poison": 0.5,
    "flying": 0.5,
    "psychic": 2.0,
    "ghost": 0.5,
    "dark": 2.0,
    "steel": 0.5,
    "fairy": 0.5
  },
  "rock": {
    "fire": 2.0,
    "ice": 2.0,
    "fighting": 0.5,
    "ground": 0.5,
    "flying": 2.0,
    "bug": 2.0,
    "steel": 0.5
  },
  "ghost": {"normal": 0.0, "psychic": 2.0, "ghost": 2.0, "dark": 0.5},
  "dragon": {"dragon": 2.0, "steel": 0.5, "fairy": 0.0},
  "dark": {
    "fighting": 0.5,
    "psychic": 2.0,
    "ghost": 2.0,
    "dark": 0.5,
    "fairy": 0.5
  },
  "steel": {
    "fire": 0.5,
    "water": 0.5,
    "electric": 0.5,
    "ice": 2.0,
    "rock": 2.0,
    "fairy": 2.0,
    "steel": 0.5
  },
  "fairy": {
    "fire": 0.5,
    "fighting": 2.0,
    "poison": 0.5,
    "dragon": 2.0,
    "dark": 2.0,
    "steel": 0.5
  },
};

/// Computes the total multiplier of an attacking type against defender types.
double typeMultiplierAgainst(List<String> defenderTypes, String attacker) {
  var m = 1.0;
  for (final def in defenderTypes) {
    final row = typeChart[attacker.toLowerCase()];
    if (row != null && row.containsKey(def.toLowerCase())) {
      m *= row[def.toLowerCase()]!;
    }
  }
  return m;
}

/// Result of type effectiveness calculation.
class TypeMatchups {
  final List<String> x4Weaknesses;
  final List<String> x2Weaknesses;
  final List<String> x05Resistances;
  final List<String> x025Resistances;
  final List<String> immunities;

  const TypeMatchups({
    required this.x4Weaknesses,
    required this.x2Weaknesses,
    required this.x05Resistances,
    required this.x025Resistances,
    required this.immunities,
  });
}

/// Computes type matchups for a Pokemon based on its types.
///
/// Returns the weaknesses, resistances, and immunities.
TypeMatchups computeMatchups(List<String> defenderTypes) {
  final List<String> x4Types = [];
  final List<String> x2Types = [];
  final List<String> x05Types = [];
  final List<String> x025Types = [];
  final List<String> x0Types = [];

  for (final attacker in typeChart.keys) {
    final multiplier = typeMultiplierAgainst(defenderTypes, attacker);
    if (multiplier == 4.0) {
      x4Types.add(attacker);
    } else if (multiplier == 2.0) {
      x2Types.add(attacker);
    } else if (multiplier == 0.5) {
      x05Types.add(attacker);
    } else if (multiplier == 0.25) {
      x025Types.add(attacker);
    } else if (multiplier == 0.0) {
      x0Types.add(attacker);
    }
  }

  return TypeMatchups(
    x4Weaknesses: x4Types,
    x2Weaknesses: x2Types,
    x05Resistances: x05Types,
    x025Resistances: x025Types,
    immunities: x0Types,
  );
}
