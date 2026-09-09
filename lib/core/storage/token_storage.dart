import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/models/user.dart';

/// Persists JWTs + a cached [UserProfile] so hard restarts can restore the
/// session without waiting solely on in-memory auth state.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'cached_user_profile';

  String? _accessToken;
  String? _refreshToken;
  UserProfile? _cachedUser;
  bool _hydrated = false;

  bool get isHydrated => _hydrated;

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  UserProfile? get cachedUser => _cachedUser;

  Future<void> hydrate() async {
    if (_hydrated) return;
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
    final userRaw = await _storage.read(key: _userKey);
    if (userRaw != null && userRaw.isNotEmpty) {
      try {
        final map = jsonDecode(userRaw) as Map<String, dynamic>;
        _cachedUser = UserProfile.fromJson(map);
      } catch (_) {
        _cachedUser = null;
      }
    }
    _hydrated = true;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _hydrated = true;
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> saveUser(UserProfile user) async {
    _cachedUser = user;
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserProfile user,
  }) async {
    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await saveUser(user);
  }

  Future<String?> readAccessToken() async {
    if (!_hydrated) await hydrate();
    return _accessToken;
  }

  Future<String?> readRefreshToken() async {
    if (!_hydrated) await hydrate();
    return _refreshToken;
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _cachedUser = null;
    _hydrated = true;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }

  Future<bool> hasSession() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
