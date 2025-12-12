import 'package:flutter/material.dart';

import 'type_chip.dart';
import '../../../favorites/ui/favorites_screen.dart';
import '../../../game/ui/who_is_pokemon_screen.dart';
import 'language_selector.dart';
import '../../../../l10n/l10n_extension.dart';

/// Drawer de generaciones y filtros para la Pokédex.
/// Permite al usuario filtrar Pokémon por generación y tipos.
/// Muestra las imágenes de cada región como banners seleccionables.
class GenerationDrawer extends StatelessWidget {
  /// Callback cuando se selecciona una generación.
  final ValueChanged<int> onSelectGeneration;

  /// Mapa de colores por tipo.
  final Map<String, Color> typeColors;

  /// Tipos actualmente seleccionados.
  final Set<String> selectedTypes;

  /// Callback cuando se activa/desactiva un tipo.
  final void Function(String type, bool selected) onToggleType;

  /// Función para obtener el icono de un tipo.
  final IconData Function(String type) iconForType;

  final int? selectedGeneration;

  /// Constructor del widget.
  const GenerationDrawer({
    super.key,
    required this.onSelectGeneration,
    required this.typeColors,
    required this.selectedTypes,
    required this.onToggleType,
    required this.iconForType,
    this.selectedGeneration,
  });

  // Colores del tema Pokédex
  static const Color _dexBurgundy = Color(0xFF102A40);
  static const Color _dexDeep = Color(0xFF09174E);
  static const Color _dexDark = Color(0xFF050A24);
  static const Color _dexWhite = Color(0xFFFFFFFF);

  static const Map<int, Color> _regionColors = {
    1: Color(0xFFEF5350),
    2: Color(0xFFFFCA28),
    3: Color(0xFF26A69A),
    4: Color(0xFF42A5F5),
    5: Color(0xFF7E57C2),
    6: Color(0xFFEC407A),
    7: Color(0xFF26C6DA),
    8: Color(0xFFD81B60),
    9: Color(0xFFFF7043),
  };

  static Color _regionColorForGeneration(int? generation) {
    return _regionColors[generation] ?? const Color(0xFFEF5350);
  }

  static const Map<int, String> _generationBackgroundImages = {
    0: 'lib/assets/AllGenerations.png',
    1: 'lib/assets/kanto.png',
    2: 'lib/assets/johto.png',
    3: 'lib/assets/hoenn.png',
    4: 'lib/assets/sinnoh.png',
    5: 'lib/assets/unova.png',
    6: 'lib/assets/kalos.png',
    7: 'lib/assets/alola.png',
    8: 'lib/assets/galar.png',
    9: 'lib/assets/paldea.png',
  };

  static String _assetForGeneration(int? generation) {
    return _generationBackgroundImages[generation] ??
        _generationBackgroundImages[0]!;
  }

  @override
  Widget build(BuildContext context) {
    // Configuración de banners de regiones
    final regionBanners = [
      {"title": "", "image": "lib/assets/AllGenerations.png"},
      {"title": "", "image": "lib/assets/kanto.png"},
      {"title": "", "image": "lib/assets/johto.png"},
      {"title": "", "image": "lib/assets/hoenn.png"},
      {"title": "", "image": "lib/assets/sinnoh.png"},
      {"title": "", "image": "lib/assets/unova.png"},
      {"title": "", "image": "lib/assets/kalos.png"},
      {"title": "", "image": "lib/assets/alola.png"},
      {"title": "", "image": "lib/assets/galar.png"},
      {"title": "", "image": "lib/assets/paldea.png"},
    ];
    final Color regionAccent = _regionColorForGeneration(selectedGeneration);
    return Drawer(
      elevation: 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              regionAccent.withOpacity(1),
              const Color(0xFF050A24),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.catching_pokemon,
                      color: _dexWhite,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.pokedexRegional,
                      style: const TextStyle(
                        color: _dexWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1.4, color: _dexWhite),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Favorites option
                        _FavoritesOption(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FavoritesScreen(
                                  selectedGeneration: selectedGeneration,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        // Game option - ¿Quién es este Pokémon?
                        _GameOption(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WhoIsPokemonScreen(
                                  selectedGeneration: selectedGeneration, // <- aquí, NO lo olvides
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        // Map option - Mapa interactivo
                        _MapOption(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed('/map');
                          },
                        ),
                        const SizedBox(height: 16),
                        // App language toggle
                        const _LanguageOption(),
                        const SizedBox(height: 18),
                        Container(height: 1.4, color: _dexWhite),
                        const SizedBox(height: 14),
                        // Sección de configuración
                        Text(
                          context.l10n.configuration,
                          style: const TextStyle(
                            color: _dexWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Grid de filtros de tipos
                        TypeChipGrid(
                          selectedTypes: selectedTypes,
                          typeColors: typeColors,
                          iconForType: iconForType,
                          onToggleType: onToggleType,
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1.4, color: _dexWhite),
                        const SizedBox(height: 14),
                        // Sección de filtro por generación
                        Text(
                          context.l10n.generation,
                          style: const TextStyle(
                            color: _dexWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Lista de regiones
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: regionBanners.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final region = regionBanners[index];
                            return _RegionBanner(
                              title: region["title"]!,
                              imagePath: region["image"]!,
                              onTap: () => onSelectGeneration(
                                  index == 0 ? 0 : index),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption();

  static const Color _dexWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final String code = locale.languageCode.toLowerCase();
    final String label = code == 'en'
        ? context.l10n.languageEnglish
        : context.l10n.languageSpanish;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _dexWhite.withOpacity(0.24),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            color: _dexWhite.withOpacity(0.95),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.appLanguage,
                  style: const TextStyle(
                    color: _dexWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: _dexWhite.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const LanguageSelector(
            iconColor: _dexWhite,
          ),
        ],
      ),
    );
  }
}

/// Favorites option button in the drawer.
class _FavoritesOption extends StatelessWidget {
  final VoidCallback onTap;

  const _FavoritesOption({required this.onTap});

  static const Color _dexWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x2C939393),
                Color(0x2C939393),
              ],
            ),
            border: Border.all(color: _dexWhite.withOpacity(0.5), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: _dexWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Builder(
                  builder: (context) => Text(
                    context.l10n.myFavorites,
                    style: const TextStyle(
                      color: _dexWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _dexWhite,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Game option button in the drawer - ¿Quién es este Pokémon?
class _GameOption extends StatelessWidget {
  final VoidCallback onTap;

  const _GameOption({required this.onTap});

  static const Color _dexWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x2C939393),
                Color(0x2C939393),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: _dexWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Builder(
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.whoIsPokemonGame,
                        style: const TextStyle(
                          color: _dexWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.triviaGame,
                        style: const TextStyle(
                          color: _dexWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner de región individual.
class _RegionBanner extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _RegionBanner({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  static const Color _dexWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xCC7A0A16),
                Color(0xCC4E0911),
              ],
            ),
            border: Border.all(color: _dexWhite, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imagePath.isNotEmpty)
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0x1A000000),
                        Colors.transparent,
                        Color(0x1A000000),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _dexWhite.withOpacity(.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _dexWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: .4,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _dexWhite,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapOption extends StatelessWidget {
  final VoidCallback onTap;

  const _MapOption({required this.onTap});

  static const Color _dexWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x2C939393),
                Color(0x2C939393),
              ],
            ),
            border: Border.all(color: _dexWhite.withOpacity(0.5), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.map,
                  color: _dexWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Mapa',
                  style: TextStyle(
                    color: _dexWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _dexWhite,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}