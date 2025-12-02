import 'package:flutter/material.dart';

/// Barra de búsqueda personalizada para la Pokédex.
/// 
/// Incluye un botón de menú para abrir el drawer y un campo
/// de texto para buscar Pokémon por nombre o ID.
class PokemonSearchBar extends StatelessWidget {
  /// Callback cuando cambia el texto de búsqueda.
  final ValueChanged<String>? onChanged;
  
  /// Texto placeholder del campo de búsqueda.
  final String hintText;

  /// Constructor del widget.
  const PokemonSearchBar({
    super.key,
    this.onChanged,
    this.hintText = 'Buscar por nombre o #ID',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.hasDrawer ?? false) {
              scaffold!.openDrawer();
            }
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
