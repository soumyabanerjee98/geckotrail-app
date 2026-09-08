import '../../../core/networking/api_client.dart';
import '../../../shared/models/enrollment.dart';

class PaymentRepository {
  PaymentRepository(this._api);

  final ApiClient _api;

  Future<PaymentOrder> createOrder({required String eventId}) {
    return _api.post(
      '/payments',
      data: {'eventId': eventId},
      parser: (data) => PaymentOrder.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<PaymentOrder> verify({
    required String paymentId,
    required String providerOrderId,
    required String providerPaymentId,
    String? providerSignature,
  }) {
    return _api.post(
      '/payments/$paymentId/verify',
      data: {
        'providerOrderId': providerOrderId,
        'providerPaymentId': providerPaymentId,
        'providerSignature': ?providerSignature,
      },
      parser: (data) => PaymentOrder.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<PaymentOrder> getPayment(String paymentId) {
    return _api.get(
      '/payments/$paymentId',
      parser: (data) => PaymentOrder.fromJson(data as Map<String, dynamic>),
    );
  }
}
