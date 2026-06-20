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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code refreshed'), backgroundColor: Color(0xFF8B1A2E)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFFFF0F0),
                    child: Icon(Icons.person, color: Color(0xFF8B1A2E), size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.displayName ?? 'Student Name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'student@montclair.edu', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Verified Student', style: TextStyle(color: Color(0xFF8B1A2E), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF8B1A2E), width: 3),
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFFFF0F0),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code_2, size: 160, color: Color(0xFF8B1A2E)),
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
                    const SnackBar(content: Text('QR ID copied to clipboard'), backgroundColor: Color(0xFF8B1A2E)),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: Colors.white,
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
                icon: const Icon(Icons.refresh, color: Color(0xFF8B1A2E)),
                label: const Text('Refresh QR', style: TextStyle(color: Color(0xFF8B1A2E))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF8B1A2E)),
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
