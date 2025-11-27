import 'package:flutter/material.dart';

/// Controles de paginación para la lista de Pokémon.
/// 
/// Muestra botones de navegación y la información de página actual.
/// Formato: `[←] Página 1 de 45 [→]`
class PaginationControls extends StatelessWidget {
  /// Página actual (base 1).
  final int currentPage;
  
  /// Total de páginas.
  final int totalPages;
  
  /// Indica si hay página anterior.
  final bool hasPreviousPage;
  
  /// Indica si hay página siguiente.
  final bool hasNextPage;
  
  /// Indica si está cargando.
  final bool isLoading;
  
  /// Callback para ir a la página anterior.
  final VoidCallback? onPreviousPage;
  
  /// Callback para ir a la página siguiente.
  final VoidCallback? onNextPage;
  
  /// Color principal para los controles.
  final Color primaryColor;

  /// Constructor del widget.
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    this.isLoading = false,
    this.onPreviousPage,
    this.onNextPage,
    this.primaryColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          _PaginationButton(
            icon: Icons.chevron_left,
            enabled: hasPreviousPage && !isLoading,
            onPressed: onPreviousPage,
            primaryColor: primaryColor,
          ),
          
          const SizedBox(width: 16),
          
          // Indicador de página
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          else
            Text(
              totalPages > 0
                  ? 'Página $currentPage de $totalPages'
                  : 'Sin resultados',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          
          const SizedBox(width: 16),
          
          // Botón siguiente
          _PaginationButton(
            icon: Icons.chevron_right,
            enabled: hasNextPage && !isLoading,
            onPressed: onNextPage,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

/// Botón individual de paginación.
class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color primaryColor;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? primaryColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled
                  ? primaryColor.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: enabled
                ? primaryColor
                : Colors.grey.withOpacity(0.4),
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Widget compacto de información de paginación para mostrar en el header.
class PaginationInfo extends StatelessWidget {
  /// Página actual.
  final int currentPage;
  
  /// Total de páginas.
  final int totalPages;
  
  /// Total de elementos.
  final int totalCount;

  /// Constructor del widget.
  const PaginationInfo({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        totalCount > 0
            ? '$totalCount Pokémon encontrados'
            : 'Sin resultados',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
