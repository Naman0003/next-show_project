import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/router/app_router.dart';

void main() {
  test('recognises the auth redirect in every shape the engine delivers', () {
    expect(isAuthCallback(Uri.parse('nextshow://login-callback?code=abc')),
        isTrue);
    expect(isAuthCallback(Uri.parse('/login-callback?code=abc')), isTrue);
    expect(isAuthCallback(Uri.parse('/?code=abc')), isTrue);
    expect(
        isAuthCallback(Uri.parse('/?error=access_denied&error_description=x')),
        isTrue);
  });

  test('leaves normal routes alone', () {
    for (final path in [
      '/',
      '/feed',
      '/discover',
      '/splash?from=/feed',
      '/event-detail'
    ]) {
      expect(isAuthCallback(Uri.parse(path)), isFalse, reason: path);
    }
  });
}
