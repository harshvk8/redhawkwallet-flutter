import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentReceivedScreen extends StatelessWidget {
  const PaymentReceivedScreen({super.key});

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final amount = extra?['amount'] as double? ?? 0.0;
    final studentName = extra?['studentName'] as String? ?? 'Customer';
    final transactionId = extra?['transactionId'] as String? ?? '—';
    final note = extra?['note'] as String? ?? '';
    final paidAt = extra?['paidAt'] as DateTime? ?? DateTime.now();
    final hour = paidAt.hour % 12 == 0 ? 12 : paidAt.hour % 12;
    final period = paidAt.hour >= 12 ? 'PM' : 'AM';
    final dateStr = '${paidAt.month}/${paidAt.day}/${paidAt.year}';
    final timeStr = '$hour:${_twoDigits(paidAt.minute)} $period';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Payment Received'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 72),
            ),
            const SizedBox(height: 24),
            const Text('Payment Successful', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _receiptRow('Customer', studentName),
                  _receiptRow('Transaction ID', transactionId),
                  _receiptRow('Date', dateStr),
                  _receiptRow('Time', timeStr),
                  if (note.isNotEmpty) _receiptRow('Note', note),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/vendor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8102E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/vendor/transactions'),
              child: const Text('View Transaction History', style: TextStyle(color: Color(0xFFC8102E))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
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
}
