import '../../../core/networking/api_client.dart';
import '../../../shared/models/region.dart';

class RegionRepository {
  RegionRepository(this._api);

  final ApiClient _api;

  Future<List<Region>> listRegions() {
    return _api.get(
      '/regions',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => Region.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<Region> getRegion(String regionId) {
    return _api.get(
      '/regions/$regionId',
      parser: (data) => Region.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Region> createRegion(Map<String, dynamic> payload) {
    return _api.post(
      '/regions',
      data: payload,
      parser: (data) => Region.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Region> updateRegion(String regionId, Map<String, dynamic> payload) {
    return _api.patch(
      '/regions/$regionId',
      data: payload,
      parser: (data) => Region.fromJson(data as Map<String, dynamic>),
    );
  }
}
