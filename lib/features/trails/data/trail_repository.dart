import 'package:dio/dio.dart';

import '../../../core/networking/api_client.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/models/event.dart';

class TrailRepository {
  TrailRepository(this._api);

  final ApiClient _api;

  Future<List<TrailSummary>> listTrails({
    String? region,
    String? query,
    bool? ecoSensitive,
  }) {
    return _api.get(
      '/trails',
      query: {
        'region': ?region,
        if (query != null && query.isNotEmpty) 'q': query,
        if (ecoSensitive == true) 'ecoSensitive': true,
      },
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => TrailSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<TrailDetails> getTrail(String trailId) {
    return _api.get(
      '/trails/$trailId',
      parser: (data) => TrailDetails.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<HostedEvent>> trailEvents(String trailId) {
    return _api.get(
      '/events',
      query: {'trailId': trailId},
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => HostedEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<TrailSummary>> featured() {
    return _api.get(
      '/trails',
      query: const {'featured': true},
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => TrailSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<TrailDetails> createTrail(Map<String, dynamic> payload) {
    return _api.post(
      '/trails',
      data: payload,
      parser: (data) => TrailDetails.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<TrailDetails> updateTrail(String trailId, Map<String, dynamic> payload) {
    return _api.patch(
      '/trails/$trailId',
      data: payload,
      parser: (data) => TrailDetails.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> uploadGpx({
    required String trailId,
    required String filePath,
    required String fileName,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    await _api.postMultipart(
      '/trails/$trailId/gpx',
      data: form,
      parser: (_) => true,
    );
  }
}
