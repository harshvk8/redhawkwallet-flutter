import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorWaitingApprovalScreen extends StatelessWidget {
  const VendorWaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.hourglass_top_rounded, size: 52, color: cs.primary),
              ),
              const SizedBox(height: 28),
              Text(
                'Application Under Review',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your vendor account is pending approval. Our team will review your application and notify you within 1–2 business days.',
                style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.6), height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildInfoCard(cs),
              const SizedBox(height: 24),
              _buildTimeline(cs),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Checking approval status...'),
                        backgroundColor: cs.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: Icon(Icons.logout, color: cs.primary),
                  label: Text('Sign Out', style: TextStyle(color: cs.primary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: cs.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Questions? Contact support@redhawkwallet.com',
                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme cs) {
    final businessEmail = FirebaseAuth.instance.currentUser?.email ?? 'your email';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text('Submission Details', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.email_outlined, 'Business Email', businessEmail, cs),
          const SizedBox(height: 8),
          _infoRow(Icons.pending_actions, 'Status', 'Pending Review', cs),
          const SizedBox(height: 8),
          _infoRow(Icons.schedule, 'Expected Decision', '1–2 Business Days', cs),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildTimeline(ColorScheme cs) {
    final steps = [
      {'icon': Icons.check_circle, 'label': 'Application Submitted', 'done': true},
      {'icon': Icons.hourglass_top, 'label': 'Admin Review', 'done': false},
      {'icon': Icons.verified, 'label': 'Account Activated', 'done': false},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Approval Steps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone = step['done'] as bool;
            return Padding(
              padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 16 : 0),
              child: Row(
                children: [
                  Icon(
                    step['icon'] as IconData,
                    color: isDone ? Colors.green : (i == 1 ? Colors.orange : Colors.grey.shade400),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDone ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
