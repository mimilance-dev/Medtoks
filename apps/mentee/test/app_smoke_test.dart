import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtoks_mentee/app.dart';

void main() {
  testWidgets('starts the independent mentee app', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MenteeApp()));
    await tester.pumpAndSettle();
    expect(find.text('Mentee app is ready (development)'), findsOneWidget);
    await tester.tap(find.text('Open design system'));
    await tester.pumpAndSettle();
    expect(find.text('MedToks foundations'), findsOneWidget);
  });
}
