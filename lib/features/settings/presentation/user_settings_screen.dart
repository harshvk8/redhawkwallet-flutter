import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_notifier.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  bool notificationsEnabled = true;
  bool get darkModeEnabled => ThemeNotifier.instance.isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection('Account', [
              _settingsTile(Icons.person_outline, 'Edit Profile', cs, onTap: () => context.push('/profile')),
              _settingsTile(Icons.lock_outline, 'Change Password', cs, onTap: () {}),
              _settingsTile(Icons.school_outlined, 'University Verification', cs, onTap: () => context.push('/verify')),
            ], cs),
            const SizedBox(height: 16),
            _buildSection('Preferences', [
              _settingsTileSwitch(Icons.notifications_none, 'Notifications', notificationsEnabled, (val) => setState(() => notificationsEnabled = val), cs),
              _settingsTileSwitch(Icons.dark_mode_outlined, 'Dark Mode (Coming Soon)', darkModeEnabled, (val) {
                ThemeNotifier.instance.value = val ? ThemeMode.dark : ThemeMode.light;
                setState(() {});
              }, cs),
            ], cs),
            const SizedBox(height: 16),
            _buildSection('Privacy & Security', [
              _settingsTile(Icons.description_outlined, 'Terms of Service', cs, onTap: () => context.push('/terms')),
              _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', cs, onTap: () => context.push('/privacy')),
              _settingsTile(Icons.security_outlined, 'Security Settings', cs, onTap: () {}),
            ], cs),
            const SizedBox(height: 16),
            _buildSection('Support', [
              _settingsTile(Icons.help_outline, 'Help & Support', cs, onTap: () {}),
              _settingsTile(Icons.info_outline, 'About Red Hawk Wallet', cs, onTap: () {}),
            ], cs),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: Icon(Icons.logout, color: cs.primary),
                label: Text('Logout', style: TextStyle(color: cs.primary, fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: cs.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Red Hawk Wallet v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text('Demo Mode • Real payments coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ...children.asMap().entries.map((e) => Column(
            children: [
              if (e.key > 0) Divider(height: 1, color: Colors.grey.shade100),
              e.value,
            ],
          )),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String label, ColorScheme cs, {required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(label, style: TextStyle(fontSize: 14, color: cs.onSurface)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _settingsTileSwitch(IconData icon, String label, bool value, Function(bool) onChanged, ColorScheme cs) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(label, style: TextStyle(fontSize: 14, color: cs.onSurface)),
      trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: cs.primary),
    );
  }
}
