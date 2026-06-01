import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../../../core/theme/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  final _userService = UserService();
  bool _checking = false;
  bool _resending = false;
  bool _resendCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  String get _email =>
      FirebaseAuth.instance.currentUser?.email ?? 'your email';

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = true;
      _cooldownSeconds = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        timer.cancel();
        setState(() => _resendCooldown = false);
      }
    });
  }

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    try {
      final user = await _authService.reloadUser();
      if (!mounted) return;
      if (user?.emailVerified == true) {
        await _userService.updateEmailVerified(user!.uid);
        if (!mounted) return;
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Email not verified yet. Please click the link in your email.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    setState(() => _resending = true);
    try {
      await _authService.sendEmailVerification();
      if (!mounted) return;
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to resend email.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Check Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a verification link to\n$_email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Click the link in the email to verify your account, then come back here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _checking ? null : _checkVerified,
                child: _checking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("I've Verified My Email"),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: (_resendCooldown || _resending) ? null : _resendEmail,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _resending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        _resendCooldown
                            ? 'Resend in ${_cooldownSeconds}s'
                            : 'Resend Email',
                        style: const TextStyle(color: AppColors.primary),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await _authService.signOut();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
