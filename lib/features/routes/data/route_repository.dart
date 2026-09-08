import '../../../core/networking/api_client.dart';
import '../../../shared/models/ride.dart';

class RouteRepository {
  RouteRepository(this._api);

  final ApiClient _api;

  Future<List<RouteAccess>> myRoutes() {
    return _api.get(
      '/me/routes',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => RouteAccess.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<RouteAccess> checkAccess(String trailId) {
    return _api.get(
      '/routes/$trailId/access',
      parser: (data) => RouteAccess.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<RouteGeometry> loadGeometry(String trailId) {
    return _api.get(
      '/routes/$trailId/geometry',
      parser: (data) => RouteGeometry.fromJson({
        ...(data as Map<String, dynamic>),
        'trailId': trailId,
      }),
    );
  }
}

class RideRepository {
  RideRepository(this._api);

  final ApiClient _api;

  Future<RideSession> startRide({
    required String trailId,
    required double latitude,
    required double longitude,
  }) {
    return _api.post(
      '/rides',
      data: {
        'trailId': trailId,
        'startLatitude': latitude,
        'startLongitude': longitude,
      },
      parser: (data) => RideSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> syncTrackPoints({
    required String rideId,
    required List<Map<String, dynamic>> points,
  }) async {
    await _api.post(
      '/rides/$rideId/points',
      data: {'points': points},
      parser: (_) => true,
    );
  }

  Future<RouteCompletionResult> completeRide({
    required String rideId,
    required double latitude,
    required double longitude,
    required double distanceMeters,
    required int durationSeconds,
  }) {
    return _api.post(
      '/rides/$rideId/complete',
      data: {
        'endLatitude': latitude,
        'endLongitude': longitude,
        'distanceMeters': distanceMeters,
        'durationSeconds': durationSeconds,
      },
      parser: (data) =>
          RouteCompletionResult.fromJson(data as Map<String, dynamic>),
    );
  }
}

class NotificationRepository {
  NotificationRepository(this._api);

  final ApiClient _api;

  Future<List<AppNotification>> list() {
    return _api.get(
      '/notifications',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<void> markRead(String id) async {
    await _api.post(
      '/notifications/$id/read',
      parser: (_) => true,
    );
  }

  Future<void> registerDeviceToken(String token) async {
    await _api.post(
      '/notifications/devices',
      data: {'token': token, 'platform': 'fcm'},
      parser: (_) => true,
    );
  }
}

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> getProfile([String? userId]) {
    final path = userId == null ? '/users/me' : '/users/$userId';
    return _api.get(path, parser: (data) => data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) {
    return _api.patch(
      '/users/me',
      data: payload,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>?> getFamiliarity(String trailId) {
    return _api.get(
      '/trails/$trailId/familiarity',
      parser: (data) => data as Map<String, dynamic>?,
    );
  }
}
