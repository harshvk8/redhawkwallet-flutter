import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Security Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _securityToggles(),
            const SizedBox(height: 16),
            _passwordCard(),
            const SizedBox(height: 16),
            _deleteAccountCard(),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B1A2E), Color(0xFFC8102E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Protect your account', style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 6),
          Text('Security controls for the demo wallet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Biometric and 2FA are visual placeholders only.', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _securityToggles() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Authentication', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Biometric login'),
            subtitle: const Text('Fingerprint or Face ID placeholder'),
            value: _biometricEnabled,
            onChanged: (value) => setState(() => _biometricEnabled = value),
            activeThumbColor: colorScheme.primary,
          ),
          const Divider(),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Two-factor authentication'),
            subtitle: const Text('Email or SMS code placeholder'),
            value: _twoFactorEnabled,
            onChanged: (value) => setState(() => _twoFactorEnabled = value),
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _passwordCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Change Password', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _passwordField(_currentPasswordController, 'Current password'),
          const SizedBox(height: 12),
          _passwordField(_newPasswordController, 'New password'),
          const SizedBox(height: 12),
          _passwordField(_confirmPasswordController, 'Confirm new password'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo only: password update is not connected.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1A2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Update Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }

  Widget _deleteAccountCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delete Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 8),
          Text(
            'This demo entry shows where account deletion would live. No data is removed in this build.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete account?'),
                    content: const Text('This is a UI-only placeholder for demo purposes.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text('Demo only: account deletion is not connected.')),
                          );
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}