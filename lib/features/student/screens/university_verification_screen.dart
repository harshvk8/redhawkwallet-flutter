import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/services/user_service.dart';
import '../../../core/utils/university_email_validator.dart';

class UniversityVerificationScreen extends StatefulWidget {
  const UniversityVerificationScreen({super.key});

  @override
  State<UniversityVerificationScreen> createState() => _UniversityVerificationScreenState();
}

class _UniversityVerificationScreenState extends State<UniversityVerificationScreen> {
  final _emailController = TextEditingController();
  final _userService = UserService();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (!UniversityEmailValidator.isUniversityEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use a valid .edu email address'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await _userService.updateUniversityVerification(uid, email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('University email verified successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('University Verification'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: Color(0xFF8B1A2E), size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify Your University Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Verify your university email to unlock student discounts, campus offers, QR student ID, and exclusive rewards.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('University Email', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'yourname@university.edu',
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                helperText: 'Use your official .edu email address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B1A2E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Verify Email', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Benefits You Will Unlock', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _benefitItem(Icons.local_offer, Colors.amber, 'Student Discounts', 'Get exclusive discounts at campus and local vendors'),
            _benefitItem(Icons.confirmation_number, const Color(0xFF8B1A2E), 'Campus Offers', 'Access special deals and promotions available only on campus'),
            _benefitItem(Icons.qr_code, const Color(0xFF8B1A2E), 'QR Student ID', 'Use your digital student ID for quick verification and access'),
            _benefitItem(Icons.star, Colors.amber, 'Exclusive Rewards', 'Earn bonus points and unlock student-only reward tiers'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitItem(IconData icon, Color color, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
