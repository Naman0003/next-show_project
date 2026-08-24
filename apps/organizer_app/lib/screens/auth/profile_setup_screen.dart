// lib/screens/auth/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

/// Shown once after first login when the user has no full_name set.
/// Saves full_name to the profiles table, then calls [onComplete].
class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const ProfileSetupScreen({super.key, required this.onComplete});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;
  String? _errorText;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      final userId = NextShowSupabaseClient.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not signed in');

      await NextShowSupabaseClient.client.from('profiles').update({
        'full_name': _nameController.text.trim(),
      }).eq('id', userId);

      if (mounted) widget.onComplete();
    } catch (e) {
      setState(() => _errorText = 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const NSLogo(fontSize: 36),
                const SizedBox(height: 32),
                Text(
                  'Complete Your Profile',
                  style: NSTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us your name so admins and your team can identify your account.',
                  style: NSTextStyles.bodyMedium
                      .copyWith(color: NSColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Your Full Name',
                    hintText: 'e.g. Alex Johnson',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  onFieldSubmitted: (_) => _save(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    style: NSTextStyles.bodySmall
                        .copyWith(color: NSColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 28),
                NSPrimaryButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
