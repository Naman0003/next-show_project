import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/auth/presentation/widgets/auth_mode_toggle.dart';

Widget _host({
  required AuthMode mode,
  required ValueChanged<AuthMode> onChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: AuthModeToggle(mode: mode, onChanged: onChanged),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('starts on the given mode and reports the other on tap',
      (tester) async {
    AuthMode? picked;
    await tester.pumpWidget(
      _host(mode: AuthMode.signIn, onChanged: (m) => picked = m),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SIGN UP'));
    await tester.pumpAndSettle();
    expect(picked, AuthMode.signUp);
  });

  testWidgets('tapping the active segment still reports it', (tester) async {
    AuthMode? picked;
    await tester.pumpWidget(
      _host(mode: AuthMode.signUp, onChanged: (m) => picked = m),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();
    expect(picked, AuthMode.signIn);
  });
}
