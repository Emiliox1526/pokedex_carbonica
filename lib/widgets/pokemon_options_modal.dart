import 'package:flutter/material.dart';

/// Enum for Pokemon form categories
enum PokemonFormCategory {
  defaultForm,
  alolan,
  galarian,
  hisuian,
  paldean,
  mega,
  gigantamax,
  special,
}

/// Extension to add helper methods to PokemonFormCategory
extension PokemonFormCategoryExtension on PokemonFormCategory {
  /// Get the display name for this category
  String get displayName {
    switch (this) {
      case PokemonFormCategory.defaultForm:
        return 'Default';
      case PokemonFormCategory.alolan:
        return 'Alolan';
      case PokemonFormCategory.galarian:
        return 'Galarian';
      case PokemonFormCategory.hisuian:
        return 'Hisuian';
      case PokemonFormCategory.paldean:
        return 'Paldean';
      case PokemonFormCategory.mega:
        return 'Mega';
      case PokemonFormCategory.gigantamax:
        return 'Gigantamax';
      case PokemonFormCategory.special:
        return 'Special';
    }
  }

  /// Get the color associated with this category
  Color get color {
    switch (this) {
      case PokemonFormCategory.defaultForm:
        return const Color(0xFF78909C); // Blue-grey
      case PokemonFormCategory.alolan:
        return const Color(0xFF4FC3F7); // Light blue - tropical
      case PokemonFormCategory.galarian:
        return const Color(0xFF7E57C2); // Purple - UK inspired
      case PokemonFormCategory.hisuian:
        return const Color(0xFF8D6E63); // Brown - ancient
      case PokemonFormCategory.paldean:
        return const Color(0xFFFFB74D); // Orange - Spanish inspired
      case PokemonFormCategory.mega:
        return const Color(0xFFE91E63); // Pink - power
      case PokemonFormCategory.gigantamax:
        return const Color(0xFFFF5722); // Deep orange - giant
      case PokemonFormCategory.special:
        return const Color(0xFFFFD700); // Gold
    }
  }

  /// Get the icon for this category
  IconData get icon {
    switch (this) {
      case PokemonFormCategory.defaultForm:
        return Icons.catching_pokemon;
      case PokemonFormCategory.alolan:
        return Icons.beach_access;
      case PokemonFormCategory.galarian:
        return Icons.shield;
      case PokemonFormCategory.hisuian:
        return Icons.landscape;
      case PokemonFormCategory.paldean:
        return Icons.castle;
      case PokemonFormCategory.mega:
        return Icons.flash_on;
      case PokemonFormCategory.gigantamax:
        return Icons.height;
      case PokemonFormCategory.special:
        return Icons.star;
    }
  }
}

/// Represents a Pokemon form variant
class PokemonFormVariant {
  final int id;
  final String name;
  final String displayName;
  final PokemonFormCategory category;
  final int pokemonId;
  final String? spriteUrl;
  final String? shinySpriteUrl;
  final List<String> types;

  const PokemonFormVariant({
    required this.id,
    required this.name,
    required this.displayName,
    required this.category,
    required this.pokemonId,
    this.spriteUrl,
    this.shinySpriteUrl,
    required this.types,
  });

  /// Determine the category from a form name
  static PokemonFormCategory getCategoryFromName(String formName) {
    final lowerName = formName.toLowerCase();
    if (lowerName.contains('alola') || lowerName.contains('alolan')) {
      return PokemonFormCategory.alolan;
    } else if (lowerName.contains('galar') || lowerName.contains('galarian')) {
      return PokemonFormCategory.galarian;
    } else if (lowerName.contains('hisui') || lowerName.contains('hisuian')) {
      return PokemonFormCategory.hisuian;
    } else if (lowerName.contains('paldea') || lowerName.contains('paldean')) {
      return PokemonFormCategory.paldean;
    } else if (lowerName.contains('mega') || lowerName.contains('-mega')) {
      return PokemonFormCategory.mega;
    } else if (lowerName.contains('gmax') || lowerName.contains('gigantamax')) {
      return PokemonFormCategory.gigantamax;
    } else if (formName.isEmpty || lowerName == 'default' || lowerName == 'normal') {
      return PokemonFormCategory.defaultForm;
    } else {
      return PokemonFormCategory.special;
    }
  }

