import 'package:flutter_test/flutter_test.dart';
import 'package:gecko_trail/shared/models/trail.dart';
import 'package:gecko_trail/shared/models/event.dart';
import 'package:gecko_trail/shared/models/enrollment.dart';

void main() {
  test('TrailSummary parses access states', () {
    final trail = TrailSummary.fromJson({
      'id': 't1',
      'name': 'Himalayan Loop',
      'region': 'Himachal',
      'accessState': 'UNLOCKED',
      'ecoSensitive': true,
      'distance': 42.5,
    });
    expect(trail.accessState, TrailAccessState.unlocked);
    expect(trail.ecoSensitive, isTrue);
    expect(trail.distanceKm, 42.5);
  });

  test('HostedEvent parses capacity and price', () {
    final event = HostedEvent.fromJson({
      'id': 'e1',
      'title': 'Dawn Ride',
      'trailId': 't1',
      'capacity': 10,
      'enrolledCount': 10,
      'price': 1500,
      'status': 'FULL',
    });
    expect(event.isFull, isTrue);
    expect(event.price, 1500);
  });

  test('AttendanceResult maps outside radius', () {
    final result = AttendanceResult.fromJson({
      'verificationStatus': 'REJECTED',
      'code': 'OUTSIDE_RADIUS',
      'message': 'Move closer to the meetup point.',
    });
    expect(result.uiState, AttendanceUiState.outsideRadius);
  });
}
