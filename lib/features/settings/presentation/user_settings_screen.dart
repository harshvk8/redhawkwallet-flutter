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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(context, 'Account', [
              _settingsTile(Icons.person_outline, 'Edit Profile', onTap: () {}),
              _settingsTile(Icons.lock_outline, 'Change Password', onTap: () => context.push('/settings/security')),
              _settingsTile(Icons.school_outlined, 'University Verification', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Preferences', [
              _settingsTileSwitch(Icons.notifications_none, 'Notifications', notificationsEnabled, (val) => setState(() => notificationsEnabled = val)),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Legal', [
              _settingsTile(Icons.article_outlined, 'Terms of Service', onTap: () => context.push('/terms')),
              _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () => context.push('/privacy')),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Privacy & Security', [
              _settingsTile(Icons.security_outlined, 'Security Settings', onTap: () => context.push('/settings/security')),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Support', [
              _settingsTile(Icons.help_outline, 'Help & Support', onTap: () {}),
              _settingsTile(Icons.info_outline, 'About Red Hawk Wallet', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Color(0xFF8B1A2E)),
                label: const Text('Logout', style: TextStyle(color: Color(0xFF8B1A2E), fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF8B1A2E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Red Hawk Wallet v1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            Text('Demo Mode • Real payments coming soon', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (title == 'Preferences') ...[
                  Text(
                    'Dark Mode',
                    style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeNotifier.instance,
                    builder: (context, mode, _) {
                      return Switch.adaptive(
                        value: mode == ThemeMode.dark,
                        onChanged: (value) {
                          ThemeNotifier.instance.value = value ? ThemeMode.dark : ThemeMode.light;
                        },
                        activeThumbColor: colorScheme.primary,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          ...children.asMap().entries.map((e) => Column(
            children: [
              if (e.key > 0) Divider(height: 1, color: colorScheme.outlineVariant),
              e.value,
            ],
          )),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String label, {required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
      onTap: onTap,
    );
  }

  Widget _settingsTileSwitch(IconData icon, String label, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: Theme.of(context).colorScheme.primary),
    );
  }
}