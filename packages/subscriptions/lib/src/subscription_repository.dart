import 'subscription.dart';

abstract interface class SubscriptionRepository {
  Future<Subscription?> findById(String id);
}
