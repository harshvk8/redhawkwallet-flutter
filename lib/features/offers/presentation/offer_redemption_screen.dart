import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../wallet/utils/qr_payloads.dart';

/// Full screen rather than a dialog — the redemption QR needs to be clearly
/// visible and durable enough to hand to a vendor, and this mirrors the
/// already-working vendor_qr_payment_screen.dart pattern instead of a modal.
class OfferRedemptionScreen extends StatelessWidget {
  const OfferRedemptionScreen({
    super.key,
    required this.offerId,
    required this.uid,
    required this.title,
  });

  final String offerId;
  final String uid;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Offer Redeemed'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 56, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Show this QR to the vendor to redeem',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: colorScheme.primary, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: redeemQrPayload(offerId, uid),
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(color: Color(0xFFC8102E)),
                  dataModuleStyle: const QrDataModuleStyle(color: Color(0xFFC8102E)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
