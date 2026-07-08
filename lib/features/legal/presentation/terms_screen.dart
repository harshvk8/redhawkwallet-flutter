import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool fromRegister = GoRouterState.of(context).extra == 'register';

    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header('Red Hawk Wallet — Terms of Service', cs),
                  _meta('Version 1.0 · Effective July 1, 2026', cs),
                  const SizedBox(height: 20),
                  _section('1. Acceptance of Terms', cs),
                  _body(
                    'By creating an account or using the Red Hawk Wallet application, you agree to be bound by these Terms of Service. If you do not agree to these terms, you may not use the service.',
                    cs,
                  ),
                  _section('2. Eligibility', cs),
                  _body(
                    'Red Hawk Wallet is available to enrolled students, faculty, and approved campus vendors affiliated with the Red Hawk University ecosystem. You must be at least 18 years of age to use this service.',
                    cs,
                  ),
                  _section('3. Wallet and Payments', cs),
                  _body(
                    'Red Hawk Dollars are a campus-only digital currency redeemable exclusively at participating vendors. They have no cash value and cannot be exchanged for real currency. All transactions are final unless a dispute is raised within 7 days.',
                    cs,
                  ),
                  _section('4. Vendor Accounts', cs),
                  _body(
                    'Vendors must apply for and receive administrative approval before accepting payments. Red Hawk Wallet reserves the right to suspend or revoke vendor access for policy violations, fraudulent activity, or failure to fulfill orders.',
                    cs,
                  ),
                  _section('5. University Verification', cs),
                  _body(
                    'Students may verify a .edu email address to unlock additional benefits. Verified status may be revoked if the associated university email becomes invalid.',
                    cs,
                  ),
                  _section('6. Prohibited Use', cs),
                  _body(
                    'You may not use the wallet for money laundering, fraud, unauthorized transfers, or any activity that violates applicable law. Accounts engaging in prohibited activity will be suspended immediately.',
                    cs,
                  ),
                  _section('7. Privacy', cs),
                  _body(
                    'Your use of the service is also governed by our Privacy Policy, which is incorporated into these Terms by reference.',
                    cs,
                  ),
                  _section('8. Limitation of Liability', cs),
                  _body(
                    'Red Hawk Wallet is provided as-is during the beta period. We are not liable for any loss of funds due to technical errors during the MVP phase. Users participate knowing this is a demo/beta service.',
                    cs,
                  ),
                  _section('9. Changes to Terms', cs),
                  _body(
                    'We may update these Terms at any time. Continued use of the service after notification constitutes acceptance of the new terms.',
                    cs,
                  ),
                  _section('10. Contact', cs),
                  _body(
                    'For questions about these Terms, contact legal@redhawkwallet.com.',
                    cs,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (fromRegister)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                    child: const Text('I Understand', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(String text, ColorScheme cs) =>
      Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.3));

  Widget _meta(String text, ColorScheme cs) =>
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
      );

  Widget _section(String text, ColorScheme cs) =>
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.onSurface)),
      );

  Widget _body(String text, ColorScheme cs) =>
      Text(text, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.75), height: 1.7));
}
