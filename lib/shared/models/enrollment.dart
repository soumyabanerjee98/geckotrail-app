import 'package:equatable/equatable.dart';

enum EnrollmentStatus {
  pendingPayment,
  confirmed,
  cancelled,
  refunded,
  attended,
  noShow,
}

enum PaymentStatus { initiated, pending, success, failed, refunded }

enum AttendanceUiState {
  notStarted,
  waitingForLocation,
  outsideRadius,
  withinRadius,
  verifying,
  verified,
  rejected,
  flagged,
  windowClosed,
  windowNotOpen,
}

class Enrollment extends Equatable {
  const Enrollment({
    required this.id,
    required this.eventId,
    required this.riderId,
    this.paymentId,
    this.status = EnrollmentStatus.pendingPayment,
  });

  final String id;
  final String eventId;
  final String riderId;
  final String? paymentId;
  final EnrollmentStatus status;

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    final nestedEvent = json['event'];
    final eventId = json['eventId']?.toString() ??
        (nestedEvent is Map ? nestedEvent['id']?.toString() : null);
    return Enrollment(
      id: json['id'].toString(),
      eventId: eventId ?? '',
      riderId: (json['riderId'] ?? json['userId'])?.toString() ?? '',
      paymentId: json['paymentId']?.toString(),
      status: _parseEnrollment(json['status']?.toString()),
    );
  }

  @override
  List<Object?> get props => [id, status];
}

class PaymentOrder extends Equatable {
  const PaymentOrder({
    required this.id,
    required this.amount,
    required this.currency,
    this.providerOrderId,
    this.provider = 'razorpay',
    this.status = PaymentStatus.initiated,
    this.eventId,
  });

  final String id;
  final double amount;
  final String currency;
  final String? providerOrderId;
  final String provider;
  final PaymentStatus status;
  final String? eventId;

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      id: json['id'].toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      providerOrderId: json['providerOrderId']?.toString(),
      provider: json['provider']?.toString() ?? 'razorpay',
      status: _parsePayment(json['status']?.toString()),
      eventId: json['eventId']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, status];
}

class AttendanceResult extends Equatable {
  const AttendanceResult({
    required this.verificationStatus,
    this.message,
    this.verifiedDistanceMeters,
    this.uiState = AttendanceUiState.verifying,
  });

  final String verificationStatus;
  final String? message;
  final double? verifiedDistanceMeters;
  final AttendanceUiState uiState;

  factory AttendanceResult.fromJson(Map<String, dynamic> json) {
    final status = json['verificationStatus']?.toString().toUpperCase() ?? '';
    return AttendanceResult(
      verificationStatus: status,
      message: json['message']?.toString(),
      verifiedDistanceMeters: (json['verifiedDistanceMeters'] as num?)?.toDouble(),
      uiState: _mapAttendanceUi(status, json['code']?.toString()),
    );
  }

  @override
  List<Object?> get props => [verificationStatus, uiState];
}

EnrollmentStatus _parseEnrollment(String? value) {
  switch (value?.toUpperCase()) {
    case 'CONFIRMED':
      return EnrollmentStatus.confirmed;
    case 'CANCELLED':
      return EnrollmentStatus.cancelled;
    case 'REFUNDED':
      return EnrollmentStatus.refunded;
    case 'ATTENDED':
      return EnrollmentStatus.attended;
    case 'NO_SHOW':
      return EnrollmentStatus.noShow;
    case 'PENDING_PAYMENT':
    case 'PENDING':
      return EnrollmentStatus.pendingPayment;
    default:
      return EnrollmentStatus.pendingPayment;
  }
}

PaymentStatus _parsePayment(String? value) {
  switch (value?.toUpperCase()) {
    case 'PENDING':
      return PaymentStatus.pending;
    case 'SUCCESS':
      return PaymentStatus.success;
    case 'FAILED':
      return PaymentStatus.failed;
    case 'REFUNDED':
      return PaymentStatus.refunded;
    case 'INITIATED':
      return PaymentStatus.initiated;
    default:
      return PaymentStatus.initiated;
  }
}

AttendanceUiState _mapAttendanceUi(String status, String? code) {
  switch (code?.toUpperCase()) {
    case 'OUTSIDE_RADIUS':
      return AttendanceUiState.outsideRadius;
    case 'WINDOW_CLOSED':
      return AttendanceUiState.windowClosed;
    case 'WINDOW_NOT_OPEN':
      return AttendanceUiState.windowNotOpen;
  }
  switch (status) {
    case 'VERIFIED':
      return AttendanceUiState.verified;
    case 'REJECTED':
      return AttendanceUiState.rejected;
    case 'FLAGGED':
      return AttendanceUiState.flagged;
    default:
      return AttendanceUiState.verifying;
  }
}
