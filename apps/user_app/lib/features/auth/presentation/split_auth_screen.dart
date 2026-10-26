import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthException;

import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';

/// Which form the auth screen is showing.
enum AuthMode { signIn, signUp }

/// Returns true once the user is authenticated, false if they backed out.
/// Screens that need identity (saving to the watchlist, the concierge) await
/// this before continuing.
Future<bool> ensureSignedIn(
  BuildContext context, {
  AuthMode initialMode = AuthMode.signIn,
}) async {
  if (AuthService.isSignedIn) return true;
  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => SplitAuthScreen(initialMode: initialMode),
    ),
  );
  return result ?? false;
}

/// Split-panel auth screen. A solid brand panel and a white form panel share
/// the screen along its long axis (side-by-side on wide layouts, stacked on
/// phones). Switching between Sign In and Sign Up is a three-step move on the
/// panel: it **expands until it covers the whole screen**, both sides swap
/// while hidden, then it **retracts to the opposite half** on a physics spring.
class SplitAuthScreen extends StatefulWidget {
  const SplitAuthScreen({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  State<SplitAuthScreen> createState() => _SplitAuthScreenState();
}

class _SplitAuthScreenState extends State<SplitAuthScreen>
    with SingleTickerProviderStateMixin {
  /// 0 = panel resting on one half, 1 = panel covering the whole screen.
  late final AnimationController _cover = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late AuthMode _mode = widget.initialMode;

  /// Whether the panel currently rests on the right/bottom half. Flipped
  /// between the expand and retract halves of a switch.
  late bool _panelOnRight = _mode == AuthMode.signUp;

  bool _busy = false;
  StreamSubscription<dynamic>? _authSub;

  @override
  void initState() {
    super.initState();
    try {
      _authSub = AuthService.onAuthStateChange.listen((state) {
        if (state.event == AuthChangeEvent.signedIn &&
            AuthService.isSignedIn &&
            mounted) {
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
    _cover.dispose();
    super.dispose();
  }

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  Future<void> _switch(AuthMode next) async {
    if (_busy || next == _mode) return;
    _busy = true;
    FocusScope.of(context).unfocus();

    if (_reduceMotion) {
      setState(() {
        _mode = next;
        _panelOnRight = next == AuthMode.signUp;
      });
      _busy = false;
      return;
    }

    // 1 — grow the panel until it covers the whole screen.
    await _cover.animateTo(1, curve: Curves.easeInOutCubic);
    if (!mounted) return;

    // 2 — swap both sides while they're completely hidden.
    setState(() => _mode = next);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    _panelOnRight = next == AuthMode.signUp;

    // 3 — retract to the opposite half on the characterful spring.
    await _cover.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 100, damping: 20),
        1,
        0,
        0,
      ),
    );
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final wide = media.width >= 700;
    // On a phone the panel is a banner, not a true half — the form needs the room.
    final restFrac = wide ? 0.5 : 0.38;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --- Form layer: both forms mounted, faded by which is active. ---
          _FormSide(
            wide: wide,
            restFrac: restFrac,
            side: AuthMode.signUp,
            active: _mode == AuthMode.signUp,
            child:
                const _AuthForm(key: ValueKey('signup'), mode: AuthMode.signUp),
          ),
          _FormSide(
            wide: wide,
            restFrac: restFrac,
            side: AuthMode.signIn,
            active: _mode == AuthMode.signIn,
            child:
                const _AuthForm(key: ValueKey('signin'), mode: AuthMode.signIn),
          ),

          // --- Expanding brand panel. ---
          AnimatedBuilder(
            animation: _cover,
            builder: (context, _) {
              final t = _cover.value.clamp(0.0, 1.0);
              final axis = wide ? media.width : media.height;
              final solid = lerpDouble(axis * restFrac, axis, t)!;
              final span = solid + _kCurveDepth;

              return Positioned(
                left: wide ? (_panelOnRight ? null : 0) : 0,
                right: wide ? (_panelOnRight ? 0 : null) : 0,
                top: wide ? 0 : (_panelOnRight ? null : 0),
                bottom: wide ? 0 : (_panelOnRight ? 0 : null),
                width: wide ? span : null,
                height: wide ? null : span,
                child: ClipPath(
                  clipper: _PanelClipper(
                    wide: wide,
                    panelOnRight: _panelOnRight,
                  ),
                  child: ColoredBox(
                    color: AppColors.royalBlue,
                    child: _PanelContent(
                      wide: wide,
                      mode: _mode,
                      onSwitch: () => _switch(
                        _mode == AuthMode.signIn
                            ? AuthMode.signUp
                            : AuthMode.signIn,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // --- Close affordance. ---
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4,
            left: 4,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                // The panel covers the top-left corner in sign-in mode.
                color: _panelOnRight ? AppColors.textSecondary : Colors.white,
              ),
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
  _PanelClipper({required this.wide, required this.panelOnRight});

  final bool wide;
  final bool panelOnRight;

  @override
  Path getClip(Size size) {
    final p = Path();
    final w = size.width;
    final h = size.height;
    const d = _kCurveDepth;

    if (wide && panelOnRight) {
      // Flat right edge, curved left edge bulging toward the form.
      p.moveTo(w, 0);
      p.lineTo(d, 0);
      p.cubicTo(-6, h * 0.28, -6, h * 0.72, d, h);
      p.lineTo(w, h);
    } else if (wide) {
      // Flat left edge, curved right edge.
      p.moveTo(0, 0);
      p.lineTo(w - d, 0);
      p.cubicTo(w + 6, h * 0.28, w + 6, h * 0.72, w - d, h);
      p.lineTo(0, h);
    } else if (panelOnRight) {
      // Panel on the bottom: flat bottom edge, curved top edge.
      p.moveTo(0, h);
      p.lineTo(0, d);
      p.cubicTo(w * 0.28, -6, w * 0.72, -6, w, d);
      p.lineTo(w, h);
    } else {
      // Panel on the top: flat top edge, curved bottom edge.
      p.moveTo(0, 0);
      p.lineTo(0, h - d);
      p.cubicTo(w * 0.28, h + 6, w * 0.72, h + 6, w, h - d);
      p.lineTo(w, 0);
    }
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_PanelClipper old) =>
      old.wide != wide || old.panelOnRight != panelOnRight;
}

class _PanelContent extends StatelessWidget {
  const _PanelContent({
    required this.wide,
    required this.mode,
    required this.onSwitch,
  });

  final bool wide;
  final AuthMode mode;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final signIn = mode == AuthMode.signIn;
    // The panel copy invites you to the *other* side.
    final title = signIn ? 'New here?' : 'One of us?';
    final body = signIn
        ? 'Join us today and discover a world of possibilities. Create your account in seconds!'
        : 'Welcome back! Sign in to continue your journey with us.';
    final cta = signIn ? 'Sign up' : 'Sign in';

    return SafeArea(
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Padding(
            key: ValueKey(mode),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 28),
                  _GhostButton(label: cta, onPressed: onSwitch),
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
/*  Form side                                                          */
/* ------------------------------------------------------------------ */

class _FormSide extends StatelessWidget {
  const _FormSide({
    required this.wide,
    required this.restFrac,
    required this.side,
    required this.active,
    required this.child,
  });

  final bool wide;
  final double restFrac;

  /// Which mode's form this is. Sign Up lives on the left/top half, Sign In on
  /// the right/bottom half — the panel covers whichever one is inactive.
  final AuthMode side;
  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onLeftOrTop = side == AuthMode.signUp;
    final media = MediaQuery.sizeOf(context);
    // Keep the fields clear of the curved lip on the edge facing the panel.
    const lip = _kCurveDepth - 8;
    final pad = EdgeInsets.fromLTRB(
      wide && !onLeftOrTop ? lip : 24,
      !wide && !onLeftOrTop ? lip : 24,
      wide && onLeftOrTop ? lip : 24,
      !wide && onLeftOrTop ? lip : 24,
    );

    return Positioned(
      left: wide ? (onLeftOrTop ? 0 : null) : 0,
      right: wide ? (onLeftOrTop ? null : 0) : 0,
      top: wide ? 0 : (onLeftOrTop ? 0 : null),
      bottom: wide ? 0 : (onLeftOrTop ? null : 0),
      width: wide ? media.width * (1 - restFrac) : null,
      height: wide ? null : media.height * (1 - restFrac),
      child: IgnorePointer(
        ignoring: !active,
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: SafeArea(
            child: Padding(
              padding: pad,
              child: Align(
                alignment: wide ? Alignment.center : Alignment.topCenter,
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/*  The forms                                                          */
/* ------------------------------------------------------------------ */

class _AuthForm extends StatefulWidget {
  const _AuthForm({super.key, required this.mode});

  final AuthMode mode;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _working = false;
  bool _googleWorking = false;
  String? _error;
  String? _notice;

  bool get _isSignUp => widget.mode == AuthMode.signUp;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!AuthService.isValidEmail(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (_isSignUp && _username.text.trim().isEmpty) {
      setState(() => _error = 'Pick a username.');
      return;
    }
    setState(() {
      _working = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_isSignUp) {
        final res = await AuthService.signUpWithPassword(
          email: email,
          password: password,
          data: {'username': _username.text.trim()},
        );
        // A signed-in session pops the screen via the auth-state listener.
        if (res.session == null && mounted) {
          setState(() {
            _working = false;
            _notice = 'Check your email to confirm your account, then sign in.';
          });
        }
      } else {
        await AuthService.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _working = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong. Try again.';
          _working = false;
        });
      }
    }
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isSignUp ? 'Sign up' : 'Sign in',
            textAlign: TextAlign.center,
            style: text.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          if (_isSignUp) ...[
            _AuthField(
              controller: _username,
              hint: 'Username',
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
          ],
          _AuthField(
            controller: _email,
            hint: 'Email',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          _AuthField(
            controller: _password,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
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
            label: _isSignUp ? 'Sign up' : 'Login',
            loading: _working,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
          _GoogleButton(loading: _googleWorking, onPressed: _google),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/*  Controls                                                           */
/* ------------------------------------------------------------------ */

class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  late bool _hidden = widget.obscure;

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
          Icon(widget.icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              obscureText: _hidden,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              cursorColor: AppColors.royalBlue,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
          if (widget.obscure)
            GestureDetector(
              onTap: () => setState(() => _hidden = !_hidden),
              child: Icon(
                _hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary,
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

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white70),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            fontSize: 12,
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
