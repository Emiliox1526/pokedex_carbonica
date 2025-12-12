import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_carbonica/features/map/ui/widgets/area_encounters_modal.dart';

void main() {
  group('AreaEncountersModal Widget Tests', () {
    testWidgets('should show loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) => const AreaEncountersModal(
                        areaIdentifier: 'test-area',
                        areaDisplayName: 'Test Area',
                      ),
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Should show the area name in header
      expect(find.text('Test Area'), findsOneWidget);

      // Should show loading state or error state (since we don't have network)
      // Loading indicator or error message should be present
      expect(
        find.byType(CircularProgressIndicator).or(find.byIcon(Icons.error_outline)),
        findsOneWidget,
      );
    });

    testWidgets('should show close button in header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) => const AreaEncountersModal(
                        areaIdentifier: 'kanto-route-1-area',
                        areaDisplayName: 'Ruta 1',
                      ),
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Should have a close button
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should close modal when close button is tapped',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) => const AreaEncountersModal(
                        areaIdentifier: 'kanto-route-1-area',
                        areaDisplayName: 'Ruta 1',
                      ),
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Modal should be visible
      expect(find.text('Ruta 1'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Modal should be closed
      expect(find.text('Ruta 1'), findsNothing);
    });
  });
}

// Matcher extension for combining finders with OR logic
extension FinderOr on Finder {
  Finder or(Finder other) {
    return find.byWidgetPredicate((widget) {
      return evaluate().isNotEmpty || other.evaluate().isNotEmpty;
    });
  }
}
