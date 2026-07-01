import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountController = TextEditingController();
  int _selectedPreset = -1;
  int _selectedMethod = 0;
  bool _loading = false;

  static const _presets = [10, 25, 50, 100];
  static const _methods = [
    {'icon': Icons.credit_card, 'label': 'Debit / Credit Card', 'sub': 'Visa, Mastercard, Amex'},
    {'icon': Icons.account_balance, 'label': 'Bank Account', 'sub': 'ACH transfer (1–2 days)'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectPreset(int i) {
    setState(() {
      _selectedPreset = i;
      _amountController.text = _presets[i].toString();
    });
  }

  Future<void> _addFunds() async {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount'), backgroundColor: Colors.orange),
      );
      return;
    }
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (amount < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum top-up is \$5.00'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stripe payment flow launching — \$$text will be added (sandbox in Week 3)'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFill = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9F9);
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(cs),
            const SizedBox(height: 24),
            Text('Enter Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 10),
            _buildAmountInput(inputFill, borderColor, cs, isDark),
            const SizedBox(height: 14),
            Row(
              children: _presets.asMap().entries.map((entry) {
                final i = entry.key;
                final preset = entry.value;
                final selected = _selectedPreset == i;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < _presets.length - 1 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => _selectPreset(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? cs.primary : cs.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? cs.primary : Colors.grey.shade300),
                        ),
                        child: Text(
                          '\$$preset',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: selected ? Colors.white : cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 10),
            ..._methods.asMap().entries.map((entry) {
              final i = entry.key;
              final method = entry.value;
              final selected = _selectedMethod == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedMethod = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary.withValues(alpha: 0.06) : cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? cs.primary : Colors.grey.shade200, width: selected ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected ? cs.primary.withValues(alpha: 0.12) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(method['icon'] as IconData, color: selected ? cs.primary : Colors.grey, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(method['label'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                            Text(method['sub'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (selected) Icon(Icons.check_circle, color: cs.primary, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            _buildTestCardHint(cs),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _addFunds,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_card),
                label: const Text('Add Funds', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: cs.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Cancel', style: TextStyle(color: cs.primary, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payments are processed securely via Stripe. Red Hawk Wallet does not store card details. This is a sandbox demo — no real charges.',
              style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45), height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Current Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          const Text('\$24.50', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Text('Red Hawk Dollars', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(Color fill, Color border, ColorScheme cs, bool isDark) {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
      onChanged: (_) => setState(() => _selectedPreset = -1),
      decoration: InputDecoration(
        prefixText: '\$ ',
        prefixStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: cs.primary),
        hintText: '0.00',
        hintStyle: TextStyle(fontSize: 28, color: cs.onSurface.withValues(alpha: 0.25)),
        filled: true,
        fillColor: fill,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildTestCardHint(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sandbox Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: '4242424242424242'));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test card number copied')));
                  },
                  child: const Text(
                    'Use test card 4242 4242 4242 4242 (tap to copy) — any future expiry, any CVC.',
                    style: TextStyle(fontSize: 12, color: Colors.blue, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
