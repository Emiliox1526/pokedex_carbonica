import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_carbonica/l10n/app_localizations.dart';

import '../../core/providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key, this.iconColor = Colors.white});

  final Color iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final currentLanguageCode = locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final currentLanguageName = currentLanguageCode == 'es'
        ? l10n.languageSpanish
        : l10n.languageEnglish;

    return Semantics(
      label: l10n.languageButtonLabel(currentLanguageName),
      button: true,
      child: PopupMenuButton<Locale>(
        tooltip: l10n.languageButtonTooltip,
        icon: Icon(Icons.language, color: iconColor),
        onSelected: (selected) => ref.read(localeProvider.notifier).setLocale(selected),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: const Locale('es'),
            child: Text(l10n.languageSpanish),
          ),
          PopupMenuItem(
            value: const Locale('en'),
            child: Text(l10n.languageEnglish),
          ),
        ],
      ),
    );
  }
}
