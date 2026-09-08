import 'package:equatable/equatable.dart';

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

  bool get isHost => hostApproved || roles.contains(UserRole.host);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final roleStrings = (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? ['rider'];
    return UserProfile(
      id: json['id'].toString(),
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? json['displayName']?.toString() ?? '',
      bio: json['bio']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? json['avatarUrl']?.toString(),
      ridingExperience: json['ridingExperience']?.toString(),
      bikeInfo: json['bikeInfo']?.toString(),
      roles: roleStrings.map(_parseRole).toList(),
      hostApproved: json['hostApproved'] == true ||
          json['hostStatus']?.toString().toUpperCase() == 'APPROVED',
    );
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
  List<Object?> get props => [id, email, name, roles, hostApproved];
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? json['access_token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? json['refresh_token']?.toString() ?? '',
    );
  }
}

class AuthSession {
  const AuthSession({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserProfile user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? json;
    return AuthSession(
      tokens: AuthTokens.fromJson(json),
      user: UserProfile.fromJson(userJson),
    );
  }
}
