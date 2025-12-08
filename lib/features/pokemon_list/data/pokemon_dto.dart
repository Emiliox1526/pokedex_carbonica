import 'dart:convert';

import 'package:hive/hive.dart';

import '../domain/pokemon.dart';

part 'pokemon_dto.g.dart';

/// Data Transfer Object para deserializar respuestas GraphQL de Pokémon.
/// 
/// Esta clase se encarga de mapear los datos crudos de la API GraphQL
/// a objetos utilizables en la aplicación. También está anotada para
/// persistencia con Hive.
@HiveType(typeId: 0)
class PokemonDTO {
  /// Identificador único del Pokémon.
  @HiveField(0)
  final int id;

  /// Nombre del Pokémon.
  @HiveField(1)
  final String name;

  /// Lista de tipos del Pokémon.
  @HiveField(2)
  final List<String> types;

  /// URL de la imagen del Pokémon.
  @HiveField(3)
  final String? imageUrl;

  /// Lista de habilidades del Pokémon.
  @HiveField(4)
  final List<String> abilities;

  /// Constructor del DTO.
  const PokemonDTO({
    required this.id,
    required this.name,
    required this.types,
    this.imageUrl,
    this.abilities = const [],
  });

  /// Crea un DTO a partir de los datos JSON de GraphQL.
  /// 
  /// [json] es el mapa con los datos de un Pokémon de la respuesta GraphQL.
  factory PokemonDTO.fromGraphQL(Map<String, dynamic> json) {
    // Extraer ID y nombre
    final int id = json['id'] as int? ?? 0;
    final String name = json['name'] as String? ?? '';

    // Extraer tipos
    final typesRaw = json['pokemon_v2_pokemontypes'] as List? ?? [];
    final List<String> types = typesRaw
        .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
        .where((e) => e.isNotEmpty)
        .toList();

    // Extraer habilidades
    final abilitiesRaw = json['pokemon_v2_pokemonabilities'] as List? ?? [];
    final List<String> abilities = abilitiesRaw
        .take(2)
        .map((a) => (a['pokemon_v2_ability']?['name'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    // Extraer URL de imagen
    String? imageUrl;
    final spritesList = json['pokemon_v2_pokemonsprites'] as List?;
    if (spritesList != null && spritesList.isNotEmpty) {
      try {
        final dynamic raw = spritesList.first['sprites'];
        Map<String, dynamic>? map;
        if (raw is String) {
          map = jsonDecode(raw) as Map<String, dynamic>;
        } else if (raw is Map) {
          map = Map<String, dynamic>.from(raw);
        }
        imageUrl =
            (map?['other']?['official-artwork']?['front_default'] as String?) ??
            (map?['front_default'] as String?);
      } catch (_) {
        imageUrl = null;
      }
    }

    return PokemonDTO(
      id: id,
      name: name,
      types: types,
      imageUrl: imageUrl,
      abilities: abilities,
    );
  }

  /// Convierte el DTO a una entidad de dominio.
  Pokemon toEntity() {
    return Pokemon(
      id: id,
      name: name,
      types: types,
      imageUrl: imageUrl,
      abilities: abilities,
    );
  }

  /// Convierte el DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      'imageUrl': imageUrl,
      'abilities': abilities,
    };
  }

  /// Crea un DTO a partir de un mapa JSON (para cache local).
  factory PokemonDTO.fromJson(Map<String, dynamic> json) {
    return PokemonDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      types: (json['types'] as List).cast<String>(),
      imageUrl: json['imageUrl'] as String?,
      abilities: (json['abilities'] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  String toString() => 'PokemonDTO(id: $id, name: $name, types: $types)';
}
