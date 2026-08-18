import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/theme_notifier.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildUniversityVerification(context),
                    const SizedBox(height: 16),
                    _buildSettingsSection(context),
                    const SizedBox(height: 16),
                    _buildLogout(context),
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

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, const Color(0xFFC8102E)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                tooltip: 'Back',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Stack(
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
                    child: const Icon(Icons.camera_alt, color: Color(0xFF8B1A2E), size: 16),
                  ),
                ),
              ],
            ),
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
    );
  }

  Widget _buildUniversityVerification(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('University Verification', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.shield_outlined, color: colorScheme.onSurfaceVariant, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Not Verified', style: TextStyle(fontSize: 12)),
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
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify your .edu email to unlock student discounts, campus offers, and exclusive rewards',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = [
      {'icon': Icons.person_outline, 'label': 'Edit Profile', 'route': '/profile/edit'},
      {'icon': Icons.history, 'label': 'Transaction History', 'route': '/transactions'},
      {'icon': Icons.star_outline, 'label': 'Points and Rewards', 'route': '/rewards'},
      {'icon': Icons.notifications_none, 'label': 'Notifications', 'route': '/notifications'},
      {'icon': Icons.article_outlined, 'label': 'Terms of Service', 'route': '/terms'},
      {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy Policy', 'route': '/privacy'},
      {'icon': Icons.help_outline, 'label': 'Help and Support', 'route': '/settings'},
    ];

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
                Text('Settings', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
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
            ),
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
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(setting['icon'] as IconData, color: colorScheme.primary, size: 20),
                  ),
                  title: Text(setting['label'] as String, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 20),
                  onTap: () {
                    final route = setting['route'] as String?;
                    if (route == null) return;
                    context.push(route);
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) context.go('/login');
        },
        icon: Icon(Icons.logout, color: colorScheme.primary),
        label: Text('Logout', style: TextStyle(color: colorScheme.primary, fontSize: 15)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildVersionNote() {
    return const Column(
      children: [
        Text('Red Hawk Wallet v1.0.0', style: TextStyle(fontSize: 12)),
        SizedBox(height: 2),
        Text('Demo Mode • Real payments coming soon', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
