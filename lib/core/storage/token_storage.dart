import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists JWTs in secure storage and keeps an in-memory copy for the
/// active process so session restore / API calls do not re-hit disk every time.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;
  bool _hydrated = false;

  bool get isHydrated => _hydrated;

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  Future<void> hydrate() async {
    if (_hydrated) return;
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
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
    _hydrated = true;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<bool> hasSession() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
