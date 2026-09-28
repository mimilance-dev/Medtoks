import 'payment_result.dart';

abstract interface class PaymentProvider {
  Future<PaymentResult> requestPayment({
    required String orderReference,
    required int amountMinorUnits,
    required String currencyCode,
  });
}
