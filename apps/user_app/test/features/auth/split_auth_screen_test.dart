import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/auth/presentation/split_auth_screen.dart';
import 'package:user_app/theme/app_theme.dart';

Widget _host({AuthMode mode = AuthMode.signIn}) {
  return MediaQuery(
    // disableAnimations -> the switch takes the instant path, no spring/timers.
    data: const MediaQueryData(
      size: Size(390, 844),
      disableAnimations: true,
    ),
    child: MaterialApp(
      theme: AppTheme.light,
      home: SplitAuthScreen(initialMode: mode),
    ),
  );
}

void main() {
  testWidgets('renders the sign-in side and its invitation to sign up',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('New here?'), findsOneWidget);
    expect(find.text('One of us?'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'SIGN UP'), findsOneWidget);
  });

  testWidgets('the panel ghost button switches to the sign-up side',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'SIGN UP'));
    await tester.pumpAndSettle();

    expect(find.text('One of us?'), findsOneWidget);
    expect(find.text('New here?'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'SIGN IN'), findsOneWidget);
  });

  testWidgets('starts on the sign-up side when asked', (tester) async {
    await tester.pumpWidget(_host(mode: AuthMode.signUp));
    await tester.pumpAndSettle();

    expect(find.text('One of us?'), findsOneWidget);
  });
}
