import 'package:medtoks_analytics/medtoks_analytics.dart';
import 'package:test/test.dart';

void main() {
  test('exports analytics event contract without collecting events', () {
    const event = AnalyticsEvent(name: 'scaffold_smoke');
    expect(event.attributes, isEmpty);
  });
}
