import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'Account Profile',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push('/verify'),
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Open University Verification'),
          ),
          const SizedBox(height: 24),
          Text(
            'Profile Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.badge_outlined),
                  title: Text('Student ID'),
                  subtitle: Text('RHW-20481'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('University'),
                  subtitle: Text('Red Hawk University'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.mail_outline),
                  title: Text('University email'),
                  subtitle: Text('jordan.hawke@redhawks.edu'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jordan Hawke',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text('Computer Science · Class of 2027'),
                  SizedBox(height: 4),
                  Text('Red Hawk Wallet member since 2025'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
