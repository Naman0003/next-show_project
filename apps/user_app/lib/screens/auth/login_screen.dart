// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/next_show_logo.dart';
import 'otp_screen.dart';

/// Pushes the sign-in flow and returns true once the user is authenticated,
/// or false if they backed out. Screens that need identity (AI concierge,
/// saving, etc.) should await this before continuing.
Future<bool> ensureSignedIn(BuildContext context) async {
  if (AuthService.isSignedIn) return true;
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return result ?? false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
      // On web this navigates away to Google's consent screen and back;
      // the app reloads fresh on return, so there's nothing to await here.
      await AuthService.signInWithGoogle();
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

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      setState(() => _errorText = "Enter a valid email address.");
      return;
    }

    setState(() {
      _isSending = true;
      _errorText = null;
    });

    try {
      await AuthService.sendOtp(email);
      if (!mounted) return;
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
      );
      if (verified == true && mounted) {
        Navigator.pop(context, true);
      }
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = "Couldn't send a code right now. Try again.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NextShowLogo(fontSize: 26),
            const SizedBox(height: 28),
            Text("Sign in", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              "No password needed — we'll email you a code.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "you@example.com",
                errorText: _errorText,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onSubmitted: (_) => _sendCode(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendCode,
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Send code"),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("or", style: Theme.of(context).textTheme.bodySmall),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _isGoogleLoading ? null : _continueWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isGoogleLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.royalBlue),
                      )
                    : Text(
                        "Continue with Google",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
