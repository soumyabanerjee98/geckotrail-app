import '../../../core/networking/api_client.dart';
import '../../../shared/models/enrollment.dart';

class PaymentRepository {
  PaymentRepository(this._api);

  final ApiClient _api;

  Future<List<PaymentOrder>> listMine() {
    return _api.get(
      '/payments/me',
      parser: (data) {
        final list = data is List ? data : (data['items'] as List? ?? const []);
        return list
            .map((e) => PaymentOrder.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<PaymentOrder> createOrder({required String eventId}) {
    return _api.post(
      '/payments/orders',
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
      '/payments/verify',
      data: {
        'paymentId': paymentId,
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
