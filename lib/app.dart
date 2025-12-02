import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'common/widgets/language_selector.dart';
import 'core/providers/locale_provider.dart';
import 'features/pokemon_list/ui/pokemon_list_screen.dart';

/// Widget principal de la aplicación Pokédex.
///
/// Configura los providers de GraphQL y Riverpod necesarios
/// para el funcionamiento de la aplicación.
class PokedexApp extends ConsumerWidget {
  final ValueNotifier<GraphQLClient> graphQLClient;

  const PokedexApp({super.key, required this.graphQLClient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return GraphQLProvider(
      client: graphQLClient,
      child: CacheProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pokédex Carbonica',
          theme: ThemeData(
            colorSchemeSeed: Colors.red,
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          // Usar la nueva pantalla con Clean Architecture
          home: Stack(
            children: [
              const PokemonListScreenNew(),
              // Selector flotante para cambiar de idioma rápidamente
              Positioned(
                right: 12,
                top: 12,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: LanguageSelector(
                      iconColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
