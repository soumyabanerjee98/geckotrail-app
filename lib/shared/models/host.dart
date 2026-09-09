import 'package:equatable/equatable.dart';

enum HostApplicationStatus { none, pending, approved, rejected }

class HostProfile extends Equatable {
  const HostProfile({
    required this.userId,
    this.status = HostApplicationStatus.pending,
    this.experienceYears,
    this.regions = const [],
    this.familiarTrails,
    this.motivation,
    this.bikeInfo,
    this.certificateFileName,
    this.ridesLed,
    this.upcomingCount,
    this.ridersLed,
    this.avgRating,
    this.displayName,
    this.photoUrl,
    this.submittedAt,
  });

  final String userId;
  final HostApplicationStatus status;
  final int? experienceYears;
  final List<String> regions;
  final String? familiarTrails;
  final String? motivation;
  final String? bikeInfo;
  final String? certificateFileName;
  final int? ridesLed;
  final int? upcomingCount;
  final int? ridersLed;
  final double? avgRating;
  final String? displayName;
  final String? photoUrl;
  final DateTime? submittedAt;

  bool get isApproved => status == HostApplicationStatus.approved;
  bool get isPending => status == HostApplicationStatus.pending;

  factory HostProfile.fromJson(Map<String, dynamic> json) {
    final regionsRaw = json['regions'] ?? json['regionsOfExpertise'];
    return HostProfile(
      userId: (json['userId'] ?? json['id'] ?? json['hostId']).toString(),
      status: _parseStatus(json['status']?.toString() ?? json['hostStatus']?.toString()),
      experienceYears: (json['experienceYears'] as num?)?.toInt() ??
          (json['ridingExperienceYears'] as num?)?.toInt(),
      regions: regionsRaw is List
          ? regionsRaw.map((e) => e.toString()).toList()
          : (regionsRaw?.toString().isNotEmpty == true
              ? regionsRaw.toString().split(',').map((e) => e.trim()).toList()
              : const []),
      familiarTrails: json['familiarTrails']?.toString() ??
          json['curatedTrailsFamiliarWith']?.toString(),
      motivation: json['motivation']?.toString() ?? json['bio']?.toString(),
      bikeInfo: json['bikeInfo']?.toString() ?? json['motorcycleDetails']?.toString(),
      certificateFileName: json['certificateFileName']?.toString(),
      ridesLed: (json['ridesLed'] as num?)?.toInt(),
      upcomingCount: (json['upcomingCount'] as num?)?.toInt(),
      ridersLed: (json['ridersLed'] as num?)?.toInt(),
      avgRating: (json['avgRating'] as num?)?.toDouble(),
      displayName: json['displayName']?.toString() ??
          json['name']?.toString() ??
          (json['user'] is Map ? (json['user'] as Map)['name']?.toString() : null),
      photoUrl: json['photoUrl']?.toString() ??
          (json['user'] is Map ? (json['user'] as Map)['photoUrl']?.toString() : null),
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
    );
  }

  static HostApplicationStatus _parseStatus(String? value) {
    return parseHostApplicationStatus(value);
  }

  @override
  List<Object?> get props => [userId, status];
}

HostApplicationStatus parseHostApplicationStatus(String? value) {
  switch (value?.toUpperCase()) {
    case 'APPROVED':
    case 'VERIFIED':
      return HostApplicationStatus.approved;
    case 'REJECTED':
      return HostApplicationStatus.rejected;
    case 'PENDING':
    case 'PENDING_REVIEW':
      return HostApplicationStatus.pending;
    case 'NONE':
    case null:
    case '':
      return HostApplicationStatus.none;
    default:
      return HostApplicationStatus.pending;
  }
}
