import 'package:flutter/material.dart';

/// Shown wherever a student is about to pay a vendor (Pay Vendor screen, or
/// confirming a scanned vendor-payment QR) so they can see/pick which
/// account funds the payment from. Red Hawk Dollars is the only account
/// that's actually wired to real money movement — Flex Dollars and Points
/// are surfaced here because the wallet data model already has fields for
/// them, but there's no way to add funds to those balances yet, so they
/// stay disabled until that exists.
class PaymentAccountSelector extends StatelessWidget {
  const PaymentAccountSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pay with', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _accountRow(context, Icons.account_balance_wallet, 'Red Hawk Dollars', enabled: true),
        const SizedBox(height: 8),
        _accountRow(context, Icons.credit_card, 'Flex Dollars', enabled: false),
        const SizedBox(height: 8),
        _accountRow(context, Icons.stars, 'Points', enabled: false),
      ],
    );
  }

  Widget _accountRow(BuildContext context, IconData icon, String name, {required bool enabled}) {
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
