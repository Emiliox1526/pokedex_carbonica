import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_carbonica/gen/l10n/app_localizations.dart';

import '../../core/providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({
    super.key,
    this.iconColor = Colors.white,
  });

  final Color iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final String currentCode = (locale?.languageCode ?? 'es').toLowerCase();

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.8), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            context,
            ref,
            code: 'es',
            label: 'ES',
            tooltip: l10n.languageSpanish,
            isActive: currentCode == 'es',
          ),
          _buildSegment(
            context,
            ref,
            code: 'en',
            label: 'EN',
            tooltip: l10n.languageEnglish,
            isActive: currentCode == 'en',
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
      BuildContext context,
      WidgetRef ref, {
        required String code,
        required String label,
        required String tooltip,
        required bool isActive,
      }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
            // Update the locale using the notifier's setLocale method
            ref.read(localeProvider.notifier).setLocale(Locale(code));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isActive
                ? iconColor.withOpacity(0.9)
                : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: isActive ? Colors.black : iconColor.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
