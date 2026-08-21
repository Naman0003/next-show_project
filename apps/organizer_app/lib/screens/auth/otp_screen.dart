// lib/screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorText;

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = "Enter the code from your email.");
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      await NextShowSupabaseClient.verifyOtp(email: widget.email, code: code);
      if (mounted) Navigator.pop(context, true);
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = "Something went wrong. Try again.");
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await NextShowSupabaseClient.signInWithOtp(email: widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New code sent.")),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const NSLogo(fontSize: 32),
              const SizedBox(height: 8),
              Text(
                'Check your email',
                style: NSTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification code to ${widget.email}',
                style: NSTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 12,
                textAlign: TextAlign.center,
                style: NSTextStyles.headlineLarge.copyWith(letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: 'Enter code',
                  counterText: '',
                  errorText: _errorText,
                ),
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 24),
              NSPrimaryButton(
                label: 'Verify Code',
                onPressed: _isVerifying ? null : _verify,
                isLoading: _isVerifying,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isResending ? null : _resend,
                child: _isResending
                    ? Text('Sending...', style: NSTextStyles.bodyMedium)
                    : Text("Didn't receive a code? Resend", style: NSTextStyles.bodyMedium),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}