import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../wallet/models/payment_request_model.dart';

class VendorQrPaymentScreen extends StatefulWidget {
  const VendorQrPaymentScreen({super.key});

  @override
  State<VendorQrPaymentScreen> createState() => _VendorQrPaymentScreenState();
}

class _VendorQrPaymentScreenState extends State<VendorQrPaymentScreen> {
  bool _navigated = false;

  Future<void> _cancelRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('paymentRequests')
          .doc(requestId)
          .update({'status': 'cancelled'});
    } catch (_) {
      // Best-effort: leaving the screen is enough even if this fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final requestId = extra?['requestId'] as String?;

    if (requestId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment QR Code')),
        body: const Center(child: Text('Missing payment request.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment QR Code')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('paymentRequests').doc(requestId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('This payment request no longer exists.'));
          }

          final request = PaymentRequestModel.fromFirestore(snapshot.data!);

          if (request.status == 'paid' && !_navigated) {
            _navigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.pushReplacement('/vendor/payment-received', extra: {
                'amount': request.amount,
                'studentName': request.studentName ?? 'Student',
                'transactionId': request.transactionId ?? request.id,
                'paidAt': request.paidAt ?? DateTime.now(),
                'note': request.note,
              });
            });
          }

          return Center(
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
                      border: Border.all(color: cs.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                      color: cs.primary.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Icon(Icons.qr_code_2, size: 160, color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('\$${request.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: cs.primary)),
                  if (request.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(request.note, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                  if (request.discount != 'No Discount') ...[
                    const SizedBox(height: 4),
                    Text(request.discount, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: request.status == 'cancelled' ? Colors.red.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status == 'cancelled' ? 'Request cancelled' : 'Waiting for payment...',
                      style: TextStyle(
                        color: request.status == 'cancelled' ? Colors.red.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (request.status == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _cancelRequest(request.id);
                          if (context.mounted) context.pop();
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    )
                  else if (request.status == 'cancelled')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
