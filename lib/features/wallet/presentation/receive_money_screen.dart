import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ReceiveMoneyScreen extends StatelessWidget {
  const ReceiveMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Student Name';
    final userEmail = user?.email ?? 'student@montclair.edu';
    final walletId = user?.uid ?? 'unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Receive Money'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B1A2E), Color(0xFFC8102E)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFFFF0F0),
                        child: Icon(Icons.person, color: Color(0xFF8B1A2E), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(userEmail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Share your wallet ID or QR', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('Get paid in seconds', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _qrPreview(),
                  const SizedBox(height: 16),
                  const Text('Wallet ID', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(walletId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: walletId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet ID copied')));
                            }
                          },
                          icon: const Icon(Icons.copy, color: Color(0xFF8B1A2E)),
                          label: const Text('Copy ID', style: TextStyle(color: Color(0xFF8B1A2E))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8B1A2E)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share action is demo-only')));
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B1A2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How students can pay you', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('1. Open the wallet app', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('2. Scan this QR or copy the wallet ID', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('3. Confirm the transfer', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrPreview() {
    const pattern = [
      [1, 1, 1, 1, 0, 1, 0],
      [1, 0, 0, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 0, 1, 0, 1],
      [1, 1, 1, 1, 0, 1, 1],
      [0, 1, 0, 0, 1, 1, 0],
      [1, 1, 0, 1, 0, 0, 1],
    ];

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, 
            mainAxisSpacing: 6, 
            crossAxisSpacing: 6,
          ),
          itemCount: 49,
          itemBuilder: (context, index) {
            final row = index ~/ 7;
            final col = index % 7;
            final isDark = pattern[row][col] == 1;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF8B1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}