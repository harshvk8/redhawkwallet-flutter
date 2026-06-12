import 'package:flutter/material.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'Scan QR Code',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _ScannerPreview(),
          SizedBox(height: 24),
          Text(
            'Recent scan targets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storefront_outlined),
                  title: Text('Campus Cafe'),
                  subtitle: Text('Accepted payment QR'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.local_mall_outlined),
                  title: Text('Bookstore'),
                  subtitle: Text('Balance top-up'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerPreview extends StatelessWidget {
  const _ScannerPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner, size: 120),
            SizedBox(height: 16),
            Text(
              'Camera preview unavailable in demo mode',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'The live scanner will be connected later. This placeholder keeps the screen functional right now.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
