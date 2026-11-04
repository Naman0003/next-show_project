import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/core/storage/secure_session_storage.dart';

void main() {
  const key = 'sb-waqyoiheasnmtaqqayma-auth-token';
  TestWidgetsFlutterBinding.ensureInitialized();

  SecureSessionStorage storage() => SecureSessionStorage(persistSessionKey: key);

  test('forUrl uses the same key as supabase_flutter', () {
    expect(
      SecureSessionStorage.forUrl('https://waqyoiheasnmtaqqayma.supabase.co')
          .persistSessionKey,
      key,
    );
  });

  test('moves a plaintext session from an older build and deletes the copy', () async {
    SharedPreferences.setMockInitialValues({key: '{"session":"old"}'});
    FlutterSecureStorage.setMockInitialValues({});

    await storage().initialize();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(key), isNull);
    expect(await storage().accessToken(), '{"session":"old"}');
  });

  test('a fresh install drops a session left in the Keychain by an old install', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({key: '{"session":"previous install"}'});

    final s = storage();
    await s.initialize();

    expect(await s.hasAccessToken(), isFalse);
  });

  test('later launches keep the session; sign-out removes it', () async {
    SharedPreferences.setMockInitialValues({SecureSessionStorage.installMarkerKey: true});
    FlutterSecureStorage.setMockInitialValues({});

    final s = storage();
    await s.initialize();
    await s.persistSession('{"session":"new"}');
    await s.initialize();
    expect(await s.accessToken(), '{"session":"new"}');

    await s.removePersistedSession();
    expect(await s.hasAccessToken(), isFalse);
  });
}
