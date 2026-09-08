import 'package:equatable/equatable.dart';

class Region extends Equatable {
  const Region({
    required this.id,
    required this.name,
    this.code,
    this.description,
  });

  final String id;
  final String name;
  final String? code;
  final String? description;

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      description: json['description']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name];
}
