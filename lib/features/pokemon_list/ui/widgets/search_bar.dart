import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../l10n/l10n_extension.dart';

class PokemonSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const PokemonSearchBar({
    super.key,
    this.onChanged,
  });

  @override
  State<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends State<PokemonSearchBar> {
  final _controller = TextEditingController();
  bool _isFocused = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChangedDebounced(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      widget.onChanged?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Menú
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                final scaffold = Scaffold.maybeOf(context);
                if (scaffold?.hasDrawer ?? false) {
                  scaffold!.openDrawer();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // Search
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() => _isFocused = hasFocus);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: _isFocused
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _onChangedDebounced, // <-- CAMBIA ESTO
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF454545),
                    letterSpacing: 0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.searchByNameOrId,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      letterSpacing: 0.2,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        Icons.search_rounded,
                        color: _isFocused ? Colors.grey[700] : Colors.grey[400],
                        size: 22,
                      ),
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                      ),
                    )
                        : null,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 50,
                    ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}