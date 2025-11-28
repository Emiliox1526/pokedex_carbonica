import 'dart:convert';

/// Builds the official artwork URL for a Pokemon by ID.
String artworkUrlForId(int id) {
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

/// Builds the official shiny artwork URL for a Pokemon by ID.
String artworkShinyUrlForId(int id) {
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';
}

/// Result of sprite URL extraction.
class SpriteUrls {
  final String? defaultUrl;
  final String? shinyUrl;

  const SpriteUrls({this.defaultUrl, this.shinyUrl});
}

/// Extracts sprite URLs from a Pokemon's sprite data.
///
/// Attempts to find official-artwork, then home sprites, then basic sprites.
SpriteUrls extractSpriteUrls(dynamic rawSprites) {
  if (rawSprites == null) {
    return const SpriteUrls();
  }

  Map<String, dynamic>? decoded;
  if (rawSprites is String) {
    try {
      decoded = json.decode(rawSprites) as Map<String, dynamic>;
    } catch (_) {
      return const SpriteUrls();
    }
  } else if (rawSprites is Map<String, dynamic>) {
    decoded = rawSprites;
  } else {
    return const SpriteUrls();
  }

  // Try official-artwork first, then home, then basic sprites
  final defaultUrl =
      decoded['other']?['official-artwork']?['front_default'] ??
          decoded['other']?['home']?['front_default'] ??
          decoded['front_default'];

  final shinyUrl =
      decoded['other']?['official-artwork']?['front_shiny'] ??
          decoded['other']?['home']?['front_shiny'] ??
          decoded['front_shiny'];

  return SpriteUrls(
    defaultUrl: defaultUrl as String?,
    shinyUrl: shinyUrl as String?,
  );
}

/// Extracts high-quality sprite URLs from form sprite data.
///
/// Returns null for low-quality basic sprites, preferring official-artwork
/// or home sprites.
SpriteUrls extractFormSprites(dynamic rawSprites) {
  if (rawSprites == null) {
    return const SpriteUrls();
  }

  Map<String, dynamic>? decoded;
  if (rawSprites is String) {
    try {
      decoded = json.decode(rawSprites) as Map<String, dynamic>;
    } catch (_) {
      return const SpriteUrls();
    }
  } else if (rawSprites is Map<String, dynamic>) {
    decoded = rawSprites;
  } else {
    return const SpriteUrls();
  }

  // Only return URLs if they are high quality (official-artwork or home)
  final hasOfficialDefault =
      decoded['other']?['official-artwork']?['front_default'] != null ||
          decoded['other']?['home']?['front_default'] != null;
  final hasOfficialShiny =
      decoded['other']?['official-artwork']?['front_shiny'] != null ||
          decoded['other']?['home']?['front_shiny'] != null;

  final defaultUrl =
      decoded['other']?['official-artwork']?['front_default'] ??
          decoded['other']?['home']?['front_default'];

  final shinyUrl = decoded['other']?['official-artwork']?['front_shiny'] ??
      decoded['other']?['home']?['front_shiny'];

  return SpriteUrls(
    defaultUrl: hasOfficialDefault ? defaultUrl as String? : null,
    shinyUrl: hasOfficialShiny ? shinyUrl as String? : null,
  );
}

/// Builds the TM/HM sprite URL based on move type.
String getTmSpriteUrl(String moveType) {
  if (moveType.isEmpty) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/tm-normal.png';
  }
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/tm-${moveType.toLowerCase()}.png';
}

/// Builds the item sprite URL from an item name.
String getItemSpriteUrl(String itemName) {
  final formattedName = itemName.toLowerCase().replaceAll(' ', '-');
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/$formattedName.png';
}
