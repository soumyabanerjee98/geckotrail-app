import 'package:equatable/equatable.dart';

enum RideStatus { active, paused, completed, abandoned }

enum SyncState { recorded, synced, verified, verificationFailed }

class RouteAccess extends Equatable {
  const RouteAccess({
    required this.id,
    required this.trailId,
    required this.trailName,
    this.region,
    this.status = 'ACTIVE',
    this.familiarityLevel,
    this.verifiedCompletionCount,
    this.lastCompletedAt,
  });

  final String id;
  final String trailId;
  final String trailName;
  final String? region;
  final String status;
  final String? familiarityLevel;
  final int? verifiedCompletionCount;
  final DateTime? lastCompletedAt;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory RouteAccess.fromJson(Map<String, dynamic> json) {
    return RouteAccess(
      id: json['id']?.toString() ?? json['trailId'].toString(),
      trailId: json['trailId'].toString(),
      trailName: json['trailName']?.toString() ??
          (json['trail'] is Map ? (json['trail'] as Map)['name']?.toString() : '') ??
          '',
      region: json['region']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      familiarityLevel: json['familiarityLevel']?.toString(),
      verifiedCompletionCount: (json['verifiedCompletionCount'] as num?)?.toInt(),
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.tryParse(json['lastCompletedAt'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, trailId, status];
}

class RouteGeometry extends Equatable {
  const RouteGeometry({
    required this.trailId,
    required this.points,
    this.start,
    this.end,
  });

  final String trailId;
  final List<LatLngPoint> points;
  final LatLngPoint? start;
  final LatLngPoint? end;

  factory RouteGeometry.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List? ??
        json['coordinates'] as List? ??
        (json['geometry'] is Map ? (json['geometry'] as Map)['coordinates'] as List? : null) ??
        const [];
    final points = rawPoints.map((e) {
      if (e is List && e.length >= 2) {
        return LatLngPoint(
          latitude: (e[1] as num).toDouble(),
          longitude: (e[0] as num).toDouble(),
        );
      }
      if (e is Map) {
        return LatLngPoint(
          latitude: (e['lat'] as num? ?? e['latitude'] as num).toDouble(),
          longitude: (e['lng'] as num? ?? e['longitude'] as num).toDouble(),
        );
      }
      throw FormatException('Invalid route point: $e');
    }).toList();

    return RouteGeometry(
      trailId: json['trailId']?.toString() ?? '',
      points: points,
      start: points.isNotEmpty ? points.first : null,
      end: points.length > 1 ? points.last : null,
    );
  }

  @override
  List<Object?> get props => [trailId, points.length];
}

class LatLngPoint extends Equatable {
  const LatLngPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  List<Object?> get props => [latitude, longitude];
}

class RideSession extends Equatable {
  const RideSession({
    required this.id,
    required this.trailId,
    this.status = RideStatus.active,
    this.startedAt,
    this.endedAt,
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.syncState = SyncState.recorded,
  });

  final String id;
  final String trailId;
  final RideStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double distanceMeters;
  final int durationSeconds;
  final SyncState syncState;

  factory RideSession.fromJson(Map<String, dynamic> json) {
    return RideSession(
      id: json['id'].toString(),
      trailId: json['trailId'].toString(),
      status: _parseRideStatus(json['status']?.toString()),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'].toString())
          : null,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      syncState: _parseSync(json['syncState']?.toString()),
    );
  }

  @override
  List<Object?> get props => [id, status, syncState];
}

class RouteCompletionResult extends Equatable {
  const RouteCompletionResult({
    required this.verificationStatus,
    this.familiarityLevel,
    this.message,
  });

  final String verificationStatus;
  final String? familiarityLevel;
  final String? message;

  bool get verified => verificationStatus.toUpperCase() == 'VERIFIED';

  factory RouteCompletionResult.fromJson(Map<String, dynamic> json) {
    return RouteCompletionResult(
      verificationStatus: json['verificationStatus']?.toString() ?? 'UNKNOWN',
      familiarityLevel: json['familiarityLevel']?.toString() ??
          (json['familiarity'] is Map
              ? (json['familiarity'] as Map)['level']?.toString()
              : null),
      message: json['message']?.toString(),
    );
  }

  @override
  List<Object?> get props => [verificationStatus];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.read = false,
    this.createdAt,
    this.type,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;
  final String? type;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      read: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      type: json['type']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, read];
}

class EventParticipant extends Equatable {
  const EventParticipant({
    required this.riderId,
    required this.name,
    this.enrollmentStatus,
    this.attendanceStatus,
    this.markedParticipant = false,
  });

  final String riderId;
  final String name;
  final String? enrollmentStatus;
  final String? attendanceStatus;
  final bool markedParticipant;

  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return EventParticipant(
      riderId: json['riderId']?.toString() ?? json['id'].toString(),
      name: json['name']?.toString() ?? '',
      enrollmentStatus: json['enrollmentStatus']?.toString(),
      attendanceStatus: json['attendanceStatus']?.toString(),
      markedParticipant: json['markedParticipant'] == true ||
          json['isParticipant'] == true,
    );
  }

  @override
  List<Object?> get props => [riderId, markedParticipant];
}

RideStatus _parseRideStatus(String? value) {
  switch (value?.toUpperCase()) {
    case 'PAUSED':
      return RideStatus.paused;
    case 'COMPLETED':
      return RideStatus.completed;
    case 'ABANDONED':
      return RideStatus.abandoned;
    default:
      return RideStatus.active;
  }
}

SyncState _parseSync(String? value) {
  switch (value?.toUpperCase()) {
    case 'SYNCED':
      return SyncState.synced;
    case 'VERIFIED':
      return SyncState.verified;
    case 'VERIFICATION_FAILED':
      return SyncState.verificationFailed;
    default:
      return SyncState.recorded;
  }
}
