enum SubscriptionStatus { pending, active, paused, expired, cancelled }

class Subscription {
  const Subscription({
    required this.id,
    required this.status,
    required this.startsAt,
    this.endsAt,
  });

  final String id;
  final SubscriptionStatus status;
  final DateTime startsAt;
  final DateTime? endsAt;
}
