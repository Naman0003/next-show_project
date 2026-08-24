import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/api_keys.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
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

enum PartnerVerificationState {
  notPartner,
  pending,
  verified,
}

class _ProfileResult {
  final PartnerVerificationState verificationState;
  final bool needsProfileSetup;
  const _ProfileResult(this.verificationState, {this.needsProfileSetup = false});
}

class _AuthGateState extends State<AuthGate> {
  String? _cachedUserId;
  Future<_ProfileResult>? _partnerRoleFuture;

  void _refreshRole(String userId) {
    setState(() {
      _partnerRoleFuture = _checkProfile(userId);
    });
  }

  Future<void> _upgradeRoleToPartner(String userId) async {
    await NextShowSupabaseClient.client
        .from('profiles')
        .update({'role': 'partner'})
        .eq('id', userId);
  }

  Future<_ProfileResult> _checkProfile(String userId) async {
    try {
      debugPrint('>>> [ROLE_CHECK] Checking profile for userId: $userId');
      final response = await NextShowSupabaseClient.client
          .from('profiles')
          .select('role, is_verified, full_name')
          .eq('id', userId)
          .maybeSingle();

      debugPrint('>>> [ROLE_CHECK] Supabase response: $response');
      if (response == null) {
        debugPrint('>>> [ROLE_CHECK] No profile found for userId: $userId');
        return const _ProfileResult(PartnerVerificationState.notPartner);
      }

      final roleStr = response['role']?.toString().toLowerCase();
      final isVerified = response['is_verified'] as bool? ?? false;
      final fullName = response['full_name'] as String?;
      final needsSetup = fullName == null || fullName.trim().isEmpty;
      debugPrint('>>> [ROLE_CHECK] role="$roleStr", isVerified=$isVerified, fullName=$fullName');

      // Auto-upgrade: anyone signing in on the organizer app is a partner by intent.
      // If still 'user', silently upgrade to 'partner' (unverified) so they
      // appear in the admin app's Pending queue immediately.
      if (roleStr == 'user') {
        debugPrint('>>> [ROLE_CHECK] Auto-upgrading role to partner...');
        await _upgradeRoleToPartner(userId);
        return _ProfileResult(PartnerVerificationState.pending, needsProfileSetup: needsSetup);
      }

      PartnerVerificationState state;
      if (roleStr == 'admin') {
        state = PartnerVerificationState.verified;
      } else if (roleStr == 'partner') {
        state = isVerified
            ? PartnerVerificationState.verified
            : PartnerVerificationState.pending;
      } else {
        state = PartnerVerificationState.notPartner;
      }

      return _ProfileResult(state, needsProfileSetup: needsSetup);
    } catch (e, st) {
      debugPrint('>>> [ROLE_CHECK] Exception while checking profile: $e');
      debugPrint('>>> [ROLE_CHECK] StackTrace: $st');
      return const _ProfileResult(PartnerVerificationState.notPartner);
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
            _partnerRoleFuture = _checkProfile(userId);
          }

          // Check if user has partner/admin role, verification status, and full_name
          return FutureBuilder<_ProfileResult>(
            future: _partnerRoleFuture,
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: NSLoading(message: 'Checking permissions...'));
              }

              final result = roleSnapshot.data ?? const _ProfileResult(PartnerVerificationState.notPartner);
              final verificationState = result.verificationState;

              // Always collect name first, regardless of partner status
              if (result.needsProfileSetup) {
                return ProfileSetupScreen(
                  onComplete: () => _refreshRole(userId),
                );
              }

              if (verificationState == PartnerVerificationState.verified) {
                return const DashboardScreen();
              } else if (verificationState == PartnerVerificationState.pending) {
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
                              color: NSColors.warning.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.hourglass_empty_rounded,
                              size: 64,
                              color: NSColors.warning,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Verification Pending',
                            style: NSTextStyles.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your partner registration is being reviewed by an administrator. '
                            'You will be granted full portal access as soon as your account is verified.',
                            style: NSTextStyles.bodyMedium.copyWith(color: NSColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          NSPrimaryButton(
                            label: 'Refresh Status',
                            icon: Icons.refresh_rounded,
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
              } else {
                // Role is still being set up — show a brief loading screen.
                // This should only flash for a moment during the very first login.
                return const Scaffold(
                  body: NSLoading(message: 'Setting up your partner account...'),
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