import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/models/user.dart';
import '../data/auth_repository.dart';
import '../../trails/data/trail_repository.dart';
import '../../events/data/event_repository.dart';
import '../../payments/data/payment_repository.dart';
import '../../regions/data/region_repository.dart';
import '../../routes/data/route_repository.dart';
import '../../host/data/host_repository.dart';
import '../../../core/location/location_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final trailRepositoryProvider = Provider<TrailRepository>((ref) {
  return TrailRepository(ref.watch(apiClientProvider));
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(apiClientProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

final regionRepositoryProvider = Provider<RegionRepository>((ref) {
  return RegionRepository(ref.watch(apiClientProvider));
});

final hostRepositoryProvider = Provider<HostRepository>((ref) {
  return HostRepository(ref.watch(apiClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(ref.watch(apiClientProvider));
});

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepository(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required this._authRepository,
    required this._tokenStorage,
    required this._apiClient,
  }) : super(const AuthState(status: AuthStatus.unknown)) {
    _apiClient.setSessionExpiredHandler(() {
      state = const AuthState(status: AuthStatus.unauthenticated);
    });
    restoreSession();
  }

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  final ApiClient _apiClient;

  Future<void> restoreSession() async {
    state = const AuthState(status: AuthStatus.unknown);
    try {
      await _tokenStorage.hydrate();
      final hasSession = await _tokenStorage.hasSession();
      if (!hasSession) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // Restore cached profile immediately so Profile/UI survive hard restarts
      // while /users/me refreshes in the background.
      final cached = _tokenStorage.cachedUser;
      if (cached != null) {
        state = AuthState(status: AuthStatus.authenticated, user: cached);
      }

      final user = await _authRepository.me();
      await _tokenStorage.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      // Keep cached authenticated user if tokens still look valid but /me failed
      // transiently; only clear when we have no cache to fall back on.
      final cached = _tokenStorage.cachedUser;
      if (cached != null && await _tokenStorage.hasSession()) {
        state = AuthState(status: AuthStatus.authenticated, user: cached);
        return;
      }
      await _tokenStorage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(clearError: true);
    try {
      final session = await _authRepository.login(email: email, password: password);
      var user = session.user;
      await _tokenStorage.saveTokens(
        accessToken: session.tokens.accessToken,
        refreshToken: session.tokens.refreshToken,
      );
      // Prefer full /users/me when login payload is token-only / partial.
      if (user.id.isEmpty || user.name.isEmpty) {
        user = await _authRepository.me();
      }
      await _tokenStorage.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        clearUser: true,
      );
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final session = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      var user = session.user;
      await _tokenStorage.saveTokens(
        accessToken: session.tokens.accessToken,
        refreshToken: session.tokens.refreshToken,
      );
      if (user.id.isEmpty || user.name.isEmpty) {
        user = await _authRepository.me();
      }
      await _tokenStorage.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        clearUser: true,
      );
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) {
    return _authRepository.forgotPassword(email: email);
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Clear local session even if the server logout call fails.
    }
    await _tokenStorage.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshUser() async {
    final user = await _authRepository.me();
    await _tokenStorage.saveUser(user);
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<UserProfile> updateProfile({
    required Map<String, dynamic> payload,
    String? photoPath,
    String? photoFileName,
  }) async {
    var user = state.user;
    if (photoPath != null && photoFileName != null) {
      user = await _authRepository.uploadPhoto(
        filePath: photoPath,
        fileName: photoFileName,
      );
      await _tokenStorage.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    }
    if (payload.isNotEmpty) {
      user = await _authRepository.updateMe(payload);
      await _tokenStorage.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else if (user != null) {
      user = await _authRepository.me();
      await _tokenStorage.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    }
    return user!;
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});
