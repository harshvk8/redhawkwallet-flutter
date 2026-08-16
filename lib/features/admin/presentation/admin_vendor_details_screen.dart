import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminVendorDetailsScreen extends StatefulWidget {
  const AdminVendorDetailsScreen({super.key, this.vendor});

  final Map<String, dynamic>? vendor;

  @override
  State<AdminVendorDetailsScreen> createState() => _AdminVendorDetailsScreenState();
}

class _AdminVendorDetailsScreenState extends State<AdminVendorDetailsScreen> {
  final _db = FirebaseFirestore.instance;
  late Map<String, dynamic> _vendor = widget.vendor ?? const {};

  String get _uid => _vendor['uid'] as String? ?? '';
  String get _name => _vendor['businessName'] as String? ?? _vendor['name'] as String? ?? 'Vendor';

  String get _displayStatus {
    if (_vendor['accountStatus'] == 'suspended') return 'Suspended';
    if (_vendor['vendorStatus'] == 'approved') return 'Active';
    if (_vendor['vendorStatus'] == 'rejected') return 'Rejected';
    return 'Pending';
  }

  Future<void> _updateStatus(Map<String, dynamic> fields, String successMessage, {required Color color}) async {
    if (_uid.isEmpty) return;
    try {
      await _db.collection('users').doc(_uid).update({
        ...fields,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      if (!mounted) return;
      setState(() => _vendor = {..._vendor, ...fields});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: color),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _confirm(String title, String message, {required String confirmLabel, required Color confirmColor}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _approve() async {
    if (!await _confirm('Approve $_name?', 'They will immediately gain access to the vendor dashboard.', confirmLabel: 'Approve', confirmColor: Colors.green)) return;
    await _updateStatus({'vendorStatus': 'approved', 'accountStatus': 'active'}, '$_name approved', color: Colors.green);
  }

  Future<void> _reject() async {
    if (!await _confirm('Reject $_name?', 'Their vendor application will be declined.', confirmLabel: 'Reject', confirmColor: Colors.red)) return;
    await _updateStatus({'vendorStatus': 'rejected', 'accountStatus': 'active'}, 'Vendor application rejected', color: Colors.red);
  }

  Future<void> _suspend() async {
    if (!await _confirm('Suspend $_name?', 'They will lose access to the vendor dashboard immediately.', confirmLabel: 'Suspend', confirmColor: Colors.red)) return;
    await _updateStatus({'accountStatus': 'suspended'}, '$_name suspended', color: Colors.red);
  }

  Future<void> _reactivate() async {
    await _updateStatus({'accountStatus': 'active'}, '$_name reactivated', color: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVendorHeader(cs),
            const SizedBox(height: 16),
            _buildDetailsCard(cs),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorHeader(ColorScheme cs) {
    final statusColor = switch (_displayStatus) {
      'Active' => Colors.green,
      'Suspended' => Colors.red,
      'Rejected' => Colors.red,
      _ => Colors.orange,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.store, color: cs.primary, size: 36),
          ),
          const SizedBox(height: 12),
          Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_vendor['businessCategory'] as String? ?? '—', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_displayStatus == 'Pending' ? 'Pending Review' : _displayStatus,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ColorScheme cs) {
    final createdAt = (_vendor['createdAt'] as Timestamp?)?.toDate();
    final applied = createdAt != null ? '${createdAt.month}/${createdAt.day}/${createdAt.year}' : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Business Information', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _detailRow(cs, Icons.email_outlined, 'Email', _vendor['email'] as String? ?? '—'),
          _detailRow(cs, Icons.phone_outlined, 'Phone', _vendor['phoneNumber'] as String? ?? '—'),
          _detailRow(cs, Icons.category_outlined, 'Category', _vendor['businessCategory'] as String? ?? '—'),
          _detailRow(cs, Icons.location_on_outlined, 'Location', _vendor['businessLocation'] as String? ?? '—'),
          _detailRow(cs, Icons.calendar_today_outlined, 'Applied', applied),
        ],
      ),
    );
  }

  Widget _detailRow(ColorScheme cs, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (_uid.isEmpty) {
      return Text('No vendor account id available.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
    }

    final buttons = <Widget>[];
    switch (_displayStatus) {
      case 'Pending':
        buttons.addAll([
          _fullWidthButton(Icons.check_circle_outline, 'Approve Vendor', Colors.green, _approve),
          const SizedBox(height: 10),
          _fullWidthButton(Icons.cancel_outlined, 'Reject Application', Colors.red, _reject),
        ]);
      case 'Active':
        buttons.add(_fullWidthButton(Icons.block, 'Suspend Vendor', Colors.orange, _suspend, outlined: true));
      case 'Suspended':
        buttons.add(_fullWidthButton(Icons.check_circle_outline, 'Reactivate Vendor', Colors.green, _reactivate));
      case 'Rejected':
        buttons.add(_fullWidthButton(Icons.check_circle_outline, 'Approve Vendor', Colors.green, _approve));
    }

    return Column(children: buttons);
  }

  Widget _fullWidthButton(IconData icon, String label, Color color, VoidCallback onPressed, {bool outlined = false}) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: color),
              label: Text(label, style: TextStyle(color: color)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
    );
  }
}
