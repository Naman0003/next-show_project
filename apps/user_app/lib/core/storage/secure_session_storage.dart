import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Keeps the Supabase session (incl. the refresh token) in the iOS Keychain /
/// Android Keystore-backed storage instead of plain SharedPreferences (S14).
///
/// On first use it also:
/// - moves a session saved by an older build out of SharedPreferences and
///   deletes the plaintext copy, so testers stay signed in after the update;
/// - clears a session left in the iOS Keychain by a previous install, since the
///   Keychain survives uninstalling the app and SharedPreferences does not.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({
    required this.persistSessionKey,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  /// Same key supabase_flutter uses by default (`sb-<project-ref>-auth-token`).
  factory SecureSessionStorage.forUrl(String supabaseUrl) => SecureSessionStorage(
        persistSessionKey:
            'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token',
      );

  final String persistSessionKey;
  final FlutterSecureStorage _storage;

  /// Set in SharedPreferences once this install has started using the secure store.
  static const installMarkerKey = 'secure_session_storage_installed';

  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(installMarkerKey) == true) return;

    // Fresh install (or first run of this build): anything in the secure store
    // belongs to an earlier install, so drop it.
    await _storage.delete(key: persistSessionKey);
    final legacy = prefs.getString(persistSessionKey);
    if (legacy != null) {
      await _storage.write(key: persistSessionKey, value: legacy);
      await prefs.remove(persistSessionKey);
    }
    await prefs.setBool(installMarkerKey, true);
  }

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: persistSessionKey);

  @override
  Future<String?> accessToken() => _storage.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: persistSessionKey, value: persistSessionString);
}
