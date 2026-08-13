import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../wallet/models/payment_request_model.dart';
import '../../wallet/services/money_transfer_service.dart';
import '../../wallet/utils/qr_payloads.dart';
import '../../wallet/widgets/payment_account_selector.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _controller = MobileScannerController();
  bool _processing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    final requestId = PaymentRequestModel.requestIdFromQr(raw);
    final receiveUid = receiveUidFromQr(raw);
    final studentIdToken = studentIdTokenFromQr(raw);
    if (requestId == null && receiveUid == null && studentIdToken == null) return;

    setState(() => _processing = true);
    await _controller.stop();
    try {
      if (requestId != null) {
        await _handlePaymentRequestQr(requestId);
      } else if (receiveUid != null) {
        await _handleReceiveQr(receiveUid);
      } else if (studentIdToken != null) {
        await _handleStudentIdQr(studentIdToken);
      }
    } catch (e) {
      _showMessage('Could not read that code: $e', Colors.red);
    } finally {
      if (mounted) {
        await _controller.start();
        setState(() => _processing = false);
      }
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _handlePaymentRequestQr(String requestId) async {
    final doc = await FirebaseFirestore.instance.collection('paymentRequests').doc(requestId).get();
    if (!doc.exists) {
      _showMessage('That payment request no longer exists.', Colors.orange);
      return;
    }
    final request = PaymentRequestModel.fromFirestore(doc);
    if (request.status != 'pending') {
      _showMessage('That payment request is no longer available.', Colors.orange);
      return;
    }
    await _confirmAndPayVendor(request);
  }

  Future<void> _handleReceiveQr(String uid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == currentUid) {
      _showMessage("That's your own QR code.", Colors.orange);
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) {
      _showMessage('That account could not be found.', Colors.orange);
      return;
    }
    final data = doc.data()!;
    final role = data['role'] as String? ?? '';
    if (role != 'normal_user' && role != 'verified_student') {
      _showMessage('You can only send money via QR to another student.', Colors.orange);
      return;
    }
    final name = (data['name'] as String?) ?? 'this student';
    await _confirmAndSendMoney(uid, name);
  }

  Future<void> _handleStudentIdQr(String token) async {
    final doc = await FirebaseFirestore.instance.collection('studentIdTokens').doc(token).get();
    if (!doc.exists) {
      _showMessage('This QR code is invalid or has expired.', Colors.orange);
      return;
    }
    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    if (expiresAt == null || expiresAt.isBefore(DateTime.now())) {
      _showMessage('This QR code has expired — ask them to refresh it.', Colors.orange);
      return;
    }
    final uid = data['uid'] as String? ?? '';
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == currentUid) {
      _showMessage("That's your own QR code.", Colors.orange);
      return;
    }
    final name = (data['name'] as String?) ?? 'this student';
    await _confirmAndSendMoney(uid, name);
  }

  Future<void> _confirmAndPayVendor(PaymentRequestModel request) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pay ${request.vendorName}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\$${request.amount.toStringAsFixed(2)}${request.note.isNotEmpty ? '\n${request.note}' : ''}'),
              const SizedBox(height: 16),
              const PaymentAccountSelector(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final transactionId = await MoneyTransferService().payVendor(
        toUid: request.vendorUid,
        amount: request.amount,
        note: request.note,
      );

      await FirebaseFirestore.instance.collection('paymentRequests').doc(request.id).update({
        'status': 'paid',
        'studentUid': user.uid,
        'studentName': user.displayName ?? 'Student',
        'paidAt': Timestamp.fromDate(DateTime.now()),
        'transactionId': transactionId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Payment sent'), backgroundColor: Theme.of(context).colorScheme.primary),
        );
        Navigator.pop(context);
      }
    } on MoneyTransferException catch (e) {
      _showMessage(e.message, Colors.red);
    } catch (e) {
      _showMessage('Payment failed: $e', Colors.red);
    }
  }

  Future<void> _confirmAndSendMoney(String toUid, String recipientName) async {
    final amountController = TextEditingController();
    final cs = Theme.of(context).colorScheme;
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Send money to $recipientName?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    hintText: '0.00',
                    errorText: errorText,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Paying from Red Hawk Dollars', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Sent via QR — capped at \$100/day.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  setDialogState(() => errorText = 'Enter a valid amount');
                  return;
                }
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final amount = double.parse(amountController.text.trim());
    try {
      await MoneyTransferService().sendMoneyViaQr(toUid: toUid, amount: amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent \$${amount.toStringAsFixed(2)} to $recipientName'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } on MoneyTransferException catch (e) {
      _showMessage(e.message, Colors.red);
    } catch (e) {
      _showMessage('Payment failed: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF8B1A2E), width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                if (_processing)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.black,
            child: const Text(
              'Scan a vendor payment QR, or another student\'s Receive Money / Student ID QR to pay them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('paymentRequests')
                    .where('status', isEqualTo: 'pending')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load payment requests.'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text('No pending payment requests right now.', style: TextStyle(color: cs.onSurfaceVariant)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final request = PaymentRequestModel.fromFirestore(docs[index]);
                      return Material(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _processing ? null : () => _confirmAndPayVendor(request),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: cs.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.store, color: Color(0xFF8B1A2E)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(request.vendorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                                      if (request.note.isNotEmpty)
                                        Text(request.note, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${request.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B1A2E)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
