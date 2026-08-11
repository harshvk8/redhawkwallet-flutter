import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../wallet/models/transaction_model.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final displayName = user?.displayName?.split(' ').first ?? 'Student';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cs, displayName),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceRow(cs, uid),
                    const SizedBox(height: 20),
                    Text('Quick Access', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildQuickAccessGrid(context),
                    const SizedBox(height: 20),
                    _buildRecentTransactions(context, cs, uid),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs, String firstName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, const Color(0xFFC8102E)]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(firstName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(ColorScheme cs, String? uid) {
    if (uid == null) {
      return Row(children: [
        _staticCard('\$0.00', 'Wallet Balance', cs.primary, cs),
        const SizedBox(width: 12),
        _staticCard('0 pts', 'Points', Colors.amber.shade700, cs),
      ]);
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('wallets').doc(uid).snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final balance = (data?['balance'] as num?)?.toDouble() ?? 0.0;
        final points = (data?['points'] as num?)?.toInt() ?? 0;
        return Row(
          children: [
            _staticCard('\$${balance.toStringAsFixed(2)}', 'Wallet Balance', cs.primary, cs),
            const SizedBox(width: 12),
            _staticCard('$points pts', 'Points', Colors.amber.shade700, cs),
          ],
        );
      },
    );
  }

  Widget _staticCard(String value, String label, Color color, ColorScheme cs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final items = [
      {'icon': Icons.account_balance_wallet, 'label': 'Wallet', 'color': cs.primary, 'route': '/wallet'},
      {'icon': Icons.local_offer, 'label': 'Offers', 'color': Colors.orange, 'route': '/offers'},
      {'icon': Icons.event, 'label': 'Events', 'color': Colors.blue, 'route': '/events'},
      {'icon': Icons.qr_code, 'label': 'QR ID', 'color': Colors.purple, 'route': '/qr-id'},
      {'icon': Icons.history, 'label': 'Transactions', 'color': Colors.teal, 'route': '/transactions'},
      {'icon': Icons.person, 'label': 'Profile', 'color': Colors.green, 'route': '/account'},
      {'icon': Icons.star, 'label': 'Rewards', 'color': Colors.amber, 'route': '/rewards'},
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.grey, 'route': '/settings'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => context.push(item['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: cs.onSurface),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions(BuildContext context, ColorScheme cs, String? uid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transactions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
              TextButton(
                onPressed: () => context.push('/transactions'),
                child: Text('View All', style: TextStyle(color: cs.primary)),
              ),
            ],
          ),
          const Divider(),
          if (uid == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('Sign in to see transactions', style: TextStyle(color: Colors.grey))),
            )
          else
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('participants', arrayContains: uid)
                  .orderBy('createdAt', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text('No transactions yet', style: TextStyle(color: Colors.grey, fontSize: 13))),
                  );
                }
                return Column(
                  children: docs.map((doc) {
                    final tx = TransactionModel.fromFirestore(doc);
                    final isSent = tx.fromUid == uid;
                    final label = isSent
                        ? (tx.toName.isNotEmpty ? tx.toName : 'Payment')
                        : (tx.fromName.isNotEmpty ? tx.fromName : 'Transfer');
                    final amountStr = isSent ? '-\$${tx.amount.toStringAsFixed(2)}' : '+\$${tx.amount.toStringAsFixed(2)}';
                    final dateStr = '${tx.createdAt.month}/${tx.createdAt.day}';
                    return _txRow(label, amountStr, dateStr, isSent, cs);
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _txRow(String name, String amount, String date, bool isDebit, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: TextStyle(fontSize: 13, color: cs.onSurface), overflow: TextOverflow.ellipsis)),
          Row(
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDebit ? cs.onSurface : Colors.green)),
              const SizedBox(width: 8),
              Text(date, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
