import 'package:flutter/material.dart';

import '../../domain/pokemon_move.dart';
import '../../../../core/utils/type_utils.dart';
import '../../../../core/utils/string_utils.dart';
import 'detail_card.dart';

/// The Moves tab displaying the Pokemon's learnable moves with filtering and pagination.
class MovesTab extends StatelessWidget {
  /// Default number of moves per page.
  static const int _defaultPerPage = 10;

  /// All moves for the Pokemon.
  final List<PokemonMove> moves;

  /// The primary color for the UI.
  final Color baseColor;

  /// Current filter method (level-up, machine, egg, tutor).
  final String methodFilter;

  /// Current sort order (level, name).
  final String sortOrder;

  /// Current page (0-indexed).
  final int currentPage;

  /// Number of moves per page.
  final int perPage;

  /// Callback when filter method changes.
  final ValueChanged<String> onChangeMethod;

  /// Callback when sort order changes.
  final ValueChanged<String> onChangeSort;

  /// Callback when page changes.
  final ValueChanged<int> onPageChange;

  /// Callback when per page changes.
  final ValueChanged<int> onPerPageChange;

  const MovesTab({
    super.key,
    required this.moves,
    required this.baseColor,
    required this.methodFilter,
    required this.sortOrder,
    required this.currentPage,
    required this.perPage,
    required this.onChangeMethod,
    required this.onChangeSort,
    required this.onPageChange,
    required this.onPerPageChange,
  });

  @override
  Widget build(BuildContext context) {
    // Apply filters
    List<PokemonMove> filtered = moves.where((m) => m.learnMethod == methodFilter).toList();

    // Apply sort
    if (sortOrder == 'level') {
      filtered.sort((a, b) {
        final la = a.level ?? 9999;
        final lb = b.level ?? 9999;
        if (la != lb) return la.compareTo(lb);
        return a.name.compareTo(b.name);
      });
    } else {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    // Pagination
    final totalMoves = filtered.length;
    final totalPages = (totalMoves / perPage).ceil();
    final safeCurrentPage =
        totalPages > 0 ? currentPage.clamp(0, totalPages - 1) : 0;
    final startIndex = safeCurrentPage * perPage;
    final endIndex = (startIndex + perPage).clamp(0, totalMoves);
    final visibleMoves =
        totalMoves > 0 ? filtered.sublist(startIndex, endIndex) : <PokemonMove>[];

    return DetailCard(
      background: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Moves',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters section
          _buildFiltersSection(context),
          const SizedBox(height: 16),

          // Moves count
          if (totalMoves > 0)
            Center(
              child: Text(
                '$totalMoves moves found',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          const SizedBox(height: 8),

          // Moves list
          if (visibleMoves.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: [
                for (final mv in visibleMoves) _buildMoveItem(mv),
              ],
            ),

          // Pagination controls
          if (totalPages > 1)
            _buildPaginationControls(safeCurrentPage, totalPages),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method filter chips
          Text(
            'Learn Method',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMethodFilterChip('Level-up', 'level-up'),
              _buildMethodFilterChip('TM/HM', 'machine'),
              _buildMethodFilterChip('Tutor', 'tutor'),
              _buildMethodFilterChip('Egg', 'egg'),
            ],
          ),
          const SizedBox(height: 12),

          // Sort and items per page
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildSortToggle(),
              _buildPerPageSelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodFilterChip(String label, String value) {
    final selected = methodFilter == value;
    return GestureDetector(
      onTap: () => onChangeMethod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? baseColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? baseColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildSortToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sort: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        GestureDetector(
          onTap: () => onChangeSort(sortOrder == 'level' ? 'name' : 'level'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: baseColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sortOrder == 'level' ? Icons.trending_up : Icons.sort_by_alpha,
                  size: 14,
                  color: baseColor,
                ),
                const SizedBox(width: 4),
                Text(
                  sortOrder == 'level' ? 'Level' : 'Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: baseColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerPageSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Per page: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: perPage,
              isDense: true,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5')),
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 15, child: Text('15')),
                DropdownMenuItem(value: 20, child: Text('20')),
              ],
              onChanged: (v) => onPerPageChange(v ?? _defaultPerPage),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No moves found with current filters',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveItem(PokemonMove mv) {
    final moveName = capitalize(mv.name);
    final moveColor = typeColor[mv.type.toLowerCase()] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level circle or TM indicator
          if (mv.isLevelUp && mv.level != null)
            _buildLevelIndicator(mv.level!)
          else if (mv.isMachine)
            _buildTmIndicator(mv)
          else
            const SizedBox(width: 48),

          // Move name
          Expanded(
            flex: 3,
            child: Text(
              moveName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Type chip
          if (mv.type.isNotEmpty)
            _buildMoveTypeChip(mv.type)
          else
            const SizedBox(width: 60),
          const SizedBox(width: 8),

          // Damage class icon
          if (mv.damageClass.isNotEmpty)
            _buildDamageClassIndicator(mv.damageClass)
          else
            const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(int level) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: baseColor, width: 2),
      ),
      child: Center(
        child: Text(
          level.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: baseColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTmIndicator(PokemonMove mv) {
    final moveColor = typeColor[mv.type.toLowerCase()] ?? Colors.grey;
    return Container(
      width: 48,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mv.tmSpriteUrl != null)
            Image.network(
              mv.tmSpriteUrl!,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.album,
                  size: 32,
                  color: moveColor,
                );
              },
            )
          else
            Icon(
              Icons.album,
              size: 32,
              color: moveColor,
            ),
          if (mv.tmLabel != null)
            Text(
              mv.tmLabel!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMoveTypeChip(String typeName) {
    final color = typeColor[typeName.toLowerCase()] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconForType(typeName.toLowerCase()),
            size: 12,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 4),
          Text(
            typeName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageClassIndicator(String damageClass) {
    final IconData icon;
    final Color color;

    switch (damageClass.toLowerCase()) {
      case 'physical':
        icon = Icons.fitness_center;
        color = Colors.orange.shade600;
        break;
      case 'special':
        icon = Icons.auto_awesome;
        color = Colors.blue.shade600;
        break;
      case 'status':
        icon = Icons.swap_horiz;
        color = Colors.grey.shade600;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey.shade400;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildPaginationControls(int safeCurrentPage, int totalPages) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: safeCurrentPage > 0
                ? () => onPageChange(safeCurrentPage - 1)
                : null,
            icon: Icon(
              Icons.chevron_left,
              color:
                  safeCurrentPage > 0 ? baseColor : Colors.grey.shade300,
            ),
            splashRadius: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Page ${safeCurrentPage + 1} of $totalPages',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          IconButton(
            onPressed: safeCurrentPage < totalPages - 1
                ? () => onPageChange(safeCurrentPage + 1)
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: safeCurrentPage < totalPages - 1
                  ? baseColor
                  : Colors.grey.shade300,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
