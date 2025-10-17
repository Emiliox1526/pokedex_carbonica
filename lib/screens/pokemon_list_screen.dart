import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../queries/get_pokemon_list.dart';

class PokemonListScreen extends StatelessWidget {
  const PokemonListScreen({super.key});

  // 🎨 Colores por tipo (alineados a la guía moderna)
  static const Map<String, Color> typeColor = {
    'fire': Color(0xFFF57D31),
    'water': Color(0xFF6493EB),
    'grass': Color(0xFF74CB48),
    'electric': Color(0xFFF9CF30),
    'ice': Color(0xFF9AD6DF),
    'fighting': Color(0xFFC12239),
    'poison': Color(0xFFA43E9E),
    'ground': Color(0xFFDEC16B),
    'flying': Color(0xFFA891EC),
    'psychic': Color(0xFFFB5584),
    'bug': Color(0xFFA7B723),
    'rock': Color(0xFFB69E31),
    'ghost': Color(0xFF70559B),
    'dragon': Color(0xFF7037FF),
    'dark': Color(0xFF75574C),
    'steel': Color(0xFFB7B9D0),
    'fairy': Color(0xFFE69EAC),
    'normal': Color(0xFF9AA5B8),
  };

  // 🔰 Icono según tipo
  IconData iconForType(String t) {
    switch (t) {
      case 'water':
        return Icons.water_drop;
      case 'grass':
        return Icons.eco;
      case 'fire':
        return Icons.local_fire_department;
      case 'electric':
        return Icons.flash_on;
      case 'rock':
        return Icons.landscape;
      case 'ground':
        return Icons.terrain;
      case 'ice':
        return Icons.ac_unit;
      case 'bug':
        return Icons.bug_report;
      case 'poison':
        return Icons.coronavirus;
      case 'ghost':
        return Icons.blur_on;
      case 'psychic':
        return Icons.auto_awesome;
      case 'dragon':
        return Icons.all_inclusive;
      case 'fighting':
        return Icons.sports_mma;
      case 'dark':
        return Icons.dark_mode;
      case 'steel':
        return Icons.build;
      case 'fairy':
        return Icons.auto_fix_high;
      case 'flying':
        return Icons.air;
      default:
        return Icons.brightness_5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Query(
        options: QueryOptions(document: gql(getPokemonListQuery)),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception}'));
          }

          final List data = result.data?['pokemon_v2_pokemon'] ?? [];

          return PageView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final p = data[index];
              final name = p['name'] as String;
              final idStr = (p['id'] as int).toString().padLeft(3, '0');

              // 🧩 Sprite seguro (Map o String)
              final spriteData =
              p['pokemon_v2_pokemonsprites']?.first?['sprites'];
              String imageUrl = '';
              if (spriteData != null) {
                if (spriteData is String) {
                  final decoded = jsonDecode(spriteData);
                  imageUrl = decoded['front_default'] ?? '';
                } else if (spriteData is Map) {
                  imageUrl = spriteData['front_default'] ?? '';
                }
              }

              final types = (p['pokemon_v2_pokemontypes'] as List)
                  .map((t) => t['pokemon_v2_type']['name'] as String)
                  .toList();
              final primary = types.isNotEmpty ? types.first : 'normal';
              final baseColor = typeColor[primary] ?? typeColor['normal']!;

              return Center(
                child: _PokemonCard(
                  id: idStr,
                  name: name,
                  imageUrl: imageUrl,
                  types: types,
                  color: baseColor,
                  typeColor: typeColor,
                  iconForType: iconForType,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  const _PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.color,
    required this.typeColor,
    required this.iconForType,
  });

  final String id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final Color color;
  final Map<String, Color> typeColor;
  final IconData Function(String) iconForType;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final cardW = w * 0.92;
    final cardH = h * 0.88;

    return Container(
      width: cardW,
      height: cardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.75), width: 4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            spreadRadius: 2,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 🔵 Header superior del color del tipo
          Container(
            height: cardH * 0.38,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.95),
            ),
          ),

          // ⚪ Cuerpo blanco con pokeball de fondo
          Positioned(
            top: cardH * 0.30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: 0.06,
                      child: _PokeballBG(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🆔 Nombre + ID
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '#$id ${name[0].toUpperCase()}${name.substring(1)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 🔵 Aro (color del tipo principal) + Pokémon encima
          Positioned(
            top: cardH * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: color, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      height: 180,
                      fit: BoxFit.contain,
                    )
                        : Icon(Icons.catching_pokemon,
                        size: 128, color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
          ),

          // 🟢 Badges redondos con borde blanco (sin sombras)
          Positioned(
            top: cardH * 0.255,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                // 👇 Duplica si solo hay un tipo para mantener simetría
                types.length == 1 ? 2 : types.length,
                    (i) {
                  final t = types.length == 1 ? types.first : types[i];
                  final tColor = typeColor[t] ?? Colors.grey;

                  return Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tColor,
                              border: Border.all(
                                color: Colors.white, // 🔲 borde blanco
                                width: 5, // igual que el aro del Pokémon
                              ),
                            ),
                            child: Icon(
                              iconForType(t),
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: const TextStyle(
                                color: Color(0xFF4A4E55),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (i != (types.length == 1 ? 1 : types.length - 1))
                        const SizedBox(width: 200),
                    ],
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// 🎯 Fallback Pokéball si no tienes la imagen
class _PokeballBG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) * 0.7;
      return Icon(Icons.catching_pokemon,
          size: size, color: Colors.black.withOpacity(0.15));
    });
  }
}
