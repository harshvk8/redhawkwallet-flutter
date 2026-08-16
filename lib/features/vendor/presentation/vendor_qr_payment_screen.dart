import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorQrPaymentScreen extends StatefulWidget {
  const VendorQrPaymentScreen({super.key, this.payment});

  final Map<String, dynamic>? payment;

  @override
  State<VendorQrPaymentScreen> createState() => _VendorQrPaymentScreenState();
}

class _VendorQrPaymentScreenState extends State<VendorQrPaymentScreen> {
  int _generation = 0;

  double get _amount => (widget.payment?['amount'] as num?)?.toDouble() ?? 12.50;
  String get _note => widget.payment?['note'] as String? ?? 'Coffee order';

  void _regenerate() {
    setState(() => _generation++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New QR code generated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment QR Code'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Show this QR to the customer', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              Container(
                key: ValueKey(_generation),
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 3),
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.primary.withValues(alpha: 0.08),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 160, color: Color(0xFFC8102E)),
                ),
              ),
              const SizedBox(height: 24),
              Text('\$${_amount.toStringAsFixed(2)}', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary)),
              const SizedBox(height: 4),
              Text(_note, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Waiting for payment...', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _regenerate,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
