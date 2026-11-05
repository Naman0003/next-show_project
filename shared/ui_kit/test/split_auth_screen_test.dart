import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Future<void> _pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const MaterialApp(home: SplitAuthScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts on the email step with no password field',
      (tester) async {
    await _pumpScreen(tester);

    expect(find.text('Continue with email'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'SEND CODE'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Password'), findsNothing);
  });

  testWidgets('rejects an invalid email before sending a code', (tester) async {
    await _pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'not-an-email');
    await tester.tap(find.widgetWithText(ElevatedButton, 'SEND CODE'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Check your email'), findsNothing);
  });

  testWidgets('field stays visible above the keyboard', (tester) async {
    await _pumpScreen(tester);

    // Simulate the iOS keyboard (336 logical px on a 390x844 phone).
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    final field = tester.getRect(find.byType(TextField));
    expect(field.bottom, lessThanOrEqualTo(844 - 336));
    // Not hidden under the brand banner: the field itself receives taps.
    WidgetController.hitTestWarningShouldBeFatal = true;
    addTearDown(() => WidgetController.hitTestWarningShouldBeFatal = false);
    await tester.tap(find.byType(TextField));
    expect(tester.takeException(), isNull);
  });

  testWidgets('organizer/admin options: own title, no Google, no close button', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      home: SplitAuthScreen(title: 'Next Show Admin', showGoogle: false, showClose: false),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Next Show Admin'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });
}
