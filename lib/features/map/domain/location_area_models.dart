/// Models for PokeAPI Location Area endpoint responses
/// GET https://pokeapi.co/api/v2/location-area/{id or name}

/// Represents the complete location area response from PokeAPI
class LocationAreaResponse {
  final String name;
  final List<PokemonEncounter> pokemonEncounters;

  const LocationAreaResponse({
    required this.name,
    required this.pokemonEncounters,
  });

  factory LocationAreaResponse.fromJson(Map<String, dynamic> json) {
    final encountersRaw = json['pokemon_encounters'] as List? ?? [];
    final encounters = encountersRaw
        .map((e) => PokemonEncounter.fromJson(e as Map<String, dynamic>))
        .toList();

    return LocationAreaResponse(
      name: json['name'] as String? ?? '',
      pokemonEncounters: encounters,
    );
  }
}

/// Represents a Pokémon that can be encountered in a location area
class PokemonEncounter {
  final PokemonSummary pokemon;
  final List<VersionDetail> versionDetails;

  const PokemonEncounter({
    required this.pokemon,
    required this.versionDetails,
  });

  factory PokemonEncounter.fromJson(Map<String, dynamic> json) {
    final pokemon = PokemonSummary.fromJson(
      json['pokemon'] as Map<String, dynamic>? ?? {},
    );

    final versionDetailsRaw = json['version_details'] as List? ?? [];
    final versionDetails = versionDetailsRaw
        .map((v) => VersionDetail.fromJson(v as Map<String, dynamic>))
        .toList();

    return PokemonEncounter(
      pokemon: pokemon,
      versionDetails: versionDetails,
    );
  }
}

/// Basic Pokémon info from encounter data
class PokemonSummary {
  final String name;
  final String url;

  const PokemonSummary({
    required this.name,
    required this.url,
  });

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    return PokemonSummary(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  /// Extract Pokémon ID from URL like "https://pokeapi.co/api/v2/pokemon/25/"
  int? get id {
    final parts = url.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return int.tryParse(parts.last);
  }

  /// Get sprite URL for this Pokémon
  String? get spriteUrl {
    final pokemonId = id;
    if (pokemonId == null) return null;
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';
  }
}

/// Version-specific encounter details
class VersionDetail {
  final GameVersion version;
  final List<EncounterDetail> encounterDetails;

  const VersionDetail({
    required this.version,
    required this.encounterDetails,
  });

  factory VersionDetail.fromJson(Map<String, dynamic> json) {
    final version = GameVersion.fromJson(
      json['version'] as Map<String, dynamic>? ?? {},
    );

    final encounterDetailsRaw = json['encounter_details'] as List? ?? [];
    final encounterDetails = encounterDetailsRaw
        .map((e) => EncounterDetail.fromJson(e as Map<String, dynamic>))
        .toList();

    return VersionDetail(
      version: version,
      encounterDetails: encounterDetails,
    );
  }
}

/// Game version info
class GameVersion {
  final String name;

  const GameVersion({required this.name});

  factory GameVersion.fromJson(Map<String, dynamic> json) {
    return GameVersion(
      name: json['name'] as String? ?? '',
    );
  }
}

/// Specific encounter method and details
class EncounterDetail {
  final int minLevel;
  final int maxLevel;
  final int chance;
  final EncounterMethod method;

  const EncounterDetail({
    required this.minLevel,
    required this.maxLevel,
    required this.chance,
    required this.method,
  });

  factory EncounterDetail.fromJson(Map<String, dynamic> json) {
    final method = EncounterMethod.fromJson(
      json['method'] as Map<String, dynamic>? ?? {},
    );

    return EncounterDetail(
      minLevel: json['min_level'] as int? ?? 1,
      maxLevel: json['max_level'] as int? ?? 1,
      chance: json['chance'] as int? ?? 0,
      method: method,
    );
  }

  /// Format level range as string
  String get levelRange {
    if (minLevel == maxLevel) {
      return 'Nv. $minLevel';
    }
    return 'Nv. $minLevel-$maxLevel';
  }

  /// Format chance as percentage
  String get chancePercentage {
    return '${chance}%';
  }
}

/// Encounter method info
class EncounterMethod {
  final String name;

  const EncounterMethod({required this.name});

  factory EncounterMethod.fromJson(Map<String, dynamic> json) {
    return EncounterMethod(
      name: json['name'] as String? ?? '',
    );
  }

  /// Translate method name to Spanish
  String get spanishName {
    switch (name.toLowerCase()) {
      case 'walk':
        return 'Caminando';
      case 'surf':
        return 'Surf';
      case 'old-rod':
        return 'Caña Vieja';
      case 'good-rod':
        return 'Caña Buena';
      case 'super-rod':
        return 'Super Caña';
      case 'rock-smash':
        return 'Golpe Roca';
      case 'headbutt':
        return 'Cabezazo';
      case 'dark-grass':
        return 'Hierba Oscura';
      case 'grass-spots':
        return 'Manchas de Hierba';
      case 'cave-spots':
        return 'Manchas de Cueva';
      case 'bridge-spots':
        return 'Manchas de Puente';
      case 'super-rod-spots':
        return 'Super Caña (Manchas)';
      case 'surf-spots':
        return 'Surf (Manchas)';
      case 'yellow-flowers':
        return 'Flores Amarillas';
      case 'purple-flowers':
        return 'Flores Moradas';
      case 'red-flowers':
        return 'Flores Rojas';
      case 'rough-terrain':
        return 'Terreno Difícil';
      default:
        return name;
    }
  }
}
