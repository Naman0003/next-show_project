import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

/// Signing in to an account that is waiting out its 14-day deletion grace period
/// asks the user whether to restore it. Declining signs them out again.
class AccountRestoreGate extends StatefulWidget {
  const AccountRestoreGate({super.key, required this.child});

  final Widget child;

  @override
  State<AccountRestoreGate> createState() => _AccountRestoreGateState();
}

class _AccountRestoreGateState extends State<AccountRestoreGate> {
  StreamSubscription<dynamic>? _sub;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    try {
      // Fires for sign-ins and for the session restored at app start.
      _sub = AuthService.onAuthStateChange.listen((_) => _check());
    } catch (_) {
      // Supabase not initialised (widget tests): nothing to watch.
    }
    _check();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (_asking || !AuthService.isSignedIn) return;
    DateTime? pending;
    try {
      pending = await AuthService.pendingDeletion();
    } catch (_) {
      return; // offline or table unavailable: don't block the app
    }
    if (pending == null || !mounted || _asking) return;
    final when = pending;

    _asking = true;
    final restore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Restore your account?',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text('This account is scheduled for permanent deletion on '
              '${DateFormat('d MMMM y').format(when)}. Restore it to keep your '
              'tickets and saved data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Sign out',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restore account',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );

    String? message;
    try {
      if (restore == true) {
        await AuthService.restoreAccount();
        message = 'Welcome back! Your account has been restored.';
      } else {
        await AuthService.signOut();
      }
    } catch (_) {
      message = "Couldn't restore your account. Please try again.";
      await AuthService.signOut().catchError((_) {});
    }
    _asking = false;
    if (message != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
