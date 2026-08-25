import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../core/router/app_router.dart';
import '../../../services/auth_service.dart';
import '../../discovery/presentation/cinema_theme.dart';

/// Pushes the sign-in flow and returns true once the user is authenticated,
/// or false if they backed out. Screens that need identity (saving to the
/// watchlist, the AI concierge, etc.) should await this before continuing.
Future<bool> ensureSignedIn(BuildContext context) async {
  if (AuthService.isSignedIn) return true;
  final result = await const LoginRoute().push<bool>(context);
  return result ?? false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isSending = false;
  bool _isGoogleLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (!AuthService.isValidEmail(email)) {
      setState(() => _errorText = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _isSending = true;
      _errorText = null;
    });

    try {
      await AuthService.sendOtp(email);
      if (!mounted) return;
      final verified = await OtpRoute(email: email).push<bool>(context);
      if (verified == true && mounted) {
        context.pop(true);
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
      backgroundColor: CinemaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CinemaColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NSLogo(fontSize: 26),
            const SizedBox(height: 28),
            Text('Sign in', style: CinemaTextStyles.spotlightTitle),
            const SizedBox(height: 6),
            Text(
              "No password needed — we'll email you a code.",
              style: CinemaTextStyles.body,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              style: CinemaTextStyles.body.copyWith(color: CinemaColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: CinemaTextStyles.meta,
                errorText: _errorText,
                errorStyle: const TextStyle(color: NSColors.error),
                filled: true,
                fillColor: CinemaColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CinemaColors.glassBorder),
                ),
              ),
              onSubmitted: (_) => _sendCode(),
            ),
            const SizedBox(height: 16),
            NSPrimaryButton(
              label: 'Send code',
              isLoading: _isSending,
              onPressed: _sendCode,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: CinemaColors.glassBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or', style: CinemaTextStyles.meta),
                ),
                Expanded(child: Divider(color: CinemaColors.glassBorder)),
              ],
            ),
            const SizedBox(height: 20),
            CinemaSecondaryButton(
              label: 'Continue with Google',
              isLoading: _isGoogleLoading,
              onPressed: _continueWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}
