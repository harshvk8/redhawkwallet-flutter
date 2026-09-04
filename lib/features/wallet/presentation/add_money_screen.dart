import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/stripe_service.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountController = TextEditingController();
  int _selectedMethod = 0;
  bool _processing = false;
  final _quickAmounts = [10, 25, 50, 100];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addFunds() async {
    if (_selectedMethod != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bank transfer (ACH) is coming soon — pay by card for now.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // flutter_stripe has no web implementation — Stripe.instance is never
    // initialized there (see main.dart), so StripeService.addFunds would
    // throw a raw MissingPluginException instead of failing cleanly.
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adding funds isn\'t available on web yet — use the iOS or Android app.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _processing = true);
    try {
      await StripeService().addFunds(amount: _parsedAmount);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment received — funds will appear in your wallet shortly.'),
          backgroundColor: Color(0xFF8B1A2E),
        ),
      );
      context.pop();
    } on AddFundsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  double get _parsedAmount {
    return double.tryParse(_amountController.text) ?? 0.0;
  }

  String get _feeEstimate {
    final amount = _parsedAmount;
    if (amount <= 0) return '\$0.00';
    final fee = _selectedMethod == 0 ? amount * 0.029 + 0.30 : 0.0;
    return '\$${fee.toStringAsFixed(2)}';
  }

  String get _totalEstimate {
    final amount = _parsedAmount;
    if (amount <= 0) return '\$0.00';
    final fee = _selectedMethod == 0 ? amount * 0.029 + 0.30 : 0.0;
    return '\$${(amount + fee).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Money'),
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountCard(cs),
            const SizedBox(height: 16),
            _buildMethodCard(cs),
            const SizedBox(height: 16),
            if (_parsedAmount > 0) ...[
              _buildSummaryCard(cs),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_parsedAmount >= 1.0 && !_processing) ? _addFunds : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: cs.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _processing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _parsedAmount >= 1.0 ? 'Review Payment · $_totalEstimate' : 'Enter an amount',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Sandbox mode — Stripe test cards only, no real money moves. Minimum deposit: \$1.00.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B1A2E), Color(0xFFC8102E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How much?', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('\$', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 36, fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                    // The app-wide InputDecorationTheme defaults every field to
                    // filled: true with a near-white fill in light mode, which
                    // was painting an opaque patch behind this field and
                    // swallowing the white digits. This field sits directly on
                    // the maroon gradient card, so it must stay unfilled.
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: _quickAmounts.map((amount) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _amountController.text = amount.toString()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _parsedAmount == amount.toDouble()
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '\$$amount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _parsedAmount == amount.toDouble()
                              ? const Color(0xFF8B1A2E)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
        const SizedBox(height: 10),
        _paymentMethod(0, Icons.credit_card, 'Debit or Credit Card', 'Visa, Mastercard, Amex · 2.9% + \$0.30 fee', cs),
        const SizedBox(height: 10),
        _paymentMethod(1, Icons.account_balance, 'Bank Transfer (ACH)', 'Free · 1–3 business days', cs),
      ],
    );
  }

  Widget _paymentMethod(int index, IconData icon, String title, String subtitle, ColorScheme cs) {
    final selected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMethod = index;
        if (_parsedAmount > 0) setState(() {});
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF8B1A2E) : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF8B1A2E) : cs.onSurfaceVariant, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: selected ? const Color(0xFF8B1A2E) : cs.onSurface)),
                  Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Color(0xFF8B1A2E)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme cs) {
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
          Text('Payment Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 10),
          _row('Amount', '\$${_parsedAmount.toStringAsFixed(2)}', cs),
          _row('Processing fee', _feeEstimate, cs),
          Divider(color: cs.outlineVariant, height: 20),
          _row('Total charged', _totalEstimate, cs, bold: true),
          const SizedBox(height: 6),
          _row('Added to wallet', '\$${_parsedAmount.toStringAsFixed(2)}', cs, color: Colors.green),
        ],
      ),
    );
  }

  Widget _row(String label, String value, ColorScheme cs, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: color ?? cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
