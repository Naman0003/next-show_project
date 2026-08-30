import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../../services/auth_service.dart';
import '../../discovery/presentation/theme/cinema_tokens.dart';
import '../../discovery/presentation/theme/nsx_motion.dart';
import '../../discovery/presentation/widgets/glass.dart';
import '../../discovery/presentation/widgets/nsx_button.dart';
import '../../discovery/presentation/widgets/spring_tap.dart';

/// Returns true once the user is authenticated, false if they dismissed.
/// Screens that need identity (saving to the watchlist, the AI concierge)
/// await this before continuing. The flow is a frosted bottom-sheet fragment
/// over a blurred backdrop — it never takes over as a full screen, so the
/// caller's browsing position is preserved.
Future<bool> ensureSignedIn(BuildContext context) async {
  if (AuthService.isSignedIn) return true;
  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
    _AuthSheetRoute(),
  );
  return result ?? false;
}

/// A non-opaque route: the caller's screen stays mounted and visible (blurred)
/// underneath while the sheet glides up.
class _AuthSheetRoute extends PageRouteBuilder<bool> {
  _AuthSheetRoute()
      : super(
          opaque: false,
          barrierColor: null,
          transitionDuration: NsxMotion.slow,
          reverseTransitionDuration: NsxMotion.medium,
          pageBuilder: (context, anim, _) => _AuthScaffold(anim: anim),
        );
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.anim});

  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    final reduced = NsxMotion.reduced(context);
    final eased = CurvedAnimation(parent: anim, curve: NsxMotion.expoOut);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Blurred, dimmed backdrop — the discovery screen shows through.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(false),
              child: AnimatedBuilder(
                animation: eased,
                builder: (context, _) => BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 10 * eased.value,
                    sigmaY: 10 * eased.value,
                  ),
                  child: ColoredBox(
                    color:
                        NsxColors.ground.withValues(alpha: 0.32 * eased.value),
                  ),
                ),
              ),
            ),
          ),
          // The sheet.
          Align(
            alignment: Alignment.bottomCenter,
            child: reduced
                ? FadeTransition(opacity: eased, child: const _AuthSheet())
                : SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(eased),
                    child: const _AuthSheet(),
                  ),
          ),
        ],
      ),
    );
  }
}

enum _Phase { email, otp }

