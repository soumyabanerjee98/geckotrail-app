import '../../../core/networking/api_client.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/models/event.dart';

class TrailRepository {
  TrailRepository(this._api);

  final ApiClient _api;

  Future<List<TrailSummary>> listTrails({String? region, String? query}) {
    return _api.get(
      '/trails',
      query: {
        'region': ?region,
        if (query != null && query.isNotEmpty) 'q': query,
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
      '/trails/$trailId/events',
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
}
