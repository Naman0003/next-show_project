// lib/services/auth_service.dart
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Account deletion and restore. Sign-in itself lives in the shared
/// [NextShowSupabaseClient] (email code, Google, sign-out), used by every app.
class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Asks to delete the signed-in user's account through the `delete-account`
  /// edge function. The account is deactivated and permanently deleted after a
  /// 14-day grace period; signing in again before then offers to restore it
  /// ([pendingDeletion] / [restoreAccount]). Returns the deletion date, and
  /// drops the local session. Throws [FunctionException] if the server refuses
  /// (see [deleteAccountErrorMessage]).
  static Future<DateTime> deleteAccount() async {
    final res = await _client.functions
        .invoke('delete-account', method: HttpMethod.post);
    final scheduledFor = scheduledForFromResponse(res.data);
    // The server already revoked every session; clear this device's copy.
    await _client.auth.signOut(scope: SignOutScope.local);
    return scheduledFor;
  }

  /// Parses `{"scheduled_for": "<ISO>"}` from the `delete-account` response.
  static DateTime scheduledForFromResponse(Object? data) {
    final iso = data is Map ? data['scheduled_for'] : null;
    if (iso is! String) throw const FormatException('missing scheduled_for');
    return DateTime.parse(iso).toLocal();
  }

  /// When the signed-in user's account will be permanently deleted, or null if
  /// no deletion is pending (or nobody is signed in).
  static Future<DateTime?> pendingDeletion() async {
    final userId = NextShowSupabaseClient.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('account_deletions')
        .select('scheduled_for')
        .eq('user_id', userId)
        .maybeSingle();
    return row == null
        ? null
        : DateTime.parse(row['scheduled_for'] as String).toLocal();
  }

  /// Cancels a pending deletion for the signed-in user.
  static Future<void> restoreAccount() => _client.rpc('restore_account');

  /// User-facing text for a failed [deleteAccount].
  static String deleteAccountErrorMessage(Object error) {
    if (error is FunctionException && error.status == 409) {
      return 'Your account still owns venues. Transfer or remove them first, '
          'or contact support.';
    }
    return "We couldn't delete your account. Check your connection and try again.";
  }
}
