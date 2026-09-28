import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtoks_mentor/app.dart';

void main() {
  testWidgets('starts the independent mentor app', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MentorApp()));
    await tester.pumpAndSettle();
    expect(find.text('Mentor app is ready (development)'), findsOneWidget);
  });
}
