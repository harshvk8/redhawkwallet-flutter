import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QrIdScreen extends StatefulWidget {
  const QrIdScreen({super.key});

  @override
  State<QrIdScreen> createState() => _QrIdScreenState();
}

class _QrIdScreenState extends State<QrIdScreen> {
  String _qrId = 'RHW-2026-DEMO';

  void _refreshQr() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'DEMO';
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    setState(() => _qrId = 'RHW-${uid.substring(0, 4).toUpperCase()}-$ts');
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('QR code refreshed'), backgroundColor: cs.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Student ID'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: cs.primary, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.displayName ?? 'Student Name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'student@montclair.edu', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Verified Student', style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                      color: cs.primary.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Icon(Icons.qr_code_2, size: 160, color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Scan to verify student status', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('ID: $_qrId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: 'Red Hawk Student ID: $_qrId'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('QR ID copied to clipboard'), backgroundColor: cs.primary),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _refreshQr,
                icon: Icon(Icons.refresh, color: cs.primary),
                label: Text('Refresh QR', style: TextStyle(color: cs.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: cs.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
