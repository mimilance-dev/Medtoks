import 'package:medtoks_subscriptions/medtoks_subscriptions.dart';
import 'package:test/test.dart';

void main() {
  test('exposes subscription status values', () {
    expect(SubscriptionStatus.values, contains(SubscriptionStatus.active));
  });
}
