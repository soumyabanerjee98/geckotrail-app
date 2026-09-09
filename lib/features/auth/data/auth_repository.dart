import 'package:dio/dio.dart';

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

  Future<void> logout() async {
    await _api.post(
      '/auth/logout',
      parser: (_) => true,
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

  Future<UserProfile> updateMe(Map<String, dynamic> payload) {
    return _api.patch(
      '/users/me',
      data: payload,
      parser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Multipart profile photo. Prefer `POST /users/me/photo`; field names `photo`/`file`.
  Future<UserProfile> uploadPhoto({
    required String filePath,
    required String fileName,
  }) async {
    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    return _api.postMultipart(
      '/users/me/photo',
      data: form,
      parser: (data) => UserProfile.fromJson(
        data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map),
      ),
    );
  }
}
