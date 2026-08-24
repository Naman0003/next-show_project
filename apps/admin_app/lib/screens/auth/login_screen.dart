import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';
import 'otp_screen.dart';

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
  String? _errorText;

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      setState(() => _errorText = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _isSending = true;
      _errorText = null;
    });

    try {
      await NextShowSupabaseClient.signInWithOtp(email: email);
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
      setState(() => _errorText = e.message);
    } catch (_) {
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
                    'Admin Portal',
                    style: NSTextStyles.headlineMedium.copyWith(
                      color: NSColors.royalBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verify partners, moderate events, and configure the platform.',
                    style: NSTextStyles.bodyMedium.copyWith(color: NSColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Admin Email Address',
                      hintText: 'admin@nextshow.com',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      errorText: _errorText,
                    ),
                    onSubmitted: (_) => _sendOtp(),
                  ),
                  const SizedBox(height: 24),
                  NSPrimaryButton(
                    label: 'Send Verification Code',
                    onPressed: _isSending ? null : _sendOtp,
                    isLoading: _isSending,
                    icon: Icons.send_rounded,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
