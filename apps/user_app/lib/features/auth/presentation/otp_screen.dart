import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../services/auth_service.dart';
import '../../discovery/presentation/cinema_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = 'Enter the code from your email.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      await AuthService.verifyOtp(email: widget.email, code: code);
      if (mounted) context.pop(true);
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = 'Something went wrong. Try again.');
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
          const SnackBar(content: Text('New code sent.')),
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
      backgroundColor: CinemaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CinemaColors.textPrimary),
        title: Text('Enter code', style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We sent a code to', style: CinemaTextStyles.meta),
            const SizedBox(height: 2),
            Text(widget.email, style: CinemaTextStyles.cardTitle),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 12,
              style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 24, letterSpacing: 4),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: '00000000',
                hintStyle: CinemaTextStyles.meta,
                errorText: _errorText,
                errorStyle: const TextStyle(color: NSColors.error),
                filled: true,
                fillColor: NSColors.royalBlue.withOpacity(0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 16),
            NSPrimaryButton(
              label: 'Verify',
              isLoading: _isVerifying,
              onPressed: _verify,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _isResending ? null : _resend,
                child: Text(
                  _isResending ? 'Sending…' : 'Resend code',
                  style: CinemaTextStyles.meta.copyWith(
                    color: NSColors.skyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
