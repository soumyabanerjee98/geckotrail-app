class AppException implements Exception {
  const AppException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please sign in again.'])
      : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'You do not have permission for this action.'])
      : super(statusCode: 403);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network unavailable. Check your connection.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on the server.'])
      : super(statusCode: 500);
}