  /// Get icon for a specific category
  static IconData getIconForCategory(PokemonFormCategory category) {
    return category.icon;
  }

  /// Get color for a specific category
  static Color getColorForCategory(PokemonFormCategory category) {
    return category.color;
  }
}

class PokemonOptionsModal extends StatefulWidget {
  const PokemonOptionsModal({
    Key? key,
    required this.baseColor,
    required this.secondaryColor,
    required this.initialShowShiny,
    required this.initialIsFavorite,
    required this.onlyLevelUp,
    required this.movesMethod,
    required this.movesSort,
    required this.onToggleShiny,
    required this.onToggleFavorite,
    required this.onChangeMovesMethod,
    required this.onChangeMovesSort,
    required this.onToggleOnlyLevelUp,
    this.availableForms,
    this.selectedFormId,
    this.onFormSelected,
    this.pokemonName,
  }) : super(key: key);

  final Color baseColor;
  final Color secondaryColor;
  final bool initialShowShiny;
  final bool initialIsFavorite;
  final bool onlyLevelUp;
  final String movesMethod;
  final String movesSort;

  final VoidCallback onToggleShiny;
  final VoidCallback onToggleFavorite;
  final ValueChanged<String> onChangeMovesMethod;
  final ValueChanged<String> onChangeMovesSort;
  final VoidCallback onToggleOnlyLevelUp;

  // New parameters for form selection
  final List<PokemonFormVariant>? availableForms;
  final int? selectedFormId;
  final ValueChanged<PokemonFormVariant>? onFormSelected;
  final String? pokemonName;

  @override
  State<PokemonOptionsModal> createState() => _PokemonOptionsModalState();
}

