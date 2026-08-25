// lib/services/auth_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isSignedIn => currentUser != null;
  static Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sends a one-time code to [email]. Throws [AuthException] on failure.
  static Future<void> sendOtp(String email) {
    return _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  /// Verifies the [code] sent to [email]. Throws [AuthException] on failure.
  static Future<void> verifyOtp({required String email, required String code}) {
    return _client.auth.verifyOTP(email: email, token: code, type: OtpType.email);
  }

  static Future<void> signOut() {
    return _client.auth.signOut();
  }

  /// Basic email shape check — not exhaustive RFC 5322 validation, just
  /// enough to catch obvious typos before hitting the network.
  static bool isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  /// Redirects to Google's consent screen (web only for now). Throws
  /// [AuthException] on failure to even start the redirect.
  static Future<void> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.origin : null,
    );
  }
}
