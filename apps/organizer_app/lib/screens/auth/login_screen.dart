// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';
import 'otp_screen.dart';

/// Pushes the sign-in flow and returns true once the user is authenticated,
/// or false if they backed out.
Future<bool> ensureSignedIn(BuildContext context) async {
  if (NextShowSupabaseClient.isSignedIn) return true;
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return result ?? false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;
  bool _isGoogleLoading = false;
  String? _errorText;

  Future<void> _continueWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorText = null;
    });
    try {
      await NextShowSupabaseClient.signInWithGoogle();
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = "Couldn't start Google sign-in. Try again.");
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    debugPrint('>>> [OTP] _sendOtp triggered, email="$email"');
    if (!_isValidEmail(email)) {
      setState(() => _errorText = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _isSending = true;
      _errorText = null;
    });

    try {
      debugPrint('>>> [OTP] Sending OTP to: $email');
      await NextShowSupabaseClient.signInWithOtp(email: email);
      debugPrint('>>> [OTP] OTP sent successfully');
      if (mounted) {
        final verified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
        );

        if (verified == true && mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } on AuthException catch (e) {
      debugPrint('>>> [OTP] AuthException: statusCode=${e.statusCode} message=${e.message}');
      setState(() => _errorText = e.message);
    } catch (e, st) {
      debugPrint('>>> [OTP] Unknown error: $e');
      debugPrint('>>> [OTP] StackTrace: $st');
      setState(() => _errorText = "Couldn't send code. Try again.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight * 0.8),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const NSLogo(fontSize: 36),
                  const SizedBox(height: 12),
                  Text(
                    'Organizer Portal',
                    style: NSTextStyles.headlineMedium.copyWith(
                      color: NSColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your venues, publish events, and schedule showtimes.',
                    style: NSTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'partner@venue.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText: _errorText,
                    ),
                    onSubmitted: (_) => _sendOtp(),
                  ),
                  const SizedBox(height: 16),
                  NSPrimaryButton(
                    label: 'Send Verification Code',
                    onPressed: _isSending ? null : _sendOtp,
                    isLoading: _isSending,
                    icon: Icons.send,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: NSColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: NSTextStyles.bodySmall),
                      ),
                      const Expanded(child: Divider(color: NSColors.border)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  NSSecondaryButton(
                    label: 'Continue with Google',
                    onPressed: _isGoogleLoading ? null : _continueWithGoogle,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'By continuing, you agree to the NextShow Partner Terms & Privacy Policy.',
                    style: NSTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}