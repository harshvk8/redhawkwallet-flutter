import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Shown wherever a student is about to pay a vendor (Pay Vendor screen, or
/// confirming a scanned vendor-payment QR) so they can see/pick which
/// account funds the payment from, and how much each currently holds. Red
/// Hawk Dollars is the only account that's actually wired to real money
/// movement — Flex Dollars and Points are surfaced here because the wallet
/// data model already has fields for them, but there's no way to add funds
/// to those balances yet, so they stay disabled until that exists.
class PaymentAccountSelector extends StatelessWidget {
  const PaymentAccountSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pay with', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (uid == null)
          _accountRow(context, Icons.account_balance_wallet, 'Red Hawk Dollars', '\$0.00', enabled: true)
        else
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('wallets').doc(uid).snapshots(),
            builder: (context, snapshot) {
              final walletData = snapshot.data?.data() as Map<String, dynamic>?;
              final balance = (walletData?['balance'] as num?)?.toDouble() ?? 0.0;
              final flexBalance = (walletData?['flexBalance'] as num?)?.toDouble() ?? 0.0;
              final points = (walletData?['points'] as num?)?.toInt() ?? 0;
              return Column(
                children: [
                  _accountRow(context, Icons.account_balance_wallet, 'Red Hawk Dollars', '\$${balance.toStringAsFixed(2)}', enabled: true),
                  const SizedBox(height: 8),
                  _accountRow(context, Icons.credit_card, 'Flex Dollars', '\$${flexBalance.toStringAsFixed(2)}', enabled: false),
                  const SizedBox(height: 8),
                  _accountRow(context, Icons.stars, 'Points', '$points pts', enabled: false),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _accountRow(BuildContext context, IconData icon, String name, String value, {required bool enabled}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled
            ? null
            : () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name is coming soon.')),
                ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text(value, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              const Spacer(),
              enabled
                  ? Icon(Icons.check_circle, color: colorScheme.primary, size: 18)
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                      child: Text('Coming soon', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
