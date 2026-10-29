// lib/services/auth_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Where Supabase sends the user back after an emailed link or Google
  /// consent. On mobile this deep-links into the app (scheme registered in
  /// Info.plist / AndroidManifest); without it Supabase falls back to the
  /// project's Site URL (localhost). Must be in the project's Redirect URLs.
  static const mobileRedirectUrl = 'nextshow://login-callback';
  static String? get _redirectUrl => kIsWeb ? null : mobileRedirectUrl;

  static User? get currentUser {
    try {
      return _client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  static bool get isSignedIn => currentUser != null;
  static Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  /// Emails a one-time code to [email], creating the account if it's new —
  /// sign-in and sign-up are the same call. Throws [AuthException] on failure.
  /// The Supabase "Magic Link" and "Confirm signup" email templates must
  /// include `{{ .Token }}` for the code to appear in the email.
  static Future<void> sendOtp(String email) {
    return _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
      emailRedirectTo: _redirectUrl,
    );
  }

  /// Verifies the [code] sent to [email]. Throws [AuthException] on failure.
  static Future<void> verifyOtp({required String email, required String code}) {
    return _client.auth
        .verifyOTP(email: email, token: code, type: OtpType.email);
  }

  static Future<void> signOut() {
    return _client.auth.signOut();
  }

  /// Basic email shape check — not exhaustive RFC 5322 validation, just
  /// enough to catch obvious typos before hitting the network.
  static bool isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  /// Opens Google's consent screen. On mobile it runs in the system browser:
  /// the in-app Safari sheet doesn't reliably hand the `nextshow://` redirect
  /// back and never closes itself. The returning deep link is exchanged for a
  /// session by supabase_flutter. Throws [AuthException] on failure to even
  /// start the redirect.
  static Future<void> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.origin : mobileRedirectUrl,
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      // Always show Google's account chooser. Without it Google silently
      // reuses whichever account the browser is signed into, which can sign
      // the user in as a different email than the one they meant.
      queryParams: const {'prompt': 'select_account'},
    );
  }
}
