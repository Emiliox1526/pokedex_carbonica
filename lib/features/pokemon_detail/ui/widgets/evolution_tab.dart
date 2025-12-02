import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../domain/pokemon_evolution.dart';
import '../../../../core/utils/type_utils.dart';
import '../../../../core/utils/sprite_utils.dart';
import 'detail_card.dart';
import 'type_chip.dart';

/// The Evolution tab displaying the Pokemon's evolution chain.
class EvolutionTab extends StatelessWidget {
  /// The evolution chain data.
  final List<PokemonEvolution> evolutionChain;

  /// The species name for fallback query.
  final String speciesName;

  const EvolutionTab({
    super.key,
    required this.evolutionChain,
    required this.speciesName,
  });

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      background: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Evolution Chart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (evolutionChain.isNotEmpty)
            _buildEvolutionChain(evolutionChain)
          else
            _buildFallbackQuery(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEvolutionChain(List<PokemonEvolution> chain) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Column(
        children: [
          for (var i = 0; i < chain.length; i++) ...[
            _EvolutionNode(
              id: chain[i].speciesId,
              name: chain[i].name,
              types: chain[i].types,
            ),
            if (i < chain.length - 1)
              _EvolutionTransition(
                minLevel: chain[i + 1].minLevel,
                triggerName: chain[i + 1].trigger,
                itemName: chain[i + 1].item,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackQuery(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Query(
        options: QueryOptions(
          document: gql(_evolutionBySpeciesQuery),
          variables: {'name': speciesName.toLowerCase()},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (result.hasException) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'Error loading evolution data',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            );
          }

          final speciesList =
              (result.data?['pokemon_v2_pokemonspecies'] as List?) ?? [];
          if (speciesList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 64.0),
              child: Center(child: Text('No evolution data available')),
            );
          }

          final chain = (speciesList.first['pokemon_v2_evolutionchain']
                  ?['pokemon_v2_pokemonspecies'] as List?) ??
              [];
          final chainItems = chain.cast<Map<String, dynamic>>();

          if (chainItems.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 64.0),
              child: Center(child: Text('No evolution data available')),
            );
          }

          return Column(
            children: [
              for (var i = 0; i < chainItems.length; i++) ...[
                _EvolutionNode(
                  id: (chainItems[i]['id'] as int?) ?? 0,
                  name: (chainItems[i]['name'] as String?) ?? '',
                  types: _extractTypesFromSpecies(chainItems[i]),
                ),
                if (i < chainItems.length - 1)
                  _EvolutionTransition(
                    minLevel: _extractEvolutionData(chainItems[i + 1])['min_level'] as int?,
                    triggerName:
                        _extractEvolutionData(chainItems[i + 1])['trigger'] as String?,
                    itemName: _extractEvolutionData(chainItems[i + 1])['item'] as String?,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<String> _extractTypesFromSpecies(Map<String, dynamic> species) {
    final pokemons = (species['pokemon_v2_pokemons'] as List?) ?? [];
    if (pokemons.isEmpty) return ['normal'];
    final pokemonTypes =
        (pokemons.first['pokemon_v2_pokemontypes'] as List?) ?? [];
    final types = pokemonTypes
        .map((t) => (t['pokemon_v2_type']?['name'] as String?) ?? 'normal')
        .where((t) => t.isNotEmpty)
        .toList();
    return types.isNotEmpty ? types : ['normal'];
  }

  Map<String, dynamic> _extractEvolutionData(Map<String, dynamic> nextSpecies) {
    final evolutions =
        (nextSpecies['pokemon_v2_pokemonevolutions'] as List?) ?? [];
    if (evolutions.isEmpty) {
      return {'min_level': null, 'trigger': null, 'item': null};
    }
    final evo = evolutions.first as Map<String, dynamic>;
    return {
      'min_level': evo['min_level'] as int?,
      'trigger': evo['pokemon_v2_evolutiontrigger']?['name'] as String?,
      'item': evo['pokemon_v2_item']?['name'] as String?,
    };
  }
}

// GraphQL query for evolution chain by species name
const String _evolutionBySpeciesQuery = r'''
  query GetEvolutionBySpeciesName($name: String!) {
    pokemon_v2_pokemonspecies(where: {name: {_eq: $name}}) {
      id
      name
      pokemon_v2_evolutionchain {
        id
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemonevolutions {
            min_level
            pokemon_v2_evolutiontrigger {
              name
            }
            pokemon_v2_item {
              name
            }
          }
          pokemon_v2_pokemons(limit: 1) {
            pokemon_v2_pokemontypes {
              pokemon_v2_type {
                name
              }
            }
          }
        }
      }
    }
  }
''';

class _EvolutionNode extends StatelessWidget {
  final int id;
  final String name;
  final List<String> types;

  const _EvolutionNode({
    required this.id,
    required this.name,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w)
        .join(' ');

    final artworkUrl = artworkUrlForId(id);
    final primaryType = types.isNotEmpty ? types.first : 'normal';
    final secondaryType = types.length > 1 ? types[1] : primaryType;
    final primaryColor = typeColor[primaryType] ?? typeColor['normal']!;
    final secondaryColor = typeColor[secondaryType] ?? typeColor['normal']!;

    return Column(
      children: [
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '#${id.toString().padLeft(3, "0")}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(130),
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(130),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.network(
                    artworkUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -45,
              top: 50,
              child: TypeIconCircle(type: primaryType),
            ),
            Positioned(
              right: -45,
              top: 50,
              child: TypeIconCircle(type: secondaryType),
            ),
          ],
        ),
      ],
    );
  }
}

class _EvolutionTransition extends StatelessWidget {
  final int? minLevel;
  final String? triggerName;
  final String? itemName;

  const _EvolutionTransition({
    this.minLevel,
    this.triggerName,
    this.itemName,
  });

  String _getTriggerLabel(String? trigger) {
    if (trigger == null) return '—';
    switch (trigger) {
      case 'level-up':
        return 'Lv.';
      case 'trade':
        return 'Trade';
      case 'use-item':
        return 'Item';
      case 'shed':
        return 'Shed';
      default:
        return trigger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUseItem = triggerName == 'use-item' && itemName != null;
    final isLevelUp =
        triggerName == 'level-up' || (minLevel != null && minLevel! > 0);

    return Column(
      children: [
        const SizedBox(height: 4),
        Transform.translate(
          offset: const Offset(0, -20),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade600,
              border: Border.all(color: Colors.white, width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isUseItem
                  ? ClipOval(
                      child: Image.network(
                        getItemSpriteUrl(itemName!),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Text(
                      isLevelUp && minLevel != null
                          ? 'Lv.${minLevel!}'
                          : _getTriggerLabel(triggerName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Transform.translate(
          offset: const Offset(0, -30),
          child: Icon(
            Icons.arrow_downward,
            size: 42,
            color: Colors.red.shade600,
            shadows: [
              Shadow(
                color: Colors.red.shade600,
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -30),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
