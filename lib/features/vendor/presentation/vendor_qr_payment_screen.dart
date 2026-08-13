import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../wallet/models/payment_request_model.dart';

class VendorQrPaymentScreen extends StatefulWidget {
  const VendorQrPaymentScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<VendorQrPaymentScreen> createState() => _VendorQrPaymentScreenState();
}

class _VendorQrPaymentScreenState extends State<VendorQrPaymentScreen> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await FirebaseFirestore.instance.collection('paymentRequests').doc(widget.requestId).update({
        'status': 'cancelled',
      });
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not cancel: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('paymentRequests').doc(widget.requestId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('This request no longer exists.'));
          }

          final request = PaymentRequestModel.fromFirestore(snapshot.data!);
          final isPending = request.status == 'pending';
          final isPaid = request.status == 'paid';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Show this QR to the customer', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: isPaid ? Colors.green : colorScheme.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                      color: (isPaid ? Colors.green : colorScheme.primary).withValues(alpha: 0.08),
                    ),
                    child: Center(
                      child: isPaid
                          ? const Icon(Icons.check_circle, size: 120, color: Colors.green)
                          : QrImageView(
                              data: request.qrPayload,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(color: Color(0xFFC8102E)),
                              dataModuleStyle: const QrDataModuleStyle(color: Color(0xFFC8102E)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '\$${request.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.note.isNotEmpty ? request.note : request.discount,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(request.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel(request), style: TextStyle(color: _statusColor(request.status), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (isPending && !_cancelling) ? _cancel : null,
                          icon: _cancelling
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/vendor'),
                          icon: const Icon(Icons.check),
                          label: const Text('Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
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
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(PaymentRequestModel request) {
    switch (request.status) {
      case 'paid':
        return 'Paid by ${request.studentName ?? 'student'}';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Waiting for payment...';
    }
  }
}
