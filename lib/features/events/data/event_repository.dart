import '../../../core/networking/api_client.dart';
import '../../../shared/models/enrollment.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/ride.dart';

class EventRepository {
  EventRepository(this._api);

  final ApiClient _api;

  Future<List<HostedEvent>> listEvents({
    String? status,
    String? trailId,
    bool? mine,
  }) {
    return _api.get(
      '/events',
      query: {
        'status': ?status,
        'trailId': ?trailId,
        if (mine == true) 'mine': true,
      },
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => HostedEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<HostedEvent> getEvent(String eventId) {
    return _api.get(
      '/events/$eventId',
      parser: (data) => HostedEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Enrollment> enrol(String eventId) {
    return _api.post(
      '/events/$eventId/enrol',
      parser: (data) => Enrollment.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Enrollment>> listMyEnrollments() {
    return _api.get(
      '/enrollments/me',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => Enrollment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<Enrollment> getEnrollment(String enrollmentId) {
    return _api.get(
      '/enrollments/$enrollmentId',
      parser: (data) => Enrollment.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AttendanceResult> markAttendance(
    String eventId, {
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) {
    return _api.post(
      '/events/$eventId/attendance',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
      },
      parser: (data) => AttendanceResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<HostedEvent>> myUpcoming() async {
    final enrollments = await listMyEnrollments();
    final activeEventIds = enrollments
        .where(
          (e) =>
              e.status == EnrollmentStatus.confirmed ||
              e.status == EnrollmentStatus.pendingPayment,
        )
        .map((e) => e.eventId)
        .toSet();

    final events = <HostedEvent>[];
    for (final eventId in activeEventIds) {
      try {
        events.add(await getEvent(eventId));
      } catch (_) {
        // Skip events that fail to load.
      }
    }

    final now = DateTime.now();
    events.sort((a, b) {
      final aStart = a.startDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bStart = b.startDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aStart.compareTo(bStart);
    });
    return events
        .where((e) => e.startDateTime == null || !e.startDateTime!.isBefore(now))
        .toList();
  }

  Future<HostedEvent> createEvent(Map<String, dynamic> payload) {
    return _api.post(
      '/events',
      data: payload,
      parser: (data) => HostedEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<HostedEvent> updateEvent(String eventId, Map<String, dynamic> payload) {
    return _api.patch(
      '/events/$eventId',
      data: payload,
      parser: (data) => HostedEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Host dashboard: list events owned by the current host via GET /events.
  Future<List<HostedEvent>> hostEvents() {
    return listEvents(mine: true);
  }

  Future<List<EventParticipant>> participants(String eventId) {
    return _api.get(
      '/events/$eventId/attendance',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => EventParticipant.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<HostedEvent> startEvent(String eventId) {
    return _api.post(
      '/events/$eventId/start',
      parser: (data) => HostedEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> completeEvent(
    String eventId, {
    required List<String> participantRiderIds,
  }) async {
    await _api.post(
      '/events/$eventId/complete',
      data: {'participantRiderIds': participantRiderIds},
      parser: (_) => true,
    );
  }

  Future<void> awardRecommendation({
    required String eventId,
    required String riderId,
    required int points,
    String? note,
  }) async {
    await _api.post(
      '/recommendations/events/$eventId/awards',
      data: {
        'riderId': riderId,
        'points': points,
        'note': ?note,
      },
      parser: (_) => true,
    );
  }

  Future<void> suspendEvent(String eventId) async {
    await _api.patch(
      '/events/$eventId',
      data: {'status': 'CANCELLED'},
      parser: (_) => true,
    );
  }
}
