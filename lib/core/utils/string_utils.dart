/// Capitalizes each word in a string, replacing dashes with spaces.
///
/// Example: 'special-attack' -> 'Special Attack'
String capitalize(String raw) {
  if (raw.isEmpty) return raw;
  final parts = raw.replaceAll('-', ' ').split(' ');
  return parts
      .map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w)
      .join(' ');
}

/// Formats a stat name for display.
///
/// Converts internal stat names to user-friendly labels.
String formatStatName(String raw) {
  switch (raw.toLowerCase()) {
    case 'hp':
      return 'HP';
    case 'attack':
      return 'Attack';
    case 'defense':
      return 'Defense';
    case 'special-attack':
      return 'Sp. Attack';
    case 'special-defense':
      return 'Sp. Defense';
    case 'speed':
      return 'Speed';
    default:
      return capitalize(raw);
  }
}

/// Returns an abbreviated stat name for compact display.
///
/// Example: 'Sp. Attack' -> 'SATK'
String getAbbreviatedStatName(String name) {
  switch (name) {
    case 'HP':
      return 'HP';
    case 'Attack':
      return 'ATK';
    case 'Defense':
      return 'DEF';
    case 'Sp. Attack':
      return 'SATK';
    case 'Sp. Defense':
      return 'SDEF';
    case 'Speed':
      return 'SPD';
    default:
      return name;
  }
}
