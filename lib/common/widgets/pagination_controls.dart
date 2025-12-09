import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../extensions/l10n_extension.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final bool isLoading;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final Color primaryColor;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.isLoading,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(64),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF050A24),
                accent.withOpacity(0.45),
                accent.withOpacity(0.35),
                const Color(0xFF050A24),

              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                enabled: hasPreviousPage && !isLoading,
                onTap: onPreviousPage,
                accent: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (context) => Text(
                        context.l10n.pageOf(currentPage.toString(), totalPages.toString()),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: accent, // o primaryColor
                          ),
                        ),

                        if (isLoading) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(1),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                enabled: hasNextPage && !isLoading,
                onTap: onNextPage,
                accent: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color accent;

  const _NavButton({
    Key? key,
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.accent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor = enabled
        ? null
        : Colors.white.withOpacity(0.10);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: baseColor,
            gradient: enabled
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withOpacity(0.95),
                accent.withOpacity(0.65),
              ],
            )
                : null,
            boxShadow: enabled
                ? [
              BoxShadow(
                color: accent.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Icon(
            icon,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
