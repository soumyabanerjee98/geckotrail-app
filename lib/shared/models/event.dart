import 'package:equatable/equatable.dart';

enum EventStatus {
  draft,
  published,
  open,
  full,
  started,
  completed,
  cancelled,
}

class HostedEvent extends Equatable {
  const HostedEvent({
    required this.id,
    required this.title,
    required this.trailId,
    this.trailName,
    this.hostId,
    this.hostName,
    this.hostPhotoUrl,
    this.startDateTime,
    this.endDateTime,
    this.meetupLatitude,
    this.meetupLongitude,
    this.attendanceRadiusMeters,
    this.attendanceStartTime,
    this.attendanceEndTime,
    this.capacity,
    this.enrolledCount,
    this.price,
    this.currency = 'INR',
    this.requirements,
    this.safetyInstructions,
    this.environmentalInstructions,
    this.description,
    this.status = EventStatus.published,
  });

  final String id;
  final String title;
  final String trailId;
  final String? trailName;
  final String? hostId;
  final String? hostName;
  final String? hostPhotoUrl;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final double? meetupLatitude;
  final double? meetupLongitude;
  final double? attendanceRadiusMeters;
  final DateTime? attendanceStartTime;
  final DateTime? attendanceEndTime;
  final int? capacity;
  final int? enrolledCount;
  final double? price;
  final String currency;
  final String? requirements;
  final String? safetyInstructions;
  final String? environmentalInstructions;
  final String? description;
  final EventStatus status;

  bool get isFull => status == EventStatus.full ||
      (capacity != null && enrolledCount != null && enrolledCount! >= capacity!);

  int? get spotsLeft {
    if (capacity == null) return null;
    final enrolled = enrolledCount ?? 0;
    return (capacity! - enrolled).clamp(0, capacity!);
  }

  factory HostedEvent.fromJson(Map<String, dynamic> json) {
    return HostedEvent(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      trailId: json['trailId']?.toString() ?? '',
      trailName: json['trailName']?.toString() ??
          (json['trail'] is Map ? (json['trail'] as Map)['name']?.toString() : null),
      hostId: json['hostId']?.toString(),
      hostName: json['hostName']?.toString() ??
          (json['host'] is Map ? (json['host'] as Map)['name']?.toString() : null),
      hostPhotoUrl: json['hostPhotoUrl']?.toString(),
      startDateTime: _parseDate(json['startDateTime']),
      endDateTime: _parseDate(json['endDateTime']),
      meetupLatitude: _toDouble(json['meetupLatitude']),
      meetupLongitude: _toDouble(json['meetupLongitude']),
      attendanceRadiusMeters: _toDouble(json['attendanceRadiusMeters']),
      attendanceStartTime: _parseDate(json['attendanceStartTime']),
      attendanceEndTime: _parseDate(json['attendanceEndTime']),
      capacity: _toInt(json['capacity']),
      enrolledCount: _toInt(json['enrolledCount'] ?? json['participantCount']),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? 'INR',
      requirements: json['requirements']?.toString(),
      safetyInstructions: json['safetyInstructions']?.toString(),
      environmentalInstructions: json['environmentalInstructions']?.toString(),
      description: json['description']?.toString(),
      status: _parseStatus(json['status']?.toString()),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'trailId': trailId,
      'title': title,
      'description': description,
      'startDateTime': startDateTime?.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'meetupLatitude': meetupLatitude,
      'meetupLongitude': meetupLongitude,
      'attendanceRadiusMeters': attendanceRadiusMeters,
      'attendanceStartTime': attendanceStartTime?.toIso8601String(),
      'attendanceEndTime': attendanceEndTime?.toIso8601String(),
      'capacity': capacity,
      'price': price,
      'currency': currency,
      'requirements': requirements,
      'safetyInstructions': safetyInstructions,
      'environmentalInstructions': environmentalInstructions,
    };
  }

  @override
  List<Object?> get props => [id, title, status];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

EventStatus _parseStatus(String? value) {
  switch (value?.toUpperCase()) {
    case 'DRAFT':
      return EventStatus.draft;
    case 'OPEN':
      return EventStatus.open;
    case 'FULL':
      return EventStatus.full;
    case 'STARTED':
      return EventStatus.started;
    case 'COMPLETED':
      return EventStatus.completed;
    case 'CANCELLED':
      return EventStatus.cancelled;
    default:
      return EventStatus.published;
  }
}
