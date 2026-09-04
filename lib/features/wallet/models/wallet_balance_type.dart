import 'package:flutter/material.dart';

/// The balance types shown on the Wallet screen and selectable on the
/// dashboard. `field` is the key each one reads on `wallets/{uid}`. Only
/// `balance` (Red Hawk Dollars) is written by anything today, via the
/// transferMoney Cloud Function — the others read as zero until a granting
/// mechanism exists for them.
enum WalletBalanceType {
  redHawkDollars('Red Hawk Dollars', 'balance', 'Debit', Color(0xFF8B1A2E), Icons.account_balance_wallet, false),
  flexDollars('Flex Dollars', 'flexBalance', 'Flex', Colors.blue, Icons.payment, false),
  bonusDollars('Bonus Dollars', 'bonusBalance', 'Bonus', Colors.green, Icons.card_giftcard, false),
  mealSwipes('Meal Swipes', 'mealSwipes', 'Meal', Colors.orange, Icons.restaurant, true);

  const WalletBalanceType(this.label, this.field, this.type, this.color, this.icon, this.isSwipes);

  final String label;
  final String field;
  final String type;
  final Color color;
  final IconData icon;
  final bool isSwipes;

  String format(Map<String, dynamic>? walletData) {
    final value = (walletData?[field] as num?)?.toDouble() ?? 0.0;
    return isSwipes ? '${value.toInt()} swipes' : '\$${value.toStringAsFixed(2)}';
  }

  static WalletBalanceType? fromName(String? name) {
    for (final type in values) {
      if (type.name == name) return type;
    }
    return null;
  }
}
