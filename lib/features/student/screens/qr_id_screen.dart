import 'package:flutter/material.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class QrIdScreen extends StatelessWidget {
  const QrIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'My QR Code',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _QrCard(),
          SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.badge_outlined),
                  title: Text('Student ID'),
                  subtitle: Text('RHW-20481'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.schedule_outlined),
                  title: Text('Updated'),
                  subtitle: Text('Just now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.qr_code_2, size: 140),
            SizedBox(height: 16),
            Text(
              'Jordan Hawke',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Present this code at campus checkout points.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
