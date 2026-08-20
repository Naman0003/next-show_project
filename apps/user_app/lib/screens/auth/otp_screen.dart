// lib/screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({Key? key, required this.email}) : super(key: key);

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
      await AuthService.verifyOtp(email: widget.email, code: code);
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
      await AuthService.sendOtp(widget.email);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter code")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "We sent a code to",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
              widget.email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 12,
              style: const TextStyle(fontSize: 22, letterSpacing: 4, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: "",
                hintText: "00000000",
                errorText: _errorText,
                filled: true,
                fillColor: AppColors.iceBlue.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verify,
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Verify"),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _isResending ? null : _resend,
                child: Text(_isResending ? "Sending..." : "Resend code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
