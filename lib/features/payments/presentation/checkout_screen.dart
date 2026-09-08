import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/models/enrollment.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';
import '../../events/presentation/event_details_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Razorpay? _razorpay;
  bool _busy = false;
  String? _statusMessage;
  PaymentStatus? _paymentStatus;
  String? _paymentId;
  String? _providerOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  void _onSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _busy = true;
      _statusMessage = 'Verifying payment with Gecko Trail…';
    });
    try {
      final paymentId = _paymentId;
      if (paymentId == null) {
        throw Exception('Missing payment reference');
      }
      final verified = await ref.read(paymentRepositoryProvider).verify(
            paymentId: paymentId,
            providerOrderId: response.orderId ?? _providerOrderId ?? '',
            providerPaymentId: response.paymentId ?? '',
            providerSignature: response.signature,
          );
      setState(() {
        _paymentStatus = verified.status;
        _statusMessage = verified.status == PaymentStatus.success
            ? 'Payment confirmed. Enrolment will reflect backend state.'
            : 'Payment status: ${verified.status.name}. Refreshing…';
      });
      ref.invalidate(eventDetailsProvider(widget.eventId));
    } catch (e) {
      setState(() {
        _paymentStatus = PaymentStatus.pending;
        _statusMessage =
            'Payment received by provider. Waiting for backend verification. $e';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onError(PaymentFailureResponse response) {
    setState(() {
      _busy = false;
      _paymentStatus = PaymentStatus.failed;
      _statusMessage = response.message ?? 'Payment failed';
    });
  }

  Future<void> _startCheckout(HostedEvent event) async {
    setState(() {
      _busy = true;
      _statusMessage = null;
      _paymentStatus = null;
    });
    try {
      await ref.read(eventRepositoryProvider).enrol(widget.eventId);
      final order = await ref.read(paymentRepositoryProvider).createOrder(
            eventId: widget.eventId,
          );
      _paymentId = order.id;
      _providerOrderId = order.providerOrderId;
      setState(() => _paymentStatus = order.status);

      if (AppConfig.razorpayKeyId.isEmpty || order.providerOrderId == null) {
        setState(() {
          _statusMessage =
              'Payment order created (${order.id}). Configure RAZORPAY_KEY_ID to open the checkout UI, then verify via backend.';
          _busy = false;
        });
        return;
      }

      final user = ref.read(authControllerProvider).user;
      final options = {
        'key': AppConfig.razorpayKeyId,
        'amount': (order.amount * 100).round(),
        'currency': order.currency,
        'name': 'Gecko Trail',
        'description': event.title,
        'order_id': order.providerOrderId,
        'prefill': {
          'email': user?.email ?? '',
          'name': user?.name ?? '',
        },
      };
      _razorpay!.open(options);
      setState(() => _busy = false);
    } catch (e) {
      setState(() {
        _busy = false;
        _statusMessage = e.toString();
        _paymentStatus = PaymentStatus.failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: eventAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (event) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Amount charged by the server: ${event.currency} ${event.price?.toStringAsFixed(0) ?? '—'}',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Final price, payment success, enrolment, and route access are decided by the backend after verification.',
                ),
                const SizedBox(height: 24),
                if (_paymentStatus != null)
                  Text(
                    'Payment state: ${_paymentStatus!.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _paymentStatus == PaymentStatus.success
                          ? AppColors.success
                          : _paymentStatus == PaymentStatus.failed
                              ? AppColors.danger
                              : AppColors.forest,
                    ),
                  ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_statusMessage!),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: _busy ? null : () => _startCheckout(event),
                  child: Text(_busy ? 'Working…' : 'Pay & enrol'),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
