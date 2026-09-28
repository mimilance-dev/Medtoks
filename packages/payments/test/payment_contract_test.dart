import 'package:medtoks_payments/medtoks_payments.dart';
import 'package:test/test.dart';

void main() {
  test('exposes payment status values without processing payments', () {
    expect(PaymentStatus.values, contains(PaymentStatus.pending));
  });
}
