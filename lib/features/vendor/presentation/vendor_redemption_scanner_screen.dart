import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../wallet/utils/qr_payloads.dart';

class VendorRedemptionScannerScreen extends StatefulWidget {
  const VendorRedemptionScannerScreen({super.key});

  @override
  State<VendorRedemptionScannerScreen> createState() => _VendorRedemptionScannerScreenState();
}

class _VendorRedemptionScannerScreenState extends State<VendorRedemptionScannerScreen> {
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

    final info = redeemInfoFromQr(raw);
    if (info == null) return;

    setState(() => _processing = true);
    await _controller.stop();
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('verifyOfferRedemption').call<Map<String, dynamic>>({
        'offerId': info.offerId,
        'uid': info.uid,
      });
      if (mounted) await _showResult(result.data);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) await _showError(e.message ?? 'Could not verify this code.');
    } finally {
      if (mounted) {
        await _controller.start();
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _showResult(Map<String, dynamic> data) {
    final studentName = data['studentName'] as String? ?? 'Student';
    final offerTitle = data['offerTitle'] as String? ?? 'Offer';
    final alreadyVerified = data['alreadyVerified'] as bool? ?? false;

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              alreadyVerified ? Icons.warning_amber_rounded : Icons.check_circle,
              color: alreadyVerified ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 10),
            Text(alreadyVerified ? 'Already Redeemed' : 'Valid'),
          ],
        ),
        content: Text(
          alreadyVerified
              ? '$studentName already redeemed "$offerTitle" — this code has been scanned before.'
              : '$studentName redeemed "$offerTitle".',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: alreadyVerified ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showError(String message) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 10),
            Text('Invalid'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Redemption'),
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
      body: Stack(
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Text(
              'Scan a student\'s offer redemption QR code.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
