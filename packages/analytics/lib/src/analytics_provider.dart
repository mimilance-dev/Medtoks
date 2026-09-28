import 'analytics_event.dart';

abstract interface class AnalyticsProvider {
  Future<void> record(AnalyticsEvent event);
}
