import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/pokeapi_location_area_service.dart';
import '../../domain/location_area_models.dart';
import '../../../../l10n/l10n_extension.dart';

/// Modal bottom sheet that displays Pokémon encounters for a location area
///
/// Shows loading, error, and success states with encounter details including
/// method, version, level range, and encounter chance.
class AreaEncountersModal extends StatefulWidget {
  /// Area identifier (can be name or ID) to fetch encounters for
  final String areaIdentifier;

  /// Display name for the area (shown in title)
  final String areaDisplayName;

  const AreaEncountersModal({
    super.key,
    required this.areaIdentifier,
    required this.areaDisplayName,
  });

  @override
  State<AreaEncountersModal> createState() => _AreaEncountersModalState();
}

class _AreaEncountersModalState extends State<AreaEncountersModal> {
  final PokeApiLocationAreaService _service = PokeApiLocationAreaService();
  late Future<LocationAreaResponse> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _service.fetchLocationArea(widget.areaIdentifier);
  }

  void _retry() {
    setState(() {
      _dataFuture = _service.fetchLocationArea(widget.areaIdentifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1420), Color(0xFF0B0E16)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              _buildHeader(context),
              const Divider(color: Color(0xFF2A2D35), height: 1),
              // Content
              Expanded(
                child: FutureBuilder<LocationAreaResponse>(
                  future: _dataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    } else if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error);
                    } else if (snapshot.hasData) {
                      return _buildSuccessState(
                        snapshot.data!,
                        scrollController,
                      );
                    } else {
                      return _buildEmptyState();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.encountersInArea,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.areaDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF5C6BC0),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.loadingEncounters,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    String errorMessage = context.l10n.errorLoadingEncounters;
    if (error is AreaNotFoundException) {
      errorMessage = context.l10n.areaNotFound;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noEncountersData,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(
    LocationAreaResponse data,
    ScrollController scrollController,
  ) {
    if (data.pokemonEncounters.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: data.pokemonEncounters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final encounter = data.pokemonEncounters[index];
        return _PokemonEncounterCard(encounter: encounter);
      },
    );
  }
}

/// Card displaying a single Pokémon encounter with expandable details
class _PokemonEncounterCard extends StatefulWidget {
  final PokemonEncounter encounter;

  const _PokemonEncounterCard({required this.encounter});

  @override
  State<_PokemonEncounterCard> createState() => _PokemonEncounterCardState();
}

class _PokemonEncounterCardState extends State<_PokemonEncounterCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.encounter.pokemon;
    final pokemonName = _capitalizeName(pokemon.name);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1D26).withOpacity(0.8),
            const Color(0xFF151821).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pokemon header
                Row(
                  children: [
                    // Sprite
                    _buildSprite(pokemon.spriteUrl),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Text(
                        pokemonName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // Expand icon
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white70,
                    ),
                  ],
                ),
                // Expandable details
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2A2D35), height: 1),
                  const SizedBox(height: 12),
                  ..._buildEncounterDetails(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSprite(String? spriteUrl) {
    if (spriteUrl == null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.catching_pokemon,
          color: Colors.white.withOpacity(0.3),
          size: 32,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: spriteUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.catching_pokemon,
            color: Colors.white.withOpacity(0.3),
            size: 32,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEncounterDetails() {
    final details = <Widget>[];

    for (final versionDetail in widget.encounter.versionDetails) {
      // Version header
      details.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.videogame_asset,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                _capitalizeVersion(versionDetail.version.name),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );

      // Encounter details
      for (final detail in versionDetail.encounterDetails) {
        details.add(
          Padding(
            padding: const EdgeInsets.only(left: 22, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    detail.method.spanishName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    detail.levelRange,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  detail.chancePercentage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      details.add(const SizedBox(height: 8));
    }

    return details;
  }

  String _capitalizeName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');
  }

  String _capitalizeVersion(String version) {
    if (version.isEmpty) return version;
    return version
        .split('-')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1)
            : word)
        .join(' ');
  }
}
