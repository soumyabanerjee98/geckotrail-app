import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});

typedef OnSessionExpired = void Function();

class ApiClient {
  ApiClient({
    required this._tokenStorage,
    this._onSessionExpired,
  }) {    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPrefix}',
        connectTimeout: AppConfig.httpTimeout,
        receiveTimeout: AppConfig.httpTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;
  OnSessionExpired? _onSessionExpired;
  bool _refreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  void setSessionExpiredHandler(OnSessionExpired handler) {
    _onSessionExpired = handler;
  }

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
        ),
      );
      return;
    }

    final status = err.response?.statusCode;
    if (status == 401 && !_isAuthPath(err.requestOptions.path)) {
      try {
        await _refreshToken();
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        await _tokenStorage.clear();
        _onSessionExpired?.call();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
            response: err.response,
            type: err.type,
          ),
        );
        return;
      }
    }

    handler.next(err);
  }

  bool _isAuthPath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout') ||
        path.contains('/auth/forgot-password');
  }

  /// Backend liveness probe lives outside `/api/v1`.
  Future<bool> health() async {
    try {
      final response = await Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.httpTimeout,
          receiveTimeout: AppConfig.httpTimeout,
        ),
      ).get<dynamic>('/health');
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> _refreshToken() async {
    if (_refreshing) {
      final waiter = Completer<void>();
      _refreshWaiters.add(waiter);
      return waiter.future;
    }
    _refreshing = true;
    try {
      final refresh = await _tokenStorage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        throw const UnauthorizedException();
      }
      final response = await Dio(
        BaseOptions(baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPrefix}'),
      ).post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = response.data ?? {};
      final access = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String? ?? refresh;
      if (access == null || access.isEmpty) {
        throw const UnauthorizedException();
      }
      await _tokenStorage.saveTokens(
        accessToken: access,
        refreshToken: newRefresh,
      );
      for (final w in _refreshWaiters) {
        w.complete();
      }
      _refreshWaiters.clear();
    } catch (e) {
      for (final w in _refreshWaiters) {
        w.completeError(e);
      }
      _refreshWaiters.clear();
      rethrow;
    } finally {
      _refreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _tokenStorage.readAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return parser(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return parser(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.put<dynamic>(path, data: data);
      return parser(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: data);
      return parser(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path, {Object? data}) async {
    try {
      await _dio.delete<dynamic>(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String message = 'Request failed';
    if (body is Map && body['message'] != null) {
      message = body['message'].toString();
    } else if (body is Map && body['error'] != null) {
      message = body['error'].toString();
    }
    if (status == 401) return UnauthorizedException(message);
    if (status == 403) return ForbiddenException(message);
    if (status != null && status >= 500) return ServerException(message);
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }
    return AppException(message, statusCode: status);
  }
}
