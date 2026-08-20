// lib/widgets/account_menu_button.dart
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../services/auth_service.dart';

/// Account icon for an AppBar's actions. Shows sign-in state and opens
/// either the sign-out sheet or the sign-in flow, depending on state.
class AccountMenuButton extends StatefulWidget {
  const AccountMenuButton({Key? key}) : super(key: key);

  @override
  State<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<AccountMenuButton> {
  Future<void> _handleTap() async {
    if (AuthService.isSignedIn) {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Signed in as", style: Theme.of(context).textTheme.bodySmall),
                Text(AuthService.currentUser?.email ?? '', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await AuthService.signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                        setState(() {});
                      }
                    },
                    child: const Text("Sign out"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final signedIn = await ensureSignedIn(context);
      if (signedIn && mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(AuthService.isSignedIn ? Icons.account_circle : Icons.account_circle_outlined),
      tooltip: AuthService.isSignedIn ? AuthService.currentUser?.email : "Sign in",
      onPressed: _handleTap,
    );
  }
}
