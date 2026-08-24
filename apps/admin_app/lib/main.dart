import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/api_keys.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiKeys.supabaseUrl,
    anonKey: ApiKeys.supabaseAnonKey,
  );

  // Initialize typed Supabase client
  await NextShowSupabaseClient.initialize(
    url: ApiKeys.supabaseUrl,
    anonKey: ApiKeys.supabaseAnonKey,
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextShow Admin',
      debugShowCheckedModeBanner: false,
      theme: nsTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _cachedUserId;
  Future<bool>? _adminCheckFuture;

  void _refreshAdminCheck(String userId) {
    setState(() {
      _adminCheckFuture = _checkAdminRole(userId);
    });
  }

  Future<bool> _checkAdminRole(String userId) async {
    try {
      debugPrint('>>> [ADMIN_CHECK] Checking admin status for userId: $userId');
      final response = await NextShowSupabaseClient.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      debugPrint('>>> [ADMIN_CHECK] Supabase response: $response');
      if (response == null) {
        return false;
      }
      final roleStr = response['role']?.toString().toLowerCase();
      debugPrint('>>> [ADMIN_CHECK] Role is: "$roleStr"');
      return roleStr == 'admin';
    } catch (e, st) {
      debugPrint('>>> [ADMIN_CHECK] Exception checking admin role: $e');
      debugPrint('>>> [ADMIN_CHECK] StackTrace: $st');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: NextShowSupabaseClient.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? NextShowSupabaseClient.client.auth.currentSession;

        if (session == null && snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: NSLoading(message: 'Loading...'));
        }

        if (session != null) {
          final userId = session.user.id;
          if (_cachedUserId != userId || _adminCheckFuture == null) {
            _cachedUserId = userId;
            _adminCheckFuture = _checkAdminRole(userId);
          }

          return FutureBuilder<bool>(
            future: _adminCheckFuture,
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: NSLoading(message: 'Checking admin permissions...'));
              }

              final isAdmin = roleSnapshot.data ?? false;

              if (isAdmin) {
                return const AdminDashboardScreen();
              } else {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: NSColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              size: 64,
                              color: NSColors.error,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Admin Access Required',
                            style: NSTextStyles.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your account does not have administrator privileges. Please sign out and log in with an admin account.',
                            style: NSTextStyles.bodyMedium.copyWith(color: NSColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          NSSecondaryButton(
                            label: 'Refresh / Check Again',
                            onPressed: () => _refreshAdminCheck(userId),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            child: Text('Sign Out', style: NSTextStyles.bodyMedium.copyWith(color: NSColors.error)),
                            onPressed: () {
                              setState(() {
                                _cachedUserId = null;
                                _adminCheckFuture = null;
                              });
                              NextShowSupabaseClient.signOut();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
