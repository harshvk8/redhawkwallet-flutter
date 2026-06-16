import 'package:flutter/material.dart';
import 'package:redhawkwallet_flutter/core/data/demo_identity.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_state_view.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class QrIdScreen extends StatefulWidget {
  const QrIdScreen({super.key});

  @override
  State<QrIdScreen> createState() => _QrIdScreenState();
}

class _QrIdScreenState extends State<QrIdScreen> {
  DemoScreenStatus _status = DemoScreenStatus.loading;

  @override
  void initState() {
    super.initState();
    _loadQrId();
  }

  Future<void> _loadQrId() async {
    setState(() {
      _status = DemoScreenStatus.loading;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    setState(() {
      _status = DemoIdentity.displayName.trim().isEmpty
          ? DemoScreenStatus.empty
          : DemoScreenStatus.ready;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'My QR Code',
      body: DemoScreenStateView(
        status: _status,
        onRetry: _loadQrId,
        emptyIcon: Icons.qr_code_2_outlined,
        emptyTitle: 'No QR ID yet',
        emptyMessage: 'Set a student name to generate the demo QR ID.',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            _QrCard(),
            const SizedBox(height: 20),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.qr_code_2_outlined, size: 140),
            const SizedBox(height: 16),
            Text(
              DemoIdentity.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Present this code at campus checkout points.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
