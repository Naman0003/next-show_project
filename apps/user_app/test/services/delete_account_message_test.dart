import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/services/auth_service.dart';

void main() {
  test('owning venues gets a specific message', () {
    final msg = AuthService.deleteAccountErrorMessage(
        FunctionException(status: 409, details: {'error': 'owns_venues'}));
    expect(msg, contains('owns venues'));
  });

  test('every other failure gets the generic retry message', () {
    for (final e in [
      FunctionException(status: 500),
      FunctionException(status: 401),
      Exception('socket closed'),
    ]) {
      expect(AuthService.deleteAccountErrorMessage(e), contains('try again'));
    }
  });

  test('reads the deletion date from the function response', () {
    final d = AuthService.scheduledForFromResponse(
        {'scheduled_for': '2026-11-19T09:00:00+00:00'});
    expect(d.toUtc(), DateTime.utc(2026, 11, 19, 9));
  });

  test('a response without a date is an error, not a silent success', () {
    for (final bad in [null, <String, dynamic>{}, {'scheduled_for': 5}, 'ok']) {
      expect(() => AuthService.scheduledForFromResponse(bad),
          throwsFormatException);
    }
  });
}
