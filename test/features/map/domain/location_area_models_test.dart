import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_carbonica/features/map/domain/location_area_models.dart';

void main() {
  group('LocationAreaResponse', () {
    test('should parse valid JSON response', () {
      final json = {
        'name': 'kanto-route-1-area',
        'pokemon_encounters': [
          {
            'pokemon': {
              'name': 'pidgey',
              'url': 'https://pokeapi.co/api/v2/pokemon/16/',
            },
            'version_details': [
              {
                'version': {'name': 'red'},
                'encounter_details': [
                  {
                    'min_level': 2,
                    'max_level': 5,
                    'chance': 40,
                    'method': {'name': 'walk'},
                  },
                ],
              },
            ],
          },
        ],
      };

      final response = LocationAreaResponse.fromJson(json);

      expect(response.name, 'kanto-route-1-area');
      expect(response.pokemonEncounters.length, 1);
      expect(response.pokemonEncounters[0].pokemon.name, 'pidgey');
    });

    test('should handle empty pokemon_encounters array', () {
      final json = {
        'name': 'test-area',
        'pokemon_encounters': [],
      };

      final response = LocationAreaResponse.fromJson(json);

      expect(response.name, 'test-area');
      expect(response.pokemonEncounters, isEmpty);
    });

    test('should handle missing pokemon_encounters field', () {
      final json = {
        'name': 'test-area',
      };

      final response = LocationAreaResponse.fromJson(json);

      expect(response.name, 'test-area');
      expect(response.pokemonEncounters, isEmpty);
    });
  });

  group('PokemonSummary', () {
    test('should extract ID from URL correctly', () {
      final summary = PokemonSummary(
        name: 'pikachu',
        url: 'https://pokeapi.co/api/v2/pokemon/25/',
      );

      expect(summary.id, 25);
    });

    test('should generate correct sprite URL', () {
      final summary = PokemonSummary(
        name: 'pikachu',
        url: 'https://pokeapi.co/api/v2/pokemon/25/',
      );

      expect(
        summary.spriteUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
      );
    });

    test('should return null for invalid URL', () {
      final summary = PokemonSummary(
        name: 'test',
        url: '',
      );

      expect(summary.id, null);
      expect(summary.spriteUrl, null);
    });
  });

  group('EncounterDetail', () {
    test('should format level range correctly for same min and max', () {
      final detail = EncounterDetail(
        minLevel: 5,
        maxLevel: 5,
        chance: 30,
        method: const EncounterMethod(name: 'walk'),
      );

      expect(detail.levelRange, 'Nv. 5');
    });

    test('should format level range correctly for different min and max', () {
      final detail = EncounterDetail(
        minLevel: 2,
        maxLevel: 5,
        chance: 30,
        method: const EncounterMethod(name: 'walk'),
      );

      expect(detail.levelRange, 'Nv. 2-5');
    });

    test('should format chance as percentage', () {
      final detail = EncounterDetail(
        minLevel: 5,
        maxLevel: 5,
        chance: 40,
        method: const EncounterMethod(name: 'walk'),
      );

      expect(detail.chancePercentage, '40%');
    });
  });

  group('EncounterMethod', () {
    test('should translate common methods to Spanish', () {
      expect(const EncounterMethod(name: 'walk').spanishName, 'Caminando');
      expect(const EncounterMethod(name: 'surf').spanishName, 'Surf');
      expect(const EncounterMethod(name: 'old-rod').spanishName, 'Caña Vieja');
      expect(const EncounterMethod(name: 'good-rod').spanishName, 'Caña Buena');
      expect(const EncounterMethod(name: 'super-rod').spanishName, 'Super Caña');
    });

    test('should return original name for unknown methods', () {
      const method = EncounterMethod(name: 'unknown-method');
      expect(method.spanishName, 'unknown-method');
    });
  });

  group('PokemonEncounter', () {
    test('should parse complete encounter data', () {
      final json = {
        'pokemon': {
          'name': 'rattata',
          'url': 'https://pokeapi.co/api/v2/pokemon/19/',
        },
        'version_details': [
          {
            'version': {'name': 'red'},
            'encounter_details': [
              {
                'min_level': 2,
                'max_level': 4,
                'chance': 50,
                'method': {'name': 'walk'},
              },
            ],
          },
        ],
      };

      final encounter = PokemonEncounter.fromJson(json);

      expect(encounter.pokemon.name, 'rattata');
      expect(encounter.pokemon.id, 19);
      expect(encounter.versionDetails.length, 1);
      expect(encounter.versionDetails[0].version.name, 'red');
      expect(encounter.versionDetails[0].encounterDetails.length, 1);
      expect(encounter.versionDetails[0].encounterDetails[0].minLevel, 2);
      expect(encounter.versionDetails[0].encounterDetails[0].maxLevel, 4);
      expect(encounter.versionDetails[0].encounterDetails[0].chance, 50);
    });

    test('should handle multiple version details', () {
      final json = {
        'pokemon': {
          'name': 'pidgey',
          'url': 'https://pokeapi.co/api/v2/pokemon/16/',
        },
        'version_details': [
          {
            'version': {'name': 'red'},
            'encounter_details': [
              {
                'min_level': 2,
                'max_level': 5,
                'chance': 40,
                'method': {'name': 'walk'},
              },
            ],
          },
          {
            'version': {'name': 'blue'},
            'encounter_details': [
              {
                'min_level': 3,
                'max_level': 6,
                'chance': 35,
                'method': {'name': 'walk'},
              },
            ],
          },
        ],
      };

      final encounter = PokemonEncounter.fromJson(json);

      expect(encounter.versionDetails.length, 2);
      expect(encounter.versionDetails[0].version.name, 'red');
      expect(encounter.versionDetails[1].version.name, 'blue');
    });

    test('should handle multiple encounter methods', () {
      final json = {
        'pokemon': {
          'name': 'magikarp',
          'url': 'https://pokeapi.co/api/v2/pokemon/129/',
        },
        'version_details': [
          {
            'version': {'name': 'red'},
            'encounter_details': [
              {
                'min_level': 5,
                'max_level': 5,
                'chance': 100,
                'method': {'name': 'old-rod'},
              },
              {
                'min_level': 10,
                'max_level': 10,
                'chance': 40,
                'method': {'name': 'good-rod'},
              },
            ],
          },
        ],
      };

      final encounter = PokemonEncounter.fromJson(json);

      expect(encounter.versionDetails[0].encounterDetails.length, 2);
      expect(
        encounter.versionDetails[0].encounterDetails[0].method.spanishName,
        'Caña Vieja',
      );
      expect(
        encounter.versionDetails[0].encounterDetails[1].method.spanishName,
        'Caña Buena',
      );
    });
  });
}
