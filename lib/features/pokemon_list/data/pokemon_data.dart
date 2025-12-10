// Definiciones de modelos, contratos y excepciones para Pokémon.

import 'dart:convert';
import 'package:hive/hive.dart';

part 'pokemon_data.g.dart';

// -------- DTO y Hive Adapter -------
@HiveType(typeId: 0)
class PokemonDTO {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<String> types;
  @HiveField(3)
  final String? imageUrl;
  @HiveField(4)
  final List<String> abilities;

  const PokemonDTO({
    required this.id,
    required this.name,
    required this.types,
    this.imageUrl,
    this.abilities = const [],
  });

  factory PokemonDTO.fromGraphQL(Map<String, dynamic> json) {
    final int id = json['id'] as int? ?? 0;
    final String name = json['name'] as String? ?? '';
    final typesRaw = json['pokemon_v2_pokemontypes'] as List? ?? [];
    final List<String> types = typesRaw
        .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
        .where((e) => e.isNotEmpty)
        .toList();
    final abilitiesRaw = json['pokemon_v2_pokemonabilities'] as List? ?? [];
    final List<String> abilities = abilitiesRaw
        .take(2)
        .map((a) => (a['pokemon_v2_ability']?['name'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
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

  Pokemon toEntity() => Pokemon(
    id: id,
    name: name,
    types: types,
    imageUrl: imageUrl,
    abilities: abilities,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'types': types,
    'imageUrl': imageUrl,
    'abilities': abilities,
  };

  factory PokemonDTO.fromJson(Map<String, dynamic> json) => PokemonDTO(
    id: json['id'] as int,
    name: json['name'] as String,
    types: (json['types'] as List).cast<String>(),
    imageUrl: json['imageUrl'] as String?,
    abilities: (json['abilities'] as List?)?.cast<String>() ?? [],
  );

  @override
  String toString() => 'PokemonDTO(id: $id, name: $name, types: $types)';
}

// -------- Dominio -------
class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final String? imageUrl;
  final List<String> abilities;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    this.imageUrl,
    required this.abilities,
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
  String get displayName => name.toUpperCase();
  String get primaryType => types.isNotEmpty ? types.first : 'normal';
  String get heroTag => 'pokemon-image-$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pokemon &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Pokemon(id: $id, name: $name, types: $types)';
}

// --------- Filtros y paginación ----------
class PokemonFilter {
  final int page;
  final int pageSize;
  final String? searchText;
  final int? generation;
  final Set<String> types;
  int get offset => (page - 1) * pageSize;

  PokemonFilter({
    this.page = 1,
    this.pageSize = 20,
    this.searchText,
    this.generation,
    this.types = const {},
  });

  PokemonFilter copyWith({
    int? page,
    int? pageSize,
    String? searchText,
    int? generation,
    Set<String>? types,
  }) =>
      PokemonFilter(
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        searchText: searchText ?? this.searchText,
        generation: generation ?? this.generation,
        types: types ?? this.types,
      );
}

class PaginatedPokemonList {
  final List<Pokemon> pokemons;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPreviousPage;
  PaginatedPokemonList({
    required this.pokemons,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedPokemonList.empty() => PaginatedPokemonList(
    pokemons: [],
    currentPage: 1,
    totalPages: 0,
    totalCount: 0,
    hasNextPage: false,
    hasPreviousPage: false,
  );
}

// --------- Contratos ----------
abstract class PokemonRepository {
  Future<PaginatedPokemonList> getPokemonList(PokemonFilter filter);
  Future<int> getTotalPokemonCount(PokemonFilter filter);
  Future<void> clearCache();
  Future<bool> hasCachedData();
  Future<List<Pokemon>> getRandomPokemonsForGame(int count);
}

// --------- Excepciones ----------
enum PokemonRemoteExceptionType { noConnection, timeout, rateLimit, serverError }

class PokemonRemoteException implements Exception {
  final String message;
  final PokemonRemoteExceptionType type;
  PokemonRemoteException({required this.message, required this.type});
  @override
  String toString() => 'PokemonRemoteException: $message (type: $type)';
}