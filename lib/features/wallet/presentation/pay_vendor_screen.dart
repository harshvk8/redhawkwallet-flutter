import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PayVendorScreen extends StatelessWidget {
  const PayVendorScreen({super.key});

  final List<Map<String, String>> recentVendors = const [
    {'name': 'Red Hawk Cafe', 'category': 'Food & Drinks', 'initial': 'R'},
    {'name': 'Campus Bookstore', 'category': 'Books & Supplies', 'initial': 'C'},
    {'name': 'Hawks Pizza', 'category': 'Food & Drinks', 'initial': 'H'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pay Vendor'),
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.push('/qr-scanner'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1A2E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scan Vendor QR Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Point your camera at vendor QR code', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF8B1A2E)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF8B1A2E), size: 36),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Search Vendor', style: TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Find vendor by name or ID', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Vendors', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...recentVendors.map((vendor) => Container(
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
                    child: Text(vendor['initial']!, style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(vendor['category']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
