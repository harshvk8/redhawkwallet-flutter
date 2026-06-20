import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorQrPaymentScreen extends StatelessWidget {
  const VendorQrPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final amount = extra?['amount'] as String? ?? '0.00';
    final note = extra?['note'] as String? ?? '';
    final discount = extra?['discount'] as String? ?? 'No Discount';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment QR Code'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Show this QR to the customer', style: TextStyle(fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 24),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC8102E), width: 3),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFFFF0F0),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 160, color: Color(0xFFC8102E)),
                ),
              ),
              const SizedBox(height: 24),
              Text('\$$amount', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(note, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
              if (discount != 'No Discount') ...[
                const SizedBox(height: 4),
                Text(discount, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Waiting for payment...', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR code regenerated'), backgroundColor: Color(0xFFC8102E)),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8102E),
                        foregroundColor: Colors.white,
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
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
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
