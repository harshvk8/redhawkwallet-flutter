import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserWalletScreen extends StatelessWidget {
  const UserWalletScreen({super.key});

  final List<Map<String, dynamic>> walletCards = const [
    {'name': 'Red Hawk Dollars', 'balance': '\$0.00', 'type': 'Debit', 'color': Color(0xFF8B1A2E), 'icon': Icons.account_balance_wallet},
    {'name': 'Flex Dollars', 'balance': '\$0.00', 'type': 'Flex', 'color': Colors.blue, 'icon': Icons.payment},
    {'name': 'Bonus Dollars', 'balance': '\$0.00', 'type': 'Bonus', 'color': Colors.green, 'icon': Icons.card_giftcard},
    {'name': 'Meal Swipes', 'balance': '0 swipes', 'type': 'Meal', 'color': Colors.orange, 'icon': Icons.restaurant},
    {'name': 'Points', 'balance': '250 pts', 'type': 'Rewards', 'color': Colors.amber, 'icon': Icons.stars},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            Text('Demo Wallet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Real balances will appear after launch', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
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
            ...walletCards.map((card) => Container(
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
                      color: (card['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(card['icon'] as IconData, color: card['color'] as Color, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card['name'] as String, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(card['type'] as String, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text(card['balance'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: card['color'] as Color)),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This is a demo wallet. Real payments will be added after security and legal review.',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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