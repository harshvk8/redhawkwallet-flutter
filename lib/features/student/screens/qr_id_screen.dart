import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../wallet/utils/qr_payloads.dart';

const _rotationInterval = Duration(seconds: 45);

class QrIdScreen extends StatefulWidget {
  const QrIdScreen({super.key});

  @override
  State<QrIdScreen> createState() => _QrIdScreenState();
}

class _QrIdScreenState extends State<QrIdScreen> {
  final _functions = FirebaseFunctions.instance;
  String? _name;
  String? _email;
  bool _isUniversityVerified = false;
  String? _token;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchToken();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!mounted) return;
    final data = doc.data();
    setState(() {
      _name = (data?['name'] as String?) ?? user.displayName ?? 'Student';
      _email = (data?['email'] as String?) ?? user.email ?? '';
      _isUniversityVerified = (data?['isUniversityVerified'] as bool?) ?? false;
    });
  }

  Future<void> _fetchToken() async {
    _rotationTimer?.cancel();
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      final result = await _functions.httpsCallable('issueStudentIdToken').call<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _token = result.data['token'] as String;
        _loading = false;
      });
      _rotationTimer = Timer(_rotationInterval, _fetchToken);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'Could not generate a QR code.';
        _loading = false;
      });
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('QR Student ID'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: Color(0xFF8B1A2E), size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(_name ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(_email ?? '', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_isUniversityVerified ? colorScheme.primary : Colors.grey).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isUniversityVerified ? 'Verified Student' : 'Not Verified',
                      style: TextStyle(
                        color: _isUniversityVerified ? colorScheme.primary : Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Center(child: _buildQrContent(colorScheme)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error != null ? 'Refreshes automatically every 45 seconds once available.' : 'This code refreshes every 45 seconds for your safety.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _refreshing ? null : _fetchToken,
                icon: _refreshing
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary))
                    : Icon(Icons.refresh, color: colorScheme.primary),
                label: Text('Refresh QR', style: TextStyle(color: colorScheme.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrContent(ColorScheme colorScheme) {
    if (_loading) {
      return const CircularProgressIndicator();
    }
    if (_error != null || _token == null) {
      return Icon(Icons.error_outline, size: 64, color: colorScheme.error);
    }
    return QrImageView(
      data: studentIdQrPayload(_token!),
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(color: Color(0xFF8B1A2E)),
      dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF8B1A2E)),
    );
  }
}
