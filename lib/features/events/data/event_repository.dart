import '../../../core/networking/api_client.dart';
import '../../../shared/models/enrollment.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/ride.dart';

class EventRepository {
  EventRepository(this._api);

  final ApiClient _api;

  Future<List<HostedEvent>> listEvents({String? status}) {
    return _api.get(
      '/events',
      query: {
        'status': ?status,
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

  Future<List<HostedEvent>> myUpcoming() {
    return _api.get(
      '/events',
      query: const {'mine': true, 'upcoming': true},
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => HostedEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<HostedEvent> createEvent(Map<String, dynamic> payload) {
    return _api.post(
      '/events',
      data: payload,
      parser: (data) => HostedEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<HostedEvent> updateEvent(String eventId, Map<String, dynamic> payload) {
    return _api.put(
      '/events/$eventId',
      data: payload,
      parser: (data) => HostedEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<HostedEvent>> hostEvents() {
    return _api.get(
      '/hosts/me/events',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => HostedEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<EventParticipant>> participants(String eventId) {
    return _api.get(
      '/events/$eventId/participants',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => EventParticipant.fromJson(e as Map<String, dynamic>))
            .toList();
      },
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
      '/events/$eventId/recommendations',
      data: {
        'riderId': riderId,
        'points': points,
        'note': ?note,
      },
      parser: (_) => true,
    );
  }
}
