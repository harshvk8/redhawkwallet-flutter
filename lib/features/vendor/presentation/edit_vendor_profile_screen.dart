import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditVendorProfileScreen extends StatefulWidget {
  const EditVendorProfileScreen({super.key});

  @override
  State<EditVendorProfileScreen> createState() => _EditVendorProfileScreenState();
}

class _EditVendorProfileScreenState extends State<EditVendorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController(text: 'Red Hawk Cafe');
  final _phoneController = TextEditingController(text: '+1 (555) 000-0000');
  final _locationController = TextEditingController(text: 'Campus Building A, Floor 1');
  final _hoursController = TextEditingController(text: 'Mon–Fri 8am–6pm');
  final _descriptionController = TextEditingController(text: 'Your go-to campus cafe for coffee, snacks, and quick bites.');
  String _selectedCategory = 'Food & Beverage';
  bool _saving = false;

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
    _businessNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _hoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFill = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9F9);
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary))
                : Text('Save', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: cs.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.storefront, size: 48, color: cs.primary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Tap to change logo', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 24),
              _label('Business Name', cs),
              const SizedBox(height: 6),
              _field(_businessNameController, 'Campus Coffee House', Icons.storefront, inputFill, borderColor, cs, isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              const SizedBox(height: 16),
              _label('Business Category', cs),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: _dec('Select category', Icons.category_outlined, inputFill, borderColor, cs),
                dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              _label('Phone Number', cs),
              const SizedBox(height: 6),
              _field(_phoneController, '+1 (555) 000-0000', Icons.phone_outlined, inputFill, borderColor, cs, isDark,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _label('Location / Address', cs),
              const SizedBox(height: 6),
              _field(_locationController, 'Building, Floor, Room', Icons.location_on_outlined, inputFill, borderColor, cs, isDark),
              const SizedBox(height: 16),
              _label('Business Hours', cs),
              const SizedBox(height: 6),
              _field(_hoursController, 'Mon–Fri 9am–5pm', Icons.schedule, inputFill, borderColor, cs, isDark),
              const SizedBox(height: 16),
              _label('Description', cs),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 200,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                decoration: _dec('Tell students about your business...', Icons.description_outlined, inputFill, borderColor, cs),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, ColorScheme cs) =>
      Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface));

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon,
    Color fill,
    Color border,
    ColorScheme cs,
    bool isDark, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
      decoration: _dec(hint, icon, fill, border, cs),
      validator: validator,
    );
  }

  InputDecoration _dec(String hint, IconData icon, Color fill, Color border, ColorScheme cs) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: fill,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.error, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
