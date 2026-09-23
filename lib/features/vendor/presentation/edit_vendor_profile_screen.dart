import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_states.dart';

class EditVendorProfileScreen extends StatefulWidget {
  const EditVendorProfileScreen({super.key});

  @override
  State<EditVendorProfileScreen> createState() => _EditVendorProfileScreenState();
}

class _EditVendorProfileScreenState extends State<EditVendorProfileScreen> {
  static const _categories = ['Food & Drinks', 'Books & Supplies', 'Services', 'Clothing', 'Electronics'];

  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _hoursController = TextEditingController();
  String? _category;

  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _populateFrom(Map<String, dynamic> data) {
    _businessNameController.text = data['businessName'] as String? ?? '';
    _ownerNameController.text = data['name'] as String? ?? '';
    _phoneController.text = data['phoneNumber'] as String? ?? '';
    _locationController.text = data['businessLocation'] as String? ?? '';
    _hoursController.text = data['businessHours'] as String? ?? '';
    final category = data['businessCategory'] as String?;
    _category = _categories.contains(category) ? category : null;
    _loaded = true;
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'businessName': _businessNameController.text.trim(),
        'name': _ownerNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'businessCategory': _category,
        'businessLocation': _locationController.text.trim(),
        'businessHours': _hoursController.text.trim(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: uid == null
          ? const AppErrorState(message: 'Not signed in.')
          : _loaded
              ? _buildForm(cs)
              : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const AppLoadingState(message: 'Loading profile…');
                    }
                    if (snapshot.hasError) {
                      return AppErrorState(onRetry: () => setState(() {}));
                    }
                    _populateFrom(snapshot.data?.data() ?? {});
                    return _buildForm(cs);
                  },
                ),
    );
  }

  Widget _buildForm(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store, color: Color(0xFFC8102E), size: 56),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo upload coming soon')),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFFC8102E), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildField('Business Name', _businessNameController),
          _buildField('Owner Name', _ownerNameController),
          _buildField('Phone Number', _phoneController),
          const Text('Business Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            hint: const Text('Select a category'),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC8102E), width: 2),
              ),
            ),
            items: _categories.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) => setState(() => _category = val),
          ),
          const SizedBox(height: 16),
          _buildField('Location', _locationController),
          _buildField('Business Hours', _hoursController),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8102E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC8102E), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
