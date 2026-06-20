import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cs),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildUniversityVerification(context, cs),
                    const SizedBox(height: 16),
                    _buildSettingsSection(context, cs),
                    const SizedBox(height: 16),
                    _buildLogout(context, cs),
                    const SizedBox(height: 16),
                    _buildVersionNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      color: cs.primary,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 44),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, color: cs.primary, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'Student Name',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                FirebaseAuth.instance.currentUser?.email ?? 'student@example.com',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Normal User', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityVerification(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('University Verification', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.shield_outlined, color: Colors.grey, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                  const Text('Not Verified', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/verify'),
              icon: const Icon(Icons.email_outlined, size: 18),
              label: const Text('Add University Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verify your .edu email to unlock student discounts, campus offers, and exclusive rewards',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ColorScheme cs) {
    final settings = [
      {'icon': Icons.person_outline, 'label': 'Edit Profile', 'route': null},
      {'icon': Icons.history, 'label': 'Transaction History', 'route': '/transactions'},
      {'icon': Icons.star_outline, 'label': 'Points and Rewards', 'route': '/rewards'},
      {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
      {'icon': Icons.notifications_none, 'label': 'Notifications', 'route': null},
      {'icon': Icons.help_outline, 'label': 'Help and Support', 'route': null},
    ];

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
            child: Text('Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
          ),
          ...settings.asMap().entries.map((entry) {
            final index = entry.key;
            final setting = entry.value;
            return Column(
              children: [
                if (index > 0) Divider(height: 1, color: Colors.grey.shade100),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(setting['icon'] as IconData, color: cs.primary, size: 20),
                  ),
                  title: Text(setting['label'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () {
                    final route = setting['route'] as String?;
                    if (route != null) {
                      context.push(route);
                    } else if (setting['label'] == 'Notifications') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No new notifications')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${setting['label']} coming in MVP')),
                      );
                    }
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context, ColorScheme cs) {
    return SizedBox(
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
    );
  }

  Widget _buildVersionNote() {
    return const Column(
      children: [
        Text('Red Hawk Wallet v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 2),
        Text('Demo Mode • Real payments coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
