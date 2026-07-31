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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection('Account', [
              _settingsTile(Icons.person_outline, 'Edit Profile', onTap: () {}),
              _settingsTile(Icons.lock_outline, 'Change Password', onTap: () => context.push('/settings/security')),
              _settingsTile(Icons.school_outlined, 'University Verification', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _buildSection('Preferences', [
              _settingsTileSwitch(Icons.notifications_none, 'Notifications', notificationsEnabled, (val) => setState(() => notificationsEnabled = val)),
              _settingsTileSwitch(
                Icons.dark_mode_outlined,
                'Dark Mode',
                ThemeNotifier.instance.isDark,
                (val) => ThemeNotifier.instance.value = val ? ThemeMode.dark : ThemeMode.light,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Privacy & Security', [
              _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
              _settingsTile(Icons.security_outlined, 'Security Settings', onTap: () => context.push('/settings/security')),
            ]),
            const SizedBox(height: 16),
            _buildSection('Support', [
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
            const Text('Red Hawk Wallet v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text('Demo Mode • Real payments coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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

  Widget _settingsTile(IconData icon, String label, {required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF8B1A2E), size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _settingsTileSwitch(IconData icon, String label, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF8B1A2E), size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF8B1A2E)),
    );
  }
}