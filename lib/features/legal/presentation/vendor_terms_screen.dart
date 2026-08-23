import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorTermsScreen extends StatelessWidget {
  const VendorTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fromRegister = GoRouterState.of(context).extra == 'register';

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Terms of Service'), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(Icons.store_mall_directory_outlined, color: cs.primary, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text('Vendor Terms of Service', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface)),
                        const SizedBox(height: 4),
                        const Text('Effective: August 1, 2026 • Version 1.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _section('1. Vendor Eligibility', '''
To register as a vendor on Red Hawk Wallet, you must:

• Operate a legitimate business on or near a partnered university campus
• Provide accurate business name, category, and contact information
• Complete the vendor onboarding process and await admin approval
• Agree to these Vendor Terms in addition to the General Terms of Service

Vendor accounts are subject to admin review and may be approved, rejected, or suspended at any time.'''),

                  _section('2. Approval Process', '''
After registration, your application enters a review queue. Admin staff will:

• Verify your business information
• Review your category and compliance with campus policies
• Approve or reject your application, typically within 2–5 business days

You will gain access to the vendor dashboard only after approval. We reserve the right to reject applications without specific cause.'''),

                  _section('3. Payment Processing', '''
All transactions processed through Red Hawk Wallet are:

• Settled in demo mode for the MVP; real payments require further security and compliance review
• Subject to a platform fee (to be disclosed prior to live payment launch)
• Non-refundable once processed, except at the vendor's discretion via the refund flow

You are responsible for any chargebacks or disputes initiated by customers.'''),

                  _section('4. Vendor Conduct', '''
As a registered vendor, you agree to:

• Honor all payment requests accepted through the platform
• Not process fraudulent, duplicate, or inflated transactions
• Maintain accurate offers, pricing, and product descriptions
• Respond to reported issues within a reasonable timeframe
• Not engage in any discriminatory, abusive, or illegal business practices

Violations may result in immediate suspension or permanent removal.'''),

                  _section('5. Offers and Promotions', '''
Vendors may create offers and promotions through the platform. You agree that:

• Offers must be accurate and honored as described
• Expiry dates and terms must be clearly stated
• Misleading or bait-and-switch offers are prohibited
• Red Hawk Wallet may remove offers that violate platform guidelines'''),

                  _section('6. Data and Privacy', '''
By using the vendor platform, you acknowledge that:

• Transaction data may be used for platform analytics and reporting
• Customer data accessed through the platform is subject to our Privacy Policy
• You must not store, export, or misuse customer personal information
• Sales reports are available to you for your own business purposes only'''),

                  _section('7. Account Suspension and Termination', '''
Red Hawk Wallet may suspend or terminate your vendor account if:

• You violate these Vendor Terms or the General Terms of Service
• Fraud or policy abuse is detected
• Your business closes or becomes inactive
• You request account deletion

Upon termination, access to the vendor dashboard and historical transaction data is revoked.'''),

                  _section('8. Limitation of Liability', '''
Red Hawk Wallet is not liable for:

• Transaction failures due to connectivity issues or bank errors
• Loss of revenue during platform downtime
• Customer disputes that arise from vendor-side errors

Our total liability to any vendor shall not exceed the fees paid to us in the preceding 3 months.'''),

                  _section('9. Changes to Vendor Terms', '''
We may update these Vendor Terms as the platform evolves. You will be notified of material changes via the app. Continued use of the vendor dashboard after changes constitute acceptance of the new terms.'''),

                  _section('10. Contact', '''
For vendor-specific support or questions about these terms, contact us at:

vendor-support@redhawkwallet.com

For general support, visit the Help & Support section in the app settings.'''),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (fromRegister)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('I Understand', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.grey)),
        ],
      ),
    );
  }
}
