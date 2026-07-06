import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminTransactionDetailsScreen extends StatelessWidget {
  const AdminTransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text('Completed', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const Text('TXN-001', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFFFFF0F0),
                          child: Text('A', style: TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 8),
                        Text('From', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('Alex Johnson', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Color(0xFFC8102E)),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFFFFF0F0),
                          child: Icon(Icons.store, color: Color(0xFFC8102E)),
                        ),
                        SizedBox(height: 8),
                        Text('To', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('Red Hawk Cafe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transaction Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _detailRow('Amount', '\$12.50'),
                  _detailRow('Date', 'May 27, 2026'),
                  _detailRow('Time', '3:45 PM'),
                  _detailRow('Payment Type', 'Red Hawk Dollars'),
                  _detailRow('Points Earned', '12 pts'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Action Logs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _logRow('3:45:01 PM', 'Payment initiated'),
                  _logRow('3:45:03 PM', 'Payment processed'),
                  _logRow('3:45:05 PM', 'Receipt sent to customer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _logRow(String time, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFFC8102E)),
          const SizedBox(width: 10),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 10),
          Text(action, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
