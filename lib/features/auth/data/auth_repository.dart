import '../../../core/networking/api_client.dart';
import '../../../shared/models/user.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    return _api.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      parser: (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _api.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
      parser: (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _api.post(
      '/auth/forgot-password',
      data: {'email': email},
      parser: (_) => true,
    );
  }

  Future<UserProfile> me() {
    return _api.get(
      '/users/me',
      parser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
    );
  }
}
