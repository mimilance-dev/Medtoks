class AnalyticsEvent {
  const AnalyticsEvent({required this.name, this.attributes = const {}});

  final String name;
  final Map<String, Object?> attributes;
}