class _AuthSheet extends StatefulWidget {
  const _AuthSheet();

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  _Phase _phase = _Phase.email;
  bool _sending = false;
  bool _verifying = false;
  bool _googleLoading = false;
  bool _resending = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  Future<void> _sendCode() async {
    if (!AuthService.isValidEmail(_email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await AuthService.sendOtp(_email);
      if (mounted) {
        setState(() {
          _phase = _Phase.otp;
          _sending = false;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _sending = false;
      });
    } catch (_) {
      setState(() {
        _error = "Couldn't send a code right now. Try again.";
        _sending = false;
      });
    }
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code from your email.');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await AuthService.verifyOtp(email: _email, code: code);
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _verifying = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Try again.';
        _verifying = false;
      });
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await AuthService.sendOtp(_email);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await AuthService.signInWithGoogle();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Couldn't start Google sign-in. Try again.");
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: GlassSurface(
        borderRadius: 20,
        blurSigma: 22,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                NsxSpace.x6, NsxSpace.x3, NsxSpace.x6, NsxSpace.x6),
            child: AnimatedSize(
              duration: NsxMotion.medium,
              curve: NsxMotion.expoOut,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: NsxColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: NsxSpace.x5),
                  AnimatedSwitcher(
                    duration: NsxMotion.medium,
                    switchInCurve: NsxMotion.expoOut,
                    transitionBuilder: (child, animation) {
                      final slide = Tween(
                        begin: Offset(_phase == _Phase.otp ? 0.12 : -0.12, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: _phase == _Phase.email
                        ? _EmailPhase(
                            key: const ValueKey('email'),
                            controller: _emailController,
                            error: _error,
                            sending: _sending,
                            googleLoading: _googleLoading,
                            onSend: _sendCode,
                            onGoogle: _google,
                          )
                        : _OtpPhase(
                            key: const ValueKey('otp'),
                            email: _email,
                            controller: _codeController,
                            error: _error,
                            verifying: _verifying,
                            resending: _resending,
                            onVerify: _verify,
                            onResend: _resend,
                            onBack: () => setState(() {
                              _phase = _Phase.email;
                              _error = null;
                            }),
                          ),
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

class _EmailPhase extends StatelessWidget {
  const _EmailPhase({
    super.key,
    required this.controller,
    required this.error,
    required this.sending,
    required this.googleLoading,
    required this.onSend,
    required this.onGoogle,
  });

  final TextEditingController controller;
  final String? error;
  final bool sending;
  final bool googleLoading;
  final VoidCallback onSend;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('No password.\nJust a code.', style: NsxType.display),
        const SizedBox(height: NsxSpace.x4),
        _Field(
          controller: controller,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          onSubmitted: (_) => onSend(),
        ),
        if (error != null) ...[
          const SizedBox(height: NsxSpace.x2),
          Text(error!,
              style: NsxType.mono
                  .copyWith(color: const Color(0xFFEF6A5F), fontSize: 10)),
        ],
        const SizedBox(height: NsxSpace.x3),
        NsxButton(label: 'Send code', loading: sending, onPressed: onSend),
        const SizedBox(height: NsxSpace.x3),
        const Row(
          children: [
            Expanded(child: Divider(color: NsxColors.hairline)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: NsxSpace.x3),
              child: Text('OR', style: NsxType.monoTiny),
            ),
            Expanded(child: Divider(color: NsxColors.hairline)),
          ],
        ),
        const SizedBox(height: NsxSpace.x3),
        NsxButton(
          label: 'Continue with Google',
          ghost: true,
          loading: googleLoading,
          onPressed: onGoogle,
        ),
      ],
    );
  }
}

class _OtpPhase extends StatelessWidget {
  const _OtpPhase({
    super.key,
    required this.email,
    required this.controller,
    required this.error,
    required this.verifying,
    required this.resending,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
  });

  final String email;
  final TextEditingController controller;
  final String? error;
  final bool verifying;
  final bool resending;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SpringTap(
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_back, size: 16, color: NsxColors.muted),
              ),
            ),
            const SizedBox(width: NsxSpace.x2),
            Expanded(
              child: Text('CODE SENT TO ${email.toUpperCase()}',
                  style: NsxType.monoTiny,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: NsxSpace.x5),
        _Field(
          controller: controller,
          hint: '',
          keyboardType: TextInputType.number,
          autofocus: true,
          center: true,
          letterSpacing: 8,
          onSubmitted: (_) => onVerify(),
        ),
        if (error != null) ...[
          const SizedBox(height: NsxSpace.x2),
          Text(error!,
              style: NsxType.mono
                  .copyWith(color: const Color(0xFFEF6A5F), fontSize: 10)),
        ],
        const SizedBox(height: NsxSpace.x4),
        NsxButton(label: 'Verify', loading: verifying, onPressed: onVerify),
        const SizedBox(height: NsxSpace.x3),
        Center(
          child: SpringTap(
            onTap: resending ? null : onResend,
            child: Text(resending ? 'SENDING…' : 'RESEND CODE',
                style: NsxType.mono
                    .copyWith(color: NsxColors.accent, fontSize: 10)),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.autofocus = false,
    this.center = false,
    this.letterSpacing,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool autofocus;
  final bool center;
  final double? letterSpacing;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NsxColors.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NsxColors.glassBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: NsxSpace.x4),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textAlign: center ? TextAlign.center : TextAlign.start,
        onSubmitted: onSubmitted,
        cursorColor: NsxColors.accent,
        style: (center ? NsxType.title : NsxType.text).copyWith(
          color: NsxColors.bone,
          letterSpacing: letterSpacing,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: NsxType.textMuted.copyWith(letterSpacing: letterSpacing),
        ),
      ),
    );
  }
}
