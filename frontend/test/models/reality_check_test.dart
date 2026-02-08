import 'package:flutter_test/flutter_test.dart';
import 'package:recur/models/reality_check.dart';

void main() {
  group('RealityCheck', () {
    test('fromJson parses API response', () {
      final json = {
        'id': 'id-1',
        'name': 'Check hands',
        'type': 'interval',
        'interval_minutes': 120,
        'event_description': null,
        'is_active': true,
      };
      final rc = RealityCheck.fromJson(json);
      expect(rc.id, 'id-1');
      expect(rc.name, 'Check hands');
      expect(rc.type, 'interval');
      expect(rc.intervalMinutes, 120);
      expect(rc.eventDescription, isNull);
      expect(rc.isActive, true);
    });

    test('toJson round-trip', () {
      final rc = RealityCheck(
        id: 'id-2',
        name: 'Event check',
        type: 'event',
        intervalMinutes: null,
        eventDescription: 'When you see your pet',
        isActive: false,
      );
      final json = rc.toJson();
      expect(RealityCheck.fromJson(json), equals(rc));
    });

    test('equality and hashCode', () {
      final a = RealityCheck(
        id: 'x',
        name: 'N',
        type: 'interval',
        intervalMinutes: 60,
        isActive: true,
      );
      final b = RealityCheck(
        id: 'x',
        name: 'N',
        type: 'interval',
        intervalMinutes: 60,
        isActive: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
