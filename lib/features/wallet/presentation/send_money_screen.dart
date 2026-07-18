import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SendMoneyScreen extends StatelessWidget {
  const SendMoneyScreen({super.key});

  final List<Map<String, String>> recentContacts = const [
    {'name': 'Alex Johnson', 'email': 'alex@montclair.edu', 'initial': 'A'},
    {'name': 'Sara Lee', 'email': 'sara@montclair.edu', 'initial': 'S'},
    {'name': 'Mike Chen', 'email': 'mike@montclair.edu', 'initial': 'M'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recent', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...recentContacts.map((contact) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFFF0F0),
                    child: Text(contact['initial']!, style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(contact['email']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            )),
            const SizedBox(height: 20),
            const Text('Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B1A2E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Note (optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'What is this for?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B1A2E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Send Money coming in MVP')),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Send', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
