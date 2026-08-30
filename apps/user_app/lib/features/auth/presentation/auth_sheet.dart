import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../../services/auth_service.dart';
import '../../discovery/presentation/theme/cinema_tokens.dart';
import '../../discovery/presentation/theme/nsx_motion.dart';
import '../../discovery/presentation/widgets/glass.dart';
import '../../discovery/presentation/widgets/nsx_button.dart';
import '../../discovery/presentation/widgets/spring_tap.dart';
import 'widgets/auth_mode_toggle.dart';

/// Returns true once the user is authenticated, false if they dismissed.
/// Screens that need identity (saving to the watchlist, the AI concierge)
/// await this before continuing. The flow is a frosted bottom-sheet fragment
/// over a blurred backdrop — it never takes over as a full screen, so the
/// caller's browsing position is preserved.
Future<bool> ensureSignedIn(
  BuildContext context, {
  AuthMode initialMode = AuthMode.signIn,
}) async {
  if (AuthService.isSignedIn) return true;
  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
    _AuthSheetRoute(initialMode: initialMode),
  );
  return result ?? false;
}

/// A non-opaque route: the caller's screen stays mounted and visible (blurred)
/// underneath while the sheet glides up.
class _AuthSheetRoute extends PageRouteBuilder<bool> {
  _AuthSheetRoute({required AuthMode initialMode})
      : super(
          opaque: false,
          barrierColor: null,
          transitionDuration: NsxMotion.slow,
          reverseTransitionDuration: NsxMotion.medium,
          pageBuilder: (context, anim, _) =>
              _AuthScaffold(anim: anim, initialMode: initialMode),
        );
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.anim, required this.initialMode});

  final Animation<double> anim;
  final AuthMode initialMode;

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
                ? FadeTransition(
                    opacity: eased,
                    child: _AuthSheet(initialMode: initialMode),
                  )
                : SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(eased),
                    child: _AuthSheet(initialMode: initialMode),
                  ),
          ),
        ],
      ),
    );
  }
}

enum _Phase { email, otp }

class _AuthSheet extends StatefulWidget {
  const _AuthSheet({required this.initialMode});

  final AuthMode initialMode;

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codeController = TextEditingController();

  _Phase _phase = _Phase.email;
  late AuthMode _mode = widget.initialMode;
  bool _sending = false;
  bool _authenticating = false;
  bool _verifying = false;
  bool _googleLoading = false;
  bool _resending = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  Future<void> _submitPassword() async {
    final password = _passwordController.text;
    if (!AuthService.isValidEmail(_email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (_mode == AuthMode.signUp && _confirmController.text != password) {
      setState(() => _error = "Those passwords don't match.");
      return;
    }
    setState(() {
      _authenticating = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_mode == AuthMode.signIn) {
        await AuthService.signInWithPassword(email: _email, password: password);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final res = await AuthService.signUpWithPassword(
          email: _email,
          password: password,
        );
        if (!mounted) return;
        if (res.session != null) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _authenticating = false;
            _mode = AuthMode.signIn;
            _notice = 'Check your email to confirm your account, then sign in.';
          });
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _authenticating = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Try again.';
        _authenticating = false;
      });
    }
  }

  Future<void> _sendCode() async {
    if (!AuthService.isValidEmail(_email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
      _notice = null;
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Never taller than the space left above the keyboard and
                // status bar — the sheet scrolls internally past that.
                maxHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).top -
                    keyboard -
                    NsxSpace.x4,
              ),
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
                  Flexible(
                    child: SingleChildScrollView(
                      child: AnimatedSize(
                        duration: NsxMotion.medium,
                        curve: NsxMotion.expoOut,
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: NsxMotion.medium,
                          switchInCurve: NsxMotion.expoOut,
                          transitionBuilder: (child, animation) {
                            final slide = Tween(
                              begin: Offset(
                                  _phase == _Phase.otp ? 0.12 : -0.12, 0),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                  position: slide, child: child),
                            );
                          },
                          child: _phase == _Phase.email
                              ? _EmailPhase(
                                  key: const ValueKey('email'),
                                  controller: _emailController,
                                  passwordController: _passwordController,
                                  confirmController: _confirmController,
                                  mode: _mode,
                                  error: _error,
                                  notice: _notice,
                                  authenticating: _authenticating,
                                  sendingCode: _sending,
                                  googleLoading: _googleLoading,
                                  onModeChanged: (m) => setState(() {
                                    _mode = m;
                                    _error = null;
                                    _notice = null;
                                  }),
                                  onSubmitPassword: _submitPassword,
                                  onSendCode: _sendCode,
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
                      ),
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
    required this.passwordController,
    required this.confirmController,
    required this.mode,
    required this.error,
    required this.notice,
    required this.authenticating,
    required this.sendingCode,
    required this.googleLoading,
    required this.onModeChanged,
    required this.onSubmitPassword,
    required this.onSendCode,
    required this.onGoogle,
  });

  final TextEditingController controller;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final AuthMode mode;
  final String? error;
  final String? notice;
  final bool authenticating;
  final bool sendingCode;
  final bool googleLoading;
  final ValueChanged<AuthMode> onModeChanged;
  final VoidCallback onSubmitPassword;
  final VoidCallback onSendCode;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    final signUp = mode == AuthMode.signUp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthModeToggle(mode: mode, onChanged: onModeChanged),
        const SizedBox(height: NsxSpace.x5),
        Text(
          signUp ? 'Create your\naccount.' : 'Welcome back.',
          style: NsxType.display,
        ),
        const SizedBox(height: NsxSpace.x2),
        Text(
          signUp
              ? 'One account for tickets, your watchlist, and the concierge.'
              : 'Sign in to pick up where you left off.',
          style: NsxType.textMuted,
        ),
        const SizedBox(height: NsxSpace.x4),
        _Field(
          controller: controller,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: NsxSpace.x2),
        _Field(
          controller: passwordController,
          hint: 'Password',
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          textInputAction: signUp ? TextInputAction.next : TextInputAction.done,
          onSubmitted: signUp ? null : (_) => onSubmitPassword(),
        ),
        if (signUp) ...[
          const SizedBox(height: NsxSpace.x2),
          _Field(
            controller: confirmController,
            hint: 'Confirm password',
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmitPassword(),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: NsxSpace.x2),
          Text(error!,
              style: NsxType.mono
                  .copyWith(color: const Color(0xFFEF6A5F), fontSize: 10)),
        ],
        if (notice != null) ...[
          const SizedBox(height: NsxSpace.x2),
          Text(notice!,
              style:
                  NsxType.mono.copyWith(color: NsxColors.muted, fontSize: 10)),
        ],
        const SizedBox(height: NsxSpace.x3),
        NsxButton(
          label: signUp ? 'Create account' : 'Sign in',
          loading: authenticating,
          onPressed: onSubmitPassword,
        ),
        const SizedBox(height: NsxSpace.x3),
        Center(
          child: SpringTap(
            onTap: sendingCode ? null : onSendCode,
            child: Text(
              sendingCode ? 'SENDING…' : 'EMAIL ME A CODE INSTEAD',
              style:
                  NsxType.mono.copyWith(color: NsxColors.muted, fontSize: 10),
            ),
          ),
        ),
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
    this.obscureText = false,
    this.letterSpacing,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool autofocus;
  final bool center;
  final bool obscureText;
  final double? letterSpacing;
  final TextInputAction? textInputAction;
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
        obscureText: obscureText,
        textInputAction: textInputAction,
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
