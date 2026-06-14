import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redhawkwallet_flutter/core/data/demo_identity.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_state_view.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  String get _displayName => DemoIdentity.displayName;
  DemoScreenStatus _status = DemoScreenStatus.loading;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _status = DemoScreenStatus.loading;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    setState(() {
      _status = _displayName.trim().isEmpty
          ? DemoScreenStatus.empty
          : DemoScreenStatus.ready;
    });
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName);

    final updatedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Full name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || updatedName == null || updatedName.isEmpty) {
      return;
    }

    setState(() {
      DemoIdentity.displayName = updatedName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'Account Profile',
      body: DemoScreenStateView(
        status: _status,
        onRetry: _loadProfile,
        emptyIcon: Icons.person_outline,
        emptyTitle: 'No profile yet',
        emptyMessage: 'Add a name to continue using the demo profile.',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            _ProfileHeader(displayName: _displayName),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _editName,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Name'),
            ),
            const SizedBox(height: 12),
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
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;

  const _ProfileHeader({required this.displayName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Computer Science · Class of 2027'),
                  const SizedBox(height: 4),
                  const Text('Red Hawk Wallet member since 2025'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
