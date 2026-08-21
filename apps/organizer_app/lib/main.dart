import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/api_keys.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';

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

  runApp(const OrganizerApp());
}

class OrganizerApp extends StatelessWidget {
  const OrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextShow Organizer',
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
  bool _isUpgrading = false;
  String? _cachedUserId;
  Future<bool>? _partnerRoleFuture;

  void _refreshRole(String userId) {
    setState(() {
      _partnerRoleFuture = _checkPartnerRole(userId);
    });
  }

  Future<void> _upgradeRoleToPartner(String userId) async {
    setState(() => _isUpgrading = true);
    try {
      await NextShowSupabaseClient.client
          .from('profiles')
          .update({'role': 'partner'})
          .eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account upgraded to Partner! Welcome.')),
        );
        _refreshRole(userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upgrade account: $e'), backgroundColor: NSColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpgrading = false);
    }
  }

  Future<bool> _checkPartnerRole(String userId) async {
    try {
      debugPrint('>>> [ROLE_CHECK] Checking role for userId: $userId');
      final response = await NextShowSupabaseClient.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      debugPrint('>>> [ROLE_CHECK] Supabase response: $response');
      if (response == null) {
        debugPrint('>>> [ROLE_CHECK] No profile found for userId: $userId');
        return false;
      }
      final roleStr = response['role']?.toString().toLowerCase();
      debugPrint('>>> [ROLE_CHECK] User role is: "$roleStr"');
      final isPartner = roleStr == 'partner' || roleStr == 'admin';
      debugPrint('>>> [ROLE_CHECK] isPartner result: $isPartner');
      return isPartner;
    } catch (e, st) {
      debugPrint('>>> [ROLE_CHECK] Exception while checking role: $e');
      debugPrint('>>> [ROLE_CHECK] StackTrace: $st');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: NextShowSupabaseClient.onAuthStateChange,
      builder: (context, snapshot) {
        // Use existing session immediately — don't wait for stream to show something
        final session = snapshot.data?.session ?? NextShowSupabaseClient.client.auth.currentSession;

        if (session == null && snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: NSLoading(message: 'Loading...'));
        }

        if (session != null) {
          final userId = session.user.id;
          if (_cachedUserId != userId || _partnerRoleFuture == null) {
            _cachedUserId = userId;
            _partnerRoleFuture = _checkPartnerRole(userId);
          }

          // Check if user has partner/admin role
          return FutureBuilder<bool>(
            future: _partnerRoleFuture,
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: NSLoading(message: 'Checking permissions...'));
              }

              if (roleSnapshot.data == true) {
                return const DashboardScreen();
              } else {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, size: 64, color: NSColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('Partner Access Required', style: NSTextStyles.headlineSmall, textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text(
                            'Your account is currently set to standard User access. Upgrade to a Partner account to start managing venues and scheduling showtimes.',
                            style: NSTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          NSPrimaryButton(
                            label: 'Upgrade to Partner Account',
                            isLoading: _isUpgrading,
                            icon: Icons.verified_user,
                            onPressed: () => _upgradeRoleToPartner(userId),
                          ),
                          const SizedBox(height: 12),
                          NSSecondaryButton(
                            label: 'Check Permission / Refresh',
                            onPressed: () => _refreshRole(userId),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            child: Text('Sign Out', style: NSTextStyles.bodyMedium.copyWith(color: NSColors.error)),
                            onPressed: () {
                              setState(() {
                                _cachedUserId = null;
                                _partnerRoleFuture = null;
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