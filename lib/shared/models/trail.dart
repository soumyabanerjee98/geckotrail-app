import 'package:equatable/equatable.dart';

enum TrailAccessState { notUnlocked, upcomingEvent, unlocked }

enum TrailDifficulty { easy, moderate, hard, expert }

class TrailSummary extends Equatable {
  const TrailSummary({
    required this.id,
    required this.name,
    required this.region,
    this.distanceKm,
    this.estimatedDurationMinutes,
    this.difficulty,
    this.terrain,
    this.elevationGainM,
    this.ecoSensitive = false,
    this.coverImageUrl,
    this.accessState = TrailAccessState.notUnlocked,
    this.hasUpcomingEvents = false,
    this.eligibilityLabel,
  });

  final String id;
  final String name;
  final String region;
  final double? distanceKm;
  final int? estimatedDurationMinutes;
  final TrailDifficulty? difficulty;
  final String? terrain;
  final double? elevationGainM;
  final bool ecoSensitive;
  final String? coverImageUrl;
  final TrailAccessState accessState;
  final bool hasUpcomingEvents;
  final String? eligibilityLabel;

  factory TrailSummary.fromJson(Map<String, dynamic> json) {
    return TrailSummary(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      region: json['region']?.toString() ??
          json['regionName']?.toString() ??
          '',
      distanceKm: _toDouble(json['distance'] ?? json['distanceKm']),
      estimatedDurationMinutes: _toInt(
        json['estimatedDuration'] ?? json['estimatedDurationMinutes'],
      ),
      difficulty: _parseDifficulty(json['difficulty']?.toString()),
      terrain: json['terrain']?.toString(),
      elevationGainM: _toDouble(json['elevationGain'] ?? json['elevationGainM']),
      ecoSensitive: json['ecoSensitive'] == true,
      coverImageUrl: json['coverImage']?.toString() ?? json['coverImageUrl']?.toString(),
      accessState: _parseAccess(json['accessState']?.toString()),
      hasUpcomingEvents: json['hasUpcomingEvents'] == true ||
          json['eventAvailability'] == true,
      eligibilityLabel: json['eligibilityLabel']?.toString() ??
          json['eligibility']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name, accessState];
}

class TrailDetails extends TrailSummary {
  const TrailDetails({
    required super.id,
    required super.name,
    required super.region,
    super.distanceKm,
    super.estimatedDurationMinutes,
    super.difficulty,
    super.terrain,
    super.elevationGainM,
    super.ecoSensitive,
    super.coverImageUrl,
    super.accessState,
    super.hasUpcomingEvents,
    super.eligibilityLabel,
    this.description,
    this.bestSeason,
    this.safetyInformation,
    this.environmentalInformation,
    this.photos = const [],
    this.familiarityLevel,
    this.verifiedCompletionCount,
  });

  final String? description;
  final String? bestSeason;
  final String? safetyInformation;
  final String? environmentalInformation;
  final List<String> photos;
  final String? familiarityLevel;
  final int? verifiedCompletionCount;

  factory TrailDetails.fromJson(Map<String, dynamic> json) {
    final summary = TrailSummary.fromJson(json);
    return TrailDetails(
      id: summary.id,
      name: summary.name,
      region: summary.region,
      distanceKm: summary.distanceKm,
      estimatedDurationMinutes: summary.estimatedDurationMinutes,
      difficulty: summary.difficulty,
      terrain: summary.terrain,
      elevationGainM: summary.elevationGainM,
      ecoSensitive: summary.ecoSensitive,
      coverImageUrl: summary.coverImageUrl,
      accessState: summary.accessState,
      hasUpcomingEvents: summary.hasUpcomingEvents,
      eligibilityLabel: summary.eligibilityLabel,
      description: json['description']?.toString(),
      bestSeason: json['bestSeason']?.toString(),
      safetyInformation: json['safetyInformation']?.toString(),
      environmentalInformation: json['environmentalInformation']?.toString(),
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      familiarityLevel: json['familiarityLevel']?.toString() ??
          (json['familiarity'] is Map
              ? (json['familiarity'] as Map)['level']?.toString()
              : null),
      verifiedCompletionCount: _toInt(
        json['verifiedCompletionCount'] ??
            (json['familiarity'] is Map
                ? (json['familiarity'] as Map)['verifiedCompletionCount']
                : null),
      ),
    );
  }
}

TrailAccessState _parseAccess(String? value) {
  switch (value?.toUpperCase()) {
    case 'UNLOCKED':
      return TrailAccessState.unlocked;
    case 'UPCOMING_EVENT':
      return TrailAccessState.upcomingEvent;
    default:
      return TrailAccessState.notUnlocked;
  }
}

TrailDifficulty? _parseDifficulty(String? value) {
  switch (value?.toUpperCase()) {
    case 'EASY':
      return TrailDifficulty.easy;
    case 'MODERATE':
      return TrailDifficulty.moderate;
    case 'HARD':
      return TrailDifficulty.hard;
    case 'EXPERT':
      return TrailDifficulty.expert;
    default:
      return null;
  }
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
