import 'package:flutter/material.dart';

/// Widget de chip de tipo de Pokémon.
/// 
/// Muestra un tipo de Pokémon con su icono y nombre en un
/// contenedor estilizado con el color correspondiente al tipo.
class TypeChip extends StatelessWidget {
  /// Nombre del tipo.
  final String label;

  /// Color del tipo.
  final Color color;

  /// Icono del tipo.
  final IconData icon;

  /// Indica si está seleccionado (para filtros).
  final bool isSelected;

  /// Callback cuando se toca el chip.
  final VoidCallback? onTap;

  /// Constructor del widget.
  const TypeChip({
    super. key,
    required this.label,
    required this.color,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves. easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: isSelected
              ?  [
            BoxShadow(
              color: color. withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        transform: Matrix4. identity()..scale(isSelected ?  1.05 : 1.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ?  Colors.white : color.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _capitalize(label),
                    style: TextStyle(
                      color: isSelected ?  Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Grid de chips de tipos para filtrar.
///
/// Muestra todos los tipos de Pokémon en un grid responsive
/// con animaciones de selección.
class TypeChipGrid extends StatelessWidget {
  /// Lista de todos los tipos disponibles.
  static const List<String> allTypes = [
    'normal', 'fire', 'water', 'grass', 'electric', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic',
    'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
  ];

  /// Tipos actualmente seleccionados.
  final Set<String> selectedTypes;

  /// Mapa de colores por tipo.
  final Map<String, Color> typeColors;

  /// Función para obtener el icono de un tipo.
  final IconData Function(String) iconForType;

  /// Callback cuando se activa/desactiva un tipo.
  final void Function(String type, bool selected) onToggleType;

  /// Constructor del widget.
  const TypeChipGrid({
    super.key,
    required this.selectedTypes,
    required this.typeColors,
    required this.iconForType,
    required this.onToggleType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula el número de columnas basado en el ancho disponible
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = availableWidth < 200 ? 2 : 3;

        // Ajusta el aspect ratio según el ancho disponible
        final itemWidth = (availableWidth - (crossAxisCount - 1) * 8) / crossAxisCount;
        final childAspectRatio = itemWidth / 32; // altura fija de ~32

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 6,
          childAspectRatio: childAspectRatio. clamp(2.0, 3.5),
          children: allTypes. map((type) {
            return TweenAnimationBuilder<double>(
              tween: Tween(
                begin: selectedTypes.contains(type) ? 1.0 : 0.0,
                end: selectedTypes. contains(type) ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 250),
              builder: (context, value, child) {
                return TypeChip(
                  label: type,
                  color: typeColors[type] ?? Colors.grey,
                  icon: iconForType(type),
                  isSelected: selectedTypes.contains(type),
                  onTap: () => onToggleType(type, !selectedTypes.contains(type)),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}