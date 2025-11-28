import 'package:flutter/material.dart';

import 'type_chip.dart';
import '../screens/favorites/favorites_screen.dart';

/// Drawer de generaciones y filtros para la Pokédex.
/// 
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

  /// Constructor del widget.
  const GenerationDrawer({
    super.key,
    required this.onSelectGeneration,
    required this.typeColors,
    required this.selectedTypes,
    required this.onToggleType,
    required this.iconForType,
  });

  // Colores del tema Pokédex
  static const Color _dexBurgundy = Color(0xFF7A0A16);
  static const Color _dexDeep = Color(0xFF4E0911);
  static const Color _dexDark = Color(0xFF240507);
  static const Color _dexWhite = Color(0xFFFFFFFF);

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

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_dexBurgundy, _dexDeep, _dexDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                const Row(
                  children: [
                    Icon(
                      Icons.catching_pokemon,
                      color: _dexWhite,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Pokédex Regional",
                      style: TextStyle(
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

                // Favorites option
                _FavoritesOption(
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Container(height: 1.4, color: _dexWhite),
                const SizedBox(height: 14),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de configuración
                        const Text(
                          "Configuración",
                          style: TextStyle(
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
                        const Text(
                          "Generación",
                          style: TextStyle(
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
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final region = regionBanners[index];
                            return _RegionBanner(
                              title: region["title"]!,
                              imagePath: region["image"]!,
                              onTap: () => onSelectGeneration(index == 0 ? 0 : index),
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
                Color(0xCC7A0A16),
                Color(0xCC4E0911),
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
              const Expanded(
                child: Text(
                  'Mis Favoritos',
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
                // Imagen de la región
                if (imagePath.isNotEmpty)
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),

                // Overlay de gradiente
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

                // Contenido
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
