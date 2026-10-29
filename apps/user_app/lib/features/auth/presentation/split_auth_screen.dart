import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthException;

import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';

/// Returns true once the user is authenticated, false if they backed out.
/// Screens that need identity (the concierge, the profile) await this before
/// continuing.
Future<bool> ensureSignedIn(BuildContext context) async {
  if (AuthService.isSignedIn) return true;
  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const SplitAuthScreen(),
    ),
  );
  return result ?? false;
}

/// Passwordless auth: email -> one-time code -> signed in. Sign-in and
/// sign-up are the same flow — Supabase creates the account on first verify.
///
/// A solid brand panel and a white form panel share the screen along its long
/// axis (side-by-side on wide layouts, stacked on phones), split by a curve.
class SplitAuthScreen extends StatefulWidget {
  const SplitAuthScreen({super.key});

  @override
  State<SplitAuthScreen> createState() => _SplitAuthScreenState();
}

class _SplitAuthScreenState extends State<SplitAuthScreen> {
  StreamSubscription<dynamic>? _authSub;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    try {
      // Covers both a verified code and the Google OAuth return.
      _authSub = AuthService.onAuthStateChange.listen((state) {
        if (state.event == AuthChangeEvent.signedIn &&
            AuthService.isSignedIn &&
            mounted &&
            !_popped) {
          _popped = true;
          Navigator.of(context).pop(true);
        }
      });
    } catch (_) {
      // Supabase not initialised (e.g. widget tests) — the UI still renders.
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // While the keyboard is up the phone banner shrinks so the field stays
    // visible above it.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 700;
              final form = SafeArea(
                top: wide,
                child: const SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _OtpForm(),
                  ),
                ),
              );

              if (wide) {
                return Row(
                  children: [
                    SizedBox(
                      width: box.maxWidth * 0.5,
                      child: ClipPath(
                        clipper: _PanelClipper(wide: true),
                        child: const ColoredBox(
                          color: AppColors.royalBlue,
                          child: _PanelContent(compact: false),
                        ),
                      ),
                    ),
                    Expanded(child: Center(child: form)),
                  ],
                );
              }

              // Phone: banner on top, form below — never overlapping.
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    height: keyboardOpen
                        ? topInset + 72 + _kCurveDepth
                        : box.maxHeight * 0.34 + _kCurveDepth,
                    child: ClipPath(
                      clipper: _PanelClipper(wide: false),
                      child: ColoredBox(
                        color: AppColors.royalBlue,
                        child: _PanelContent(compact: keyboardOpen),
                      ),
                    ),
                  ),
                  Expanded(child: form),
                ],
              );
            },
          ),

          // --- Close affordance. ---
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(false),
            ),
          ),
        ],
      ),
    );
  }
}

const double _kCurveDepth = 44;

/* ------------------------------------------------------------------ */
/*  Panel shape + content                                             */
/* ------------------------------------------------------------------ */

/// Clips the brand panel so its inner edge (the one facing the form) is a
/// single sweeping curve rather than a straight line.
class _PanelClipper extends CustomClipper<Path> {
  _PanelClipper({required this.wide});

  final bool wide;

  @override
  Path getClip(Size size) {
    final p = Path();
    final w = size.width;
    final h = size.height;
    const d = _kCurveDepth;

    if (wide) {
      // Flat left edge, curved right edge.
      p.moveTo(0, 0);
      p.lineTo(w - d, 0);
      p.cubicTo(w + 6, h * 0.28, w + 6, h * 0.72, w - d, h);
      p.lineTo(0, h);
    } else {
      // Flat top edge, curved bottom edge.
      p.moveTo(0, 0);
      p.lineTo(0, h - d);
      p.cubicTo(w * 0.28, h + 6, w * 0.72, h + 6, w, h - d);
      p.lineTo(w, 0);
    }
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_PanelClipper old) => old.wide != wide;
}

class _PanelContent extends StatelessWidget {
  const _PanelContent({required this.compact});

