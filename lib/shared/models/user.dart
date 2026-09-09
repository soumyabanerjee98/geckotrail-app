import 'package:equatable/equatable.dart';

import 'host.dart';

enum UserRole { rider, host, admin }

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.bio,
    this.photoUrl,
    this.ridingExperience,
    this.bikeInfo,
    this.roles = const [UserRole.rider],
    this.hostApproved = false,
    this.hostStatus = HostApplicationStatus.none,
    this.hostRegions = const [],
    this.unlockedRoutesCount,
    this.verifiedRouteCompletions,
    this.hostedRidesCount,
  });

  final String id;
  final String email;
  final String name;
  final String? bio;
  final String? photoUrl;
  final String? ridingExperience;
  final String? bikeInfo;
  final List<UserRole> roles;
  final bool hostApproved;
  final HostApplicationStatus hostStatus;
  final List<String> hostRegions;
  final int? unlockedRoutesCount;
  final int? verifiedRouteCompletions;
  final int? hostedRidesCount;

  bool get isHost =>
      hostApproved ||
      hostStatus == HostApplicationStatus.approved ||
      roles.contains(UserRole.host);

  bool get isAdmin => roles.contains(UserRole.admin);

  bool get hasPendingHostApplication =>
      hostStatus == HostApplicationStatus.pending;

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    final user = json['user'];
    if (user is Map<String, dynamic> && json['id'] == null) return user;
    if (user is Map && json['id'] == null) {
      return Map<String, dynamic>.from(user);
    }
    return json;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final root = _unwrap(json);
    final roleStrings =
        (root['roles'] as List?)?.map((e) => e.toString()).toList() ?? ['rider'];
    final hostStatusRaw =
        root['hostStatus']?.toString() ?? root['hostApplicationStatus']?.toString();
    final regionsRaw = root['hostRegions'] ?? root['regionsOfExpertise'];
    return UserProfile(
      id: (root['id'] ?? root['userId'] ?? '').toString(),
      email: root['email']?.toString() ?? '',
      name: root['name']?.toString() ?? root['displayName']?.toString() ?? '',
      bio: root['bio']?.toString(),
      photoUrl: root['photoUrl']?.toString() ?? root['avatarUrl']?.toString(),
      ridingExperience: root['ridingExperience']?.toString(),
      bikeInfo: root['bikeInfo']?.toString(),
      roles: roleStrings.map(_parseRole).toList(),
      hostApproved: root['hostApproved'] == true ||
          hostStatusRaw?.toUpperCase() == 'APPROVED',
      hostStatus: parseHostApplicationStatus(hostStatusRaw),
      hostRegions: regionsRaw is List
          ? regionsRaw.map((e) => e.toString()).toList()
          : const [],
      unlockedRoutesCount: (root['unlockedRoutesCount'] as num?)?.toInt(),
      verifiedRouteCompletions:
          (root['verifiedRouteCompletions'] as num?)?.toInt(),
      hostedRidesCount: (root['hostedRidesCount'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'ridingExperience': ridingExperience,
      'bikeInfo': bikeInfo,
      'roles': roles.map((r) => r.name.toUpperCase()).toList(),
      'hostApproved': hostApproved,
      'hostStatus': hostStatus.name.toUpperCase(),
      'hostRegions': hostRegions,
      'unlockedRoutesCount': unlockedRoutesCount,
      'verifiedRouteCompletions': verifiedRouteCompletions,
      'hostedRidesCount': hostedRidesCount,
    };
  }

  static UserRole _parseRole(String value) {
    switch (value.toLowerCase()) {
      case 'host':
        return UserRole.host;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.rider;
    }
  }

  @override
  List<Object?> get props => [id, email, name, roles, hostApproved, hostStatus];
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return AuthTokens(
      accessToken:
          root['accessToken']?.toString() ?? root['access_token']?.toString() ?? '',
      refreshToken:
          root['refreshToken']?.toString() ?? root['refresh_token']?.toString() ?? '',
    );
  }
}

class AuthSession {
  const AuthSession({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserProfile user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final userJson = root['user'] is Map
        ? Map<String, dynamic>.from(root['user'] as Map)
        : root;
    return AuthSession(
      tokens: AuthTokens.fromJson(root),
      user: UserProfile.fromJson(userJson),
    );
  }
}
