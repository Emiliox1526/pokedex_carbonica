import 'package:flutter/material.dart';

import '../../domain/pokemon_form_variant.dart';

class PokemonOptionsModal extends StatefulWidget {
  const PokemonOptionsModal({
    Key? key,
    required this. baseColor,
    required this.secondaryColor,
    required this. initialShowShiny,
    required this.initialIsFavorite,
    required this. onlyLevelUp,
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

  bool _isFormDropdownExpanded = false;
  late AnimationController _dropdownAnimationController;
  late Animation<double> _dropdownRotationAnimation;
  late Animation<double> _dropdownHeightAnimation;

  late AnimationController _formSelectionAnimationController;
  late Animation<double> _formScaleAnimation;
  late Animation<double> _formGlowAnimation;
  int?  _animatingFormId;

  // Estado interno del selectedFormId
  late int?  _internalSelectedFormId;

  @override
  void initState() {
    super.initState();
    _showShiny = widget.initialShowShiny;
    _internalSelectedFormId = widget.selectedFormId;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]). animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _dropdownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _dropdownRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _dropdownAnimationController, curve: Curves. easeInOut),
    );

    _dropdownHeightAnimation = CurvedAnimation(
      parent: _dropdownAnimationController,
      curve: Curves.easeInOut,
    );

    _formSelectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _formScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _formSelectionAnimationController,
      curve: Curves.easeInOut,
    ));

    _formGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _formSelectionAnimationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dropdownAnimationController.dispose();
    _formSelectionAnimationController.dispose();
    super. dispose();
  }

  void _handleToggleShiny() {
    setState(() {
      _showShiny = !_showShiny;
    });
    _animationController. forward(from: 0);
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
    if (form.id == _internalSelectedFormId) {
      _toggleFormDropdown();
      return;
    }

    setState(() {
      _animatingFormId = form.id;
    });

    _formSelectionAnimationController.forward(from: 0). then((_) {
      setState(() {
        _internalSelectedFormId = form.id;
        _animatingFormId = null;
      });

      widget.onFormSelected?.call(form);
      _toggleFormDropdown();
    });
  }

  PokemonFormVariant?  get _selectedForm {
    if (widget.availableForms == null || _internalSelectedFormId == null) {
      return null;
    }
    try {
      return widget.availableForms!.firstWhere((f) => f.id == _internalSelectedFormId);
    } catch (_) {
      return widget.availableForms!.isNotEmpty ? widget.availableForms! .first : null;
    }
  }

  Map<PokemonFormCategory, List<PokemonFormVariant>> get _groupedForms {
    if (widget.availableForms == null) return {};
    final Map<PokemonFormCategory, List<PokemonFormVariant>> grouped = {};
    for (final form in widget.availableForms!) {
      if (! grouped.containsKey(form. category)) {
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
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
            if (hasMultipleForms) ...[
        _buildFormDropdown(),
    const SizedBox(height: 12),
    ],
    AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
    return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.grey.shade50,
    borderRadius: BorderRadius.circular(16),
    border: Border. all(
    color: _showShiny
    ? widget.baseColor. withOpacity(0.5 + (_glowAnimation.value * 0.5))
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
    ScaleTransition(
    scale: _scaleAnimation,
    child: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: widget.baseColor. withOpacity(0.15),
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
        : Colors. grey.shade600,
    ),
    ),
    ],
    ),
    ),
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
    inactiveThumbColor: Colors. grey.shade400,
    inactiveTrackColor: Colors. grey.shade300,
    splashRadius: 20,
    onChanged: (_) => _handleToggleShiny(),
    ),
    ),
    ],
    ),
    );
    },
    ),
    const SizedBox(height: 28),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildFormDropdown() {
    final selectedForm = _selectedForm;
    final groupedForms = _groupedForms;

    if (selectedForm == null) return const SizedBox. shrink();

    final categoryColor = selectedForm.category.color;
    final categoryIcon = selectedForm.category.icon;
    final formsCount = widget.availableForms?.length ??  0;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _formSelectionAnimationController,
          builder: (context, child) {
            final isAnimating = _animatingFormId != null;
            final glowValue = isAnimating ? _formGlowAnimation.value : 0.0;

            return GestureDetector(
            onTap: _toggleFormDropdown,
            child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            gradient: LinearGradient(
            colors: [
            categoryColor.withOpacity(0.1 + (glowValue * 0.1)),
            categoryColor.withOpacity(0.05 + (glowValue * 0.1)),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
            color: categoryColor.withOpacity(0.3 + (glowValue * 0.4)),
            width: 1.5 + (glowValue * 0.5),
            ),
            boxShadow: [
            BoxShadow(
            color: categoryColor. withOpacity(0.1 + (glowValue * 0.2)),
            blurRadius: 8 + (glowValue * 8),
            offset: const Offset(0, 2),
            spreadRadius: glowValue * 2,
            ),
            ],
            ),
            child: Row(
            children: [
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
            Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
            children: [
            Expanded(
            child: Text(
            selectedForm. displayName,
            style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
            ),
            ),
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
            _buildTypeChips(selectedForm.types),
            ],
            ),
            ),
            const SizedBox(width: 8),
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
            );
          },
        ),
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
                  color: Colors. black.withOpacity(0.08),
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
                    for (final entry in groupedForms.entries) ...[
                      _buildCategoryHeader(entry.key),
                      for (final form in entry.value)
                        _buildFormItem(form, form.id == _internalSelectedFormId),
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
            type. toUpperCase(),
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
                    category.color. withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormItem(PokemonFormVariant form, bool isSelected) {
    final categoryColor = form.category.color;
    final isAnimating = _animatingFormId == form.id;

    return AnimatedBuilder(
      animation: _formSelectionAnimationController,
      builder: (context, child) {
        final scale = isAnimating ? _formScaleAnimation.value : 1.0;
        final glowValue = isAnimating ? _formGlowAnimation.value : 0.0;

        return Transform. scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _selectForm(form),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected || isAnimating
                    ? categoryColor.withOpacity(0.1 + (glowValue * 0.15))
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected || isAnimating
                      ? categoryColor.withOpacity(0.4 + (glowValue * 0.4))
                      : Colors.transparent,
                  width: 1.5 + (glowValue * 0.5),
                ),
                boxShadow: isAnimating
                    ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3 * glowValue),
                    blurRadius: 12 * glowValue,
                    spreadRadius: 2 * glowValue,
                  ),
                ]
                    : null,
              ),
              child: Row(
                children: [
                  Transform.scale(
                    scale: isAnimating ? 1.0 + (glowValue * 0.1) : 1.0,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isAnimating
                                ? categoryColor. withOpacity(0.3 * glowValue)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: isAnimating ?  8 * glowValue : 4,
                            offset: const Offset(0, 2),
                            spreadRadius: isAnimating ? glowValue : 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: form.spriteUrl != null
                            ?  Image.network(
                          form.spriteUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons. catching_pokemon, color: Colors.grey.shade400),
                        )
                            : Icon(Icons.catching_pokemon, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isAnimating || isSelected
                                ? categoryColor
                                : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTypeChips(form.types),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24 + (isAnimating ? glowValue * 4 : 0),
                    height: 24 + (isAnimating ? glowValue * 4 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected || isAnimating ?  categoryColor : Colors.grey.shade200,
                      border: Border.all(
                        color: isSelected || isAnimating ?  categoryColor : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isAnimating
                          ? [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.5 * glowValue),
                          blurRadius: 8 * glowValue,
                          spreadRadius: 2 * glowValue,
                        ),
                      ]
                          : null,
                    ),
                    child: isSelected || isAnimating
                        ?  Icon(
                      Icons.check,
                      size: 14 + (isAnimating ? glowValue * 2 : 0),
                      color: Colors. white,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
    return typeColors[type. toLowerCase()] ?? Colors.grey;
  }
}