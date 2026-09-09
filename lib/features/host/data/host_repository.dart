import '../../../core/networking/api_client.dart';
import '../../../shared/models/host.dart';
import '../../../shared/models/user.dart';

class HostRepository {
  HostRepository(this._api);

  final ApiClient _api;

  Future<HostProfile> apply(Map<String, dynamic> payload) {
    return _api.post(
      '/hosts/apply',
      data: payload,
      parser: (data) => HostProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<HostProfile?> me() async {
    try {
      return await _api.get(
        '/hosts/me',
        parser: (data) {
          if (data == null) return null;
          return HostProfile.fromJson(data as Map<String, dynamic>);
        },
      );
    } catch (_) {
      return null;
    }
  }

  Future<HostProfile> updateMe(Map<String, dynamic> payload) {
    return _api.patch(
      '/hosts/me',
      data: payload,
      parser: (data) => HostProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<HostProfile> getByUserId(String userId) {
    return _api.get(
      '/hosts/$userId',
      parser: (data) => HostProfile.fromJson(data as Map<String, dynamic>),
    );
  }
}

class AdminRepository {
  AdminRepository(this._api);

  final ApiClient _api;

  Future<List<UserProfile>> listUsers({String? hostStatus}) {
    return _api.get(
      '/admin/users',
      query: {
        'hostStatus': ?hostStatus,
      },
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<HostProfile>> listHostApplications({String? status}) async {
    final users = await listUsers(hostStatus: status);
    final wanted = status == null
        ? null
        : parseHostApplicationStatus(status);
    return users
        .where((u) {
          if (wanted == null) {
            return u.hostStatus != HostApplicationStatus.none;
          }
          return u.hostStatus == wanted;
        })
        .map(
          (u) => HostProfile(
            userId: u.id,
            status: u.hostStatus,
            displayName: u.name,
            photoUrl: u.photoUrl,
            experienceYears: int.tryParse(
              RegExp(r'\d+').firstMatch(u.ridingExperience ?? '')?.group(0) ?? '',
            ),
            motivation: u.bio,
            bikeInfo: u.bikeInfo,
            regions: u.hostRegions,
          ),
        )
        .toList();
  }

  Future<void> approveHost(String userId) async {
    await _api.post(
      '/admin/hosts/$userId/approve',
      parser: (_) => true,
    );
  }

  /// No dedicated reject route — patch admin user host status.
  Future<void> rejectHost(String userId) async {
    await _api.patch(
      '/admin/users/$userId',
      data: {'hostStatus': 'REJECTED'},
      parser: (_) => true,
    );
  }

  Future<List<Map<String, dynamic>>> listPayments() {
    return _api.get(
      '/admin/payments',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      },
    );
  }
}
