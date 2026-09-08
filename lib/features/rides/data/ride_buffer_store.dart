import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/ride.dart';

class GpsSample {
  GpsSample({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GpsSample.fromJson(Map<String, dynamic> json) {
    return GpsSample(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.parse(json['timestamp'].toString()),
    );
  }
}

class LocalRideBuffer {
  LocalRideBuffer({
    required this.localId,
    required this.trailId,
    this.remoteRideId,
    this.samples = const [],
    this.syncState = SyncState.recorded,
    this.distanceMeters = 0,
  });

  final String localId;
  String? remoteRideId;
  final String trailId;
  List<GpsSample> samples;
  SyncState syncState;
  double distanceMeters;

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'remoteRideId': remoteRideId,
        'trailId': trailId,
        'samples': samples.map((e) => e.toJson()).toList(),
        'syncState': syncState.name,
        'distanceMeters': distanceMeters,
      };

  factory LocalRideBuffer.fromJson(Map<String, dynamic> json) {
    return LocalRideBuffer(
      localId: json['localId'].toString(),
      trailId: json['trailId'].toString(),
      remoteRideId: json['remoteRideId']?.toString(),
      samples: (json['samples'] as List? ?? const [])
          .map((e) => GpsSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      syncState: SyncState.values.firstWhere(
        (e) => e.name == json['syncState'],
        orElse: () => SyncState.recorded,
      ),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RideBufferStore {
  final _uuid = const Uuid();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/ride_buffers.json');
  }

  Future<List<LocalRideBuffer>> loadAll() async {
    final file = await _file();
    if (!await file.exists()) return [];
    final raw = jsonDecode(await file.readAsString()) as List;
    return raw
        .map((e) => LocalRideBuffer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<LocalRideBuffer> buffers) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(buffers.map((e) => e.toJson()).toList()));
  }

  Future<LocalRideBuffer> create(String trailId) async {
    final buffer = LocalRideBuffer(localId: _uuid.v4(), trailId: trailId);
    final all = await loadAll();
    all.add(buffer);
    await saveAll(all);
    return buffer;
  }

  Future<void> upsert(LocalRideBuffer buffer) async {
    final all = await loadAll();
    final index = all.indexWhere((e) => e.localId == buffer.localId);
    if (index >= 0) {
      all[index] = buffer;
    } else {
      all.add(buffer);
    }
    await saveAll(all);
  }
}