class _PokemonOptionsModalState extends State<PokemonOptionsModal>
    with TickerProviderStateMixin {
  late bool _showShiny;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  // Form dropdown state
  bool _isFormDropdownExpanded = false;
  late AnimationController _dropdownAnimationController;
  late Animation<double> _dropdownRotationAnimation;
  late Animation<double> _dropdownHeightAnimation;

  @override
  void initState() {
    super.initState();
    _showShiny = widget.initialShowShiny;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Initialize dropdown animation controller
    _dropdownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _dropdownRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _dropdownAnimationController, curve: Curves.easeInOut),
    );

    _dropdownHeightAnimation = CurvedAnimation(
      parent: _dropdownAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dropdownAnimationController.dispose();
    super.dispose();
  }

  void _handleToggleShiny() {
    setState(() {
      _showShiny = !_showShiny;
    });
    _animationController.forward(from: 0);
    widget.onToggleShiny();
  }

  void _toggleFormDropdown() {
    setState(() {
      _isFormDropdownExpanded = !_isFormDropdownExpanded;
    });
    if (_isFormDropdownExpanded) {
      _dropdownAnimationController.forward();
    } else {
      _dropdownAnimationController.reverse();
    }
  }

  void _selectForm(PokemonFormVariant form) {
    widget.onFormSelected?.call(form);
    _toggleFormDropdown();
  }

  // Get the currently selected form
  PokemonFormVariant? get _selectedForm {
    if (widget.availableForms == null || widget.selectedFormId == null) {
      return null;
    }
    try {
      return widget.availableForms!.firstWhere((f) => f.id == widget.selectedFormId);
    } catch (_) {
      return widget.availableForms!.isNotEmpty ? widget.availableForms!.first : null;
    }
  }

  // Group forms by category
  Map<PokemonFormCategory, List<PokemonFormVariant>> get _groupedForms {
    if (widget.availableForms == null) return {};
    final Map<PokemonFormCategory, List<PokemonFormVariant>> grouped = {};
    for (final form in widget.availableForms!) {
      if (!grouped.containsKey(form.category)) {
        grouped[form.category] = [];
      }
      grouped[form.category]!.add(form);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMultipleForms = widget.availableForms != null && widget.availableForms!.length > 1;
    
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, -6)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tune, size: 22, color: widget.baseColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form dropdown (only show if there are multiple forms)
              if (hasMultipleForms) ...[
                _buildFormDropdown(),
                const SizedBox(height: 12),
              ],

              // Shiny toggle card with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _showShiny
                            ? widget.baseColor.withOpacity(0.5 + (_glowAnimation.value * 0.5))
                            : Colors.grey.shade200,
                        width: _showShiny ? 2 : 1,
                      ),
                      boxShadow: _showShiny
                          ? [
                        BoxShadow(
                          color: widget.baseColor.withOpacity(0.3 * _glowAnimation.value),
                          blurRadius: 12 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Icon with scale animation
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.baseColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _showShiny ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                              color: widget.baseColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Show Shiny',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _showShiny ? widget.baseColor : Colors.black,
                                ),
                              ),
                              Text(
                                _showShiny ? 'Shiny sprite enabled ✨' : 'Toggle shiny sprite',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _showShiny
                                      ? widget.baseColor.withOpacity(0.7)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Animated switch with Pokemon colors
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _showShiny
                                ? [
                              BoxShadow(
                                color: widget.baseColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                                : null,
                          ),
                          child: Switch(
                            value: _showShiny,
                            activeColor: widget.baseColor,
                            activeTrackColor: widget.baseColor.withOpacity(0.5),
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade300,
                            splashRadius: 20,
                            onChanged: (_) => _handleToggleShiny(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the form selection dropdown widget
  Widget _buildFormDropdown() {
    final selectedForm = _selectedForm;
    final groupedForms = _groupedForms;
    
    if (selectedForm == null) return const SizedBox.shrink();

    final categoryColor = selectedForm.category.color;
    final categoryIcon = selectedForm.category.icon;
    final formsCount = widget.availableForms?.length ?? 0;

    return Column(
      children: [
        // Dropdown header
        GestureDetector(
          onTap: _toggleFormDropdown,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColor.withOpacity(0.1),
                  categoryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Form name and type chips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedForm.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Forms count indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$formsCount forms',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Type chips
                      _buildTypeChips(selectedForm.types),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Animated arrow
                RotationTransition(
                  turns: _dropdownRotationAnimation,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: categoryColor,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded dropdown list
        SizeTransition(
          sizeFactor: _dropdownHeightAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build sections for each category
                    for (final entry in groupedForms.entries) ...[
                      _buildCategoryHeader(entry.key),
                      for (final form in entry.value)
                        _buildFormItem(form, form.id == widget.selectedFormId),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds type chips for a form
  Widget _buildTypeChips(List<String> types) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: types.map((type) {
        final color = _getTypeColor(type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds a category header for the dropdown
  Widget _buildCategoryHeader(PokemonFormCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              category.icon,
              size: 14,
              color: category.color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: category.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    category.color.withOpacity(0.3),
                    category.color.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single form item in the dropdown list
  Widget _buildFormItem(PokemonFormVariant form, bool isSelected) {
    final categoryColor = form.category.color;
    
    return GestureDetector(
      onTap: () => _selectForm(form),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? categoryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? categoryColor.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Sprite thumbnail
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: form.spriteUrl != null
                    ? Image.network(
                        form.spriteUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.catching_pokemon, color: Colors.grey.shade400),
                      )
                    : Icon(Icons.catching_pokemon, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),
            // Form name and types
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildTypeChips(form.types),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? categoryColor : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected ? categoryColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for a Pokemon type
  Color _getTypeColor(String type) {
    const Map<String, Color> typeColors = {
      "normal": Color(0xFF9BA0A8),
      "fire": Color(0xFFFF6B3D),
      "water": Color(0xFF4C90FF),
      "electric": Color(0xFFFFD037),
      "grass": Color(0xFF6BD64A),
      "ice": Color(0xFF64DDF8),
      "fighting": Color(0xFFE34343),
      "poison": Color(0xFFB24ADD),
      "ground": Color(0xFFE2B36B),
      "flying": Color(0xFFA890F7),
      "psychic": Color(0xFFFF4888),
      "bug": Color(0xFF88C12F),
      "rock": Color(0xFFC9B68B),
      "ghost": Color(0xFF6F65D8),
      "dragon": Color(0xFF7366FF),
      "dark": Color(0xFF5A5A5A),
      "steel": Color(0xFF8AA4C1),
      "fairy": Color(0xFFFF78D5),
    };
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }
}

// Widget helper para AnimatedBuilder
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    Key? key,
    required Animation<double> animation,
    required this.builder,
    this. child,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}