import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  String _selectedRole = UserRole.normalUser;
  String? _selectedCategory;

  bool get _isVendor => _selectedRole == UserRole.vendor;

  static const _categories = [
    'Food & Beverage',
    'Bookstore',
    'Clothing & Apparel',
    'Health & Wellness',
    'Technology',
    'Services',
    'Entertainment',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        role: _selectedRole,
        vendorData: _isVendor
            ? {
                'businessName': _businessNameController.text.trim(),
                'businessCategory': _selectedCategory,
              }
            : null,
      );
      await _authService.sendEmailVerification();
      if (!mounted) return;
      context.go('/email-verification');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Registration failed. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB);
    final inputFill =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9F9);
    final mutedText =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final mutedBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.4 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        cs.primary.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const AuthHawkLogo(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Create your Red Hawk Wallet\naccount',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join as a user or vendor and start using campus-friendly offers, rewards, and wallet features.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedText,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Role toggle
                          Container(
                            decoration: BoxDecoration(
                              color: inputFill,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: borderColor),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                _roleOption(
                                  label: 'User',
                                  icon: Icons.person_outline,
                                  value: UserRole.normalUser,
                                  cs: cs,
                                  isDark: isDark,
                                ),
                                _roleOption(
                                  label: 'Vendor',
                                  icon: Icons.storefront,
                                  value: UserRole.vendor,
                                  cs: cs,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Vendor-specific fields
                          if (_isVendor) ...[
                            AuthInputLabel('Business Name'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _businessNameController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                              decoration: _inputDec(
                                hint: 'Campus Coffee House',
                                icon: Icons.storefront,
                                fill: inputFill,
                                border: borderColor,
                                cs: cs,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Enter your business name'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Name field
                          AuthInputLabel(_isVendor ? 'Owner/Manager Full Name' : 'Full Name'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                            decoration: _inputDec(
                              hint: _isVendor ? 'Jane Smith' : 'Your full name',
                              icon: Icons.person_outlined,
                              fill: inputFill,
                              border: borderColor,
                              cs: cs,
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Enter your full name'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          AuthInputLabel(_isVendor ? 'Business Email' : 'Email'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                            decoration: _inputDec(
                              hint: _isVendor ? 'contact@business.com' : 'you@university.edu',
                              icon: Icons.mail_outlined,
                              fill: inputFill,
                              border: borderColor,
                              cs: cs,
                            ),
                            validator: (v) =>
                                (v == null || !v.contains('@'))
                                    ? 'Enter a valid email'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          // Category dropdown (vendor only)
                          if (_isVendor) ...[
                            AuthInputLabel('Business Category'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: _inputDec(
                                hint: 'Select a category',
                                icon: Icons.category_outlined,
                                fill: inputFill,
                                border: borderColor,
                                cs: cs,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                              items: _categories
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCategory = v),
                              validator: (v) =>
                                  v == null ? 'Select a business category' : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Password
                          AuthInputLabel('Password'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                            decoration: _inputDec(
                              hint: 'Enter password',
                              icon: Icons.lock_outlined,
                              fill: inputFill,
                              border: borderColor,
                              cs: cs,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: mutedText,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 8)
                                ? 'Password must be at least 8 characters'
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Use at least 8 characters',
                              style: TextStyle(fontSize: 11, color: mutedText),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          AuthInputLabel('Confirm Password'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _register(),
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                            decoration: _inputDec(
                              hint: 'Confirm password',
                              icon: Icons.lock_outlined,
                              fill: inputFill,
                              border: borderColor,
                              cs: cs,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: mutedText,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) =>
                                v != _passwordController.text
                                    ? 'Passwords do not match'
                                    : null,
                          ),
                          const SizedBox(height: 20),

                          // Terms checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (v) =>
                                      setState(() => _agreedToTerms = v ?? false),
                                  activeColor: cs.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _agreedToTerms = !_agreedToTerms),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        height: 1.4,
                                      ),
                                      children: [
                                        const TextSpan(text: 'I agree to the '),
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Create Account button
                          ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isVendor
                                    ? 'Create Vendor Account'
                                    : 'Create Account'),
                          ),
                          const SizedBox(height: 20),

                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                    fontSize: 13, color: mutedText),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Footer
                          Text(
                            'Demo wallet only. Real payments coming after security and payment review.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11, color: mutedText, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          AuthDarkToggle(mutedBg: mutedBg, isDark: isDark),
        ],
      ),
    );
  }

  Widget _roleOption({
    required String label,
    required IconData icon,
    required String value,
    required ColorScheme cs,
    required bool isDark,
  }) {
    final selected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.grey)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec({
    required String hint,
    required IconData icon,
    required Color fill,
    required Color border,
    required ColorScheme cs,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: fill,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
