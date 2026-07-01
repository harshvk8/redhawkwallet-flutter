import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AdminTransactionDetailsScreen extends StatelessWidget {
  const AdminTransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final id = extra?['id'] as String? ?? 'TXN-001';
    final user = extra?['user'] as String? ?? 'Alex Johnson';
    final vendor = extra?['vendor'] as String? ?? 'Red Hawk Cafe';
    final amount = extra?['amount'] as String? ?? '\$12.50';
    final status = extra?['status'] as String? ?? 'Completed';
    final date = extra?['date'] as String? ?? 'May 27, 2026';

    Color statusColor = Colors.green;
    if (status == 'Pending') statusColor = Colors.orange;
    if (status == 'Failed') statusColor = Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAmountCard(amount, status, statusColor, id, cs, context),
            const SizedBox(height: 16),
            _buildParties(user, vendor, cs),
            const SizedBox(height: 16),
            _buildTimeline(date, cs),
            const SizedBox(height: 16),
            _buildActions(context, status, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(String amount, String status, Color statusColor, String id, ColorScheme cs, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(amount, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: cs.primary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction ID copied')),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(id, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
                const SizedBox(width: 6),
                Icon(Icons.copy, size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParties(String user, String vendor, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parties', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 14),
          _partyRow(Icons.person_outline, 'Student', user, cs),
          const Divider(height: 20),
          _partyRow(Icons.storefront_outlined, 'Vendor', vendor, cs),
          const Divider(height: 20),
          _partyRow(Icons.account_balance, 'Platform Fee', '\$0.25', cs),
        ],
      ),
    );
  }

  Widget _partyRow(IconData icon, String label, String value, ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(String date, ColorScheme cs) {
    final events = [
      {'label': 'Payment Initiated', 'time': '$date — 3:44 PM', 'done': true},
      {'label': 'Funds Reserved', 'time': '$date — 3:44 PM', 'done': true},
      {'label': 'Vendor Confirmed', 'time': '$date — 3:45 PM', 'done': true},
      {'label': 'Settlement Complete', 'time': '$date — 3:45 PM', 'done': true},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 16),
          ...events.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final isDone = e['done'] as bool;
            return Padding(
              padding: EdgeInsets.only(bottom: i < events.length - 1 ? 14 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isDone ? Colors.green : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 12)
                            : null,
                      ),
                      if (i < events.length - 1)
                        Container(width: 2, height: 24, color: isDone ? Colors.green.withValues(alpha: 0.3) : Colors.grey.shade200),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      Text(e['time'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, String status, ColorScheme cs) {
    return Column(
      children: [
        if (status == 'Completed')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refund initiated — requires backend confirmation')),
                );
              },
              icon: const Icon(Icons.undo),
              label: const Text('Initiate Refund'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (status == 'Pending') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction voided')),
                );
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Void Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: cs.primary),
            label: Text('Back to Transactions', style: TextStyle(color: cs.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: cs.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
