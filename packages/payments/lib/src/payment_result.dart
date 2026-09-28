enum PaymentStatus { pending, authorized, failed, cancelled }

class PaymentResult {
  const PaymentResult({required this.reference, required this.status});

  final String reference;
  final PaymentStatus status;
}