  /// Title only — used while the keyboard has shrunk the banner.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 8, 48, _kCurveDepth),
        child: Center(
          // Scales down rather than overflowing while the banner animates.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to Next Show',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 12),
                    Text(
                      "No passwords. We'll email you a code to sign in — "
                      'new here? That creates your account too.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/*  The form                                                           */
/* ------------------------------------------------------------------ */

class _OtpForm extends StatefulWidget {
  const _OtpForm();

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  /// Supabase's minimum gap between emails to the same address.
  static const _resendCooldown = 60;

  final _email = TextEditingController();
  final _code = TextEditingController();

  /// Null until a code has been sent; then the address it went to.
  String? _sentTo;
  bool _working = false;
  bool _googleWorking = false;
  String? _error;
  String? _notice;

  int _cooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = _resendCooldown);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  String _messageFor(AuthException e) {
    switch (e.code) {
      case 'over_email_send_rate_limit':
        return 'Too many codes sent. Wait a bit and try again.';
      case 'otp_expired':
        return 'That code is wrong or has expired. Try again or resend.';
      case 'otp_disabled':
      case 'signup_disabled':
        return 'Email sign-in is turned off right now.';
      default:
        return e.message;
    }
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!AuthService.isValidEmail(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _working = true;
      _error = null;
      _notice = null;
    });
    try {
      await AuthService.sendOtp(email);
      if (!mounted) return;
      final resend = _sentTo == email;
      setState(() {
        _sentTo = email;
        _code.clear();
        _notice = resend ? 'New code sent.' : null;
      });
      _startCooldown();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _messageFor(e));
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'Enter the code from the email.');
      return;
    }
    setState(() {
      _working = true;
      _error = null;
      _notice = null;
    });
    try {
      // On success the screen pops via the auth-state listener.
      await AuthService.verifyOtp(email: _sentTo!, code: code);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _messageFor(e));
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _changeEmail() {
    _cooldownTimer?.cancel();
    setState(() {
      _sentTo = null;
      _cooldown = 0;
      _code.clear();
      _error = null;
      _notice = null;
    });
  }

  Future<void> _google() async {
    setState(() {
      _googleWorking = true;
      _error = null;
    });
    try {
      await AuthService.signInWithGoogle();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = "Couldn't start Google sign-in. Try again.");
      }
    } finally {
      if (mounted) setState(() => _googleWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final codeStep = _sentTo != null;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            codeStep ? 'Check your email' : 'Continue with email',
            textAlign: TextAlign.center,
            style: text.headlineSmall!.copyWith(fontWeight: FontWeight.w800),
          ),
          if (codeStep) ...[
            const SizedBox(height: 8),
            Text(
              'We sent a code to $_sentTo',
              textAlign: TextAlign.center,
              style: text.bodyMedium!.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 18),
          if (!codeStep)
            _AuthField(
              key: const ValueKey('email'),
              controller: _email,
              hint: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _sendCode(),
            )
          else
            _AuthField(
              key: const ValueKey('code'),
              controller: _code,
              hint: 'Code',
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              letterSpacing: 6,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _verify(),
            ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: text.bodySmall!.copyWith(color: AppColors.error),
            ),
          ],
          if (_notice != null) ...[
            const SizedBox(height: 10),
            Text(
              _notice!,
              textAlign: TextAlign.center,
              style: text.bodySmall!.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: codeStep ? 'Verify' : 'Send code',
            loading: _working,
            onPressed: codeStep ? _verify : _sendCode,
          ),
          const SizedBox(height: 10),
          if (codeStep) ...[
            TextButton(
              onPressed: _working || _cooldown > 0 ? null : _sendCode,
              child: Text(
                _cooldown > 0 ? 'Resend code in ${_cooldown}s' : 'Resend code',
              ),
            ),
            TextButton(
              onPressed: _working ? null : _changeEmail,
              child: const Text('Use a different email'),
            ),
          ] else
            _GoogleButton(loading: _googleWorking, onPressed: _google),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/*  Controls                                                           */
/* ------------------------------------------------------------------ */

class _AuthField extends StatelessWidget {
  const _AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.autofillHints,
    this.inputFormatters,
    this.letterSpacing,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final double? letterSpacing;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              autofillHints: autofillHints,
              inputFormatters: inputFormatters,
              autofocus: autofocus,
              autocorrect: false,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              cursorColor: AppColors.royalBlue,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(letterSpacing: letterSpacing),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.royalBlue.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, this.loading = false});

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.g_mobiledata_rounded,
                size: 26, color: AppColors.royalBlue),
        label: const Text('Continue with Google'),
      ),
    );
  }
}
