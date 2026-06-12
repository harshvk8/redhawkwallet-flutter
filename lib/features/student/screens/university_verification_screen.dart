import 'package:flutter/material.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class UniversityVerificationScreen extends StatelessWidget {
  const UniversityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'University Verification',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _VerificationBanner(),
          SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.alternate_email),
                  title: Text('University email'),
                  subtitle: Text('jordan.hawke@redhawks.edu'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.verified_outlined),
                  title: Text('Verification status'),
                  subtitle: Text('Verified for campus wallet access'),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Demo verification timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Email submitted'),
                  subtitle: Text('name@redhawks.edu'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('University match found'),
                  subtitle: Text('Red Hawk University'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Wallet unlocked'),
                  subtitle: Text('Campus features enabled'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.tertiaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.verified_user_outlined, size: 80),
            SizedBox(height: 12),
            Text(
              'University Verification',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Demo verification data is shown here so the screen is usable before the real flow is connected.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
