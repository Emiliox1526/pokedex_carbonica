import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_carbonica/features/map/domain/route_area_mapping.dart';

void main() {
  group('RouteAreaMapping', () {
    test('should return correct area identifier for route 1', () {
      final areaId = RouteAreaMapping.getAreaIdentifier(1);
      expect(areaId, 'kanto-route-1-area');
    });

    test('should return correct area identifier for route 22', () {
      final areaId = RouteAreaMapping.getAreaIdentifier(22);
      expect(areaId, 'kanto-route-22-area');
    });

    test('should return null for unmapped route', () {
      final areaId = RouteAreaMapping.getAreaIdentifier(999);
      expect(areaId, null);
    });

    test('should have mappings for all 23 Kanto routes', () {
      for (int i = 1; i <= 23; i++) {
        final areaId = RouteAreaMapping.getAreaIdentifier(i);
        expect(areaId, isNotNull, reason: 'Route $i should have a mapping');
      }
    });

    test('should return sea routes for routes 19-21', () {
      expect(
        RouteAreaMapping.getAreaIdentifier(19),
        'kanto-sea-route-19-area',
      );
      expect(
        RouteAreaMapping.getAreaIdentifier(20),
        'kanto-sea-route-20-area',
      );
      expect(
        RouteAreaMapping.getAreaIdentifier(21),
        'kanto-sea-route-21-area',
      );
    });

    test('should return all area identifiers including alternatives', () {
      final route2Areas = RouteAreaMapping.getAllAreaIdentifiers(2);
      expect(route2Areas.length, greaterThan(0));
      expect(route2Areas.first, contains('route-2'));
    });

    test('should return primary area when no alternatives exist', () {
      final route1Areas = RouteAreaMapping.getAllAreaIdentifiers(1);
      expect(route1Areas, contains('kanto-route-1-area'));
    });

    test('should return empty list for unmapped route', () {
      final route999Areas = RouteAreaMapping.getAllAreaIdentifiers(999);
      expect(route999Areas, isEmpty);
    });
  });
}
