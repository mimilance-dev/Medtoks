import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtoks_design_system/medtoks_design_system.dart';

void main() {
  testWidgets('showcase renders accessible controls and switches appearance', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    await tester.pumpWidget(
      CupertinoApp(
        theme: AppTheme.cupertinoSystem,
        home: DesignSystemShowcaseScreen(),
      ),
    );

    expect(find.text('MedToks foundations'), findsOneWidget);
    expect(find.text('Primary action'), findsOneWidget);
    expect(find.text('Secondary action'), findsOneWidget);
    expect(find.bySemanticsLabel('Email address'), findsOneWidget);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    expect(find.byType(DesignSystemShowcaseScreen), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('subscription card preserves its action and semantic label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var pressed = false;
    await tester.pumpWidget(
      CupertinoApp(
        theme: AppTheme.cupertinoLight,
        home: CupertinoPageScaffold(
          child: Center(
            child: AppSubscriptionCard(
              title: 'Focused preparation',
              price: '₹1,499',
              interval: '/ month',
              features: const ['Study resources', 'Mentor messaging'],
              actionLabel: 'Choose plan',
              onPressed: () => pressed = true,
              semanticLabel: 'Focused preparation subscription option',
            ),
          ),
        ),
      ),
    );

    final cardSemantics = tester.getSemantics(find.byType(AppSubscriptionCard));
    expect(
      cardSemantics.label,
      startsWith('Focused preparation subscription option'),
    );
    await tester.tap(find.text('Choose plan'));
    expect(pressed, isTrue);
    semantics.dispose();
  });

  testWidgets('showcase remains usable at narrow width and large text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    await tester.pumpWidget(
      CupertinoApp(
        theme: AppTheme.cupertinoSystem,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.8)),
            child: const DesignSystemShowcaseScreen(),
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Focused preparation'),
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });
}
