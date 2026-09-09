import 'package:equatable/equatable.dart';

class Region extends Equatable {
  const Region({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.stateOrTerritory,
    this.bestSeason,
    this.safetyNotes,
    this.terrainTypes = const [],
    this.coverImageUrl,
  });

  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? stateOrTerritory;
  final String? bestSeason;
  final String? safetyNotes;
  final List<String> terrainTypes;
  final String? coverImageUrl;

  factory Region.fromJson(Map<String, dynamic> json) {
    final terrain = json['terrainTypes'] ?? json['terrain'];
    return Region(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      description: json['description']?.toString(),
      stateOrTerritory:
          json['stateOrTerritory']?.toString() ?? json['state']?.toString(),
      bestSeason: json['bestSeason']?.toString(),
      safetyNotes: json['safetyNotes']?.toString() ??
          json['safetyAndEcoNotes']?.toString(),
      terrainTypes: terrain is List
          ? terrain.map((e) => e.toString()).toList()
          : const [],
      coverImageUrl: json['coverImageUrl']?.toString() ?? json['coverImage']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name];
}
