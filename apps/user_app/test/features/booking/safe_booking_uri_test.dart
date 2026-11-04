import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/booking/presentation/booking_web_view_screen.dart';

void main() {
  test('accepts https URLs with a host', () {
    expect(safeBookingUri('https://tickets.example.com/book?id=1')?.host, 'tickets.example.com');
    expect(safeBookingUri('  https://example.com  '), isNotNull);
  });

  test('refuses every other scheme and malformed input', () {
    for (final bad in [
      'http://example.com',
      'javascript:alert(1)',
      'data:text/html,<script>1</script>',
      'file:///etc/passwd',
      'intent://scan/#Intent;scheme=zxing;end',
      'nextshow://login-callback',
      'https://',
      'example.com/book',
      '',
      'https://exa mple.com:bad',
    ]) {
      expect(safeBookingUri(bad), isNull, reason: bad);
    }
  });
}
