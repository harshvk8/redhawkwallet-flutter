import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/wallet_balance_type.dart';

class UserWalletScreen extends StatelessWidget {
  const UserWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('My Wallet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Wallet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Red Hawk Dollars updates in real time.', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _actionButton(context, Icons.send, 'Send Money', '/wallet/send')),
                const SizedBox(width: 10),
                Expanded(child: _actionButton(context, Icons.qr_code_2, 'Receive', '/wallet/receive')),
                const SizedBox(width: 10),
                Expanded(child: _actionButton(context, Icons.storefront_outlined, 'Pay Vendor', '/wallet/pay-vendor')),
              ],
            ),
            const SizedBox(height: 18),
            if (uid == null)
              Text('Not signed in.', style: TextStyle(color: colorScheme.onSurfaceVariant))
            else
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('wallets').doc(uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: LinearProgressIndicator());
                  }
                  final walletData = snapshot.data?.data() as Map<String, dynamic>?;
                  final points = (walletData?['points'] as num?)?.toInt() ?? 0;
                  return Column(
                    children: [
                      ...WalletBalanceType.values.map((card) => _balanceCard(
                            theme,
                            colorScheme,
                            name: card.label,
                            type: card.type,
                            color: card.color,
                            icon: card.icon,
                            value: card.format(walletData),
                          )),
                      // Points is shown here on the Wallet screen only — it's
                      // not part of WalletBalanceType, which is also used to
                      // populate the dashboard's balance picker, and Points
                      // already has its own dedicated screen at /rewards.
                      _balanceCard(
                        theme,
                        colorScheme,
                        name: 'Points',
                        type: 'Rewards',
                        color: Colors.amber,
                        icon: Icons.stars,
                        value: '$points pts',
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Red Hawk Dollars reflects real transfers. Flex Dollars, Bonus Dollars, and Meal Swipes are not issued yet.',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String name,
    required String type,
    required Color color,
    required IconData icon,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text(type, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, String route) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(route),
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}