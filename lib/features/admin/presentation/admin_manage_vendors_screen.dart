import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_states.dart';

class AdminManageVendorsScreen extends StatefulWidget {
  const AdminManageVendorsScreen({super.key});

  @override
  State<AdminManageVendorsScreen> createState() => _AdminManageVendorsScreenState();
}

class _AdminManageVendorsScreenState extends State<AdminManageVendorsScreen> {
  String _filter = 'All';
  String _search = '';
  final _filters = ['All', 'Active', 'Pending', 'Suspended'];
  final _db = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

  /// Maps Firestore fields → a single display status string.
  String _displayStatus(Map<String, dynamic> data) {
    if (data['accountStatus'] == 'suspended') return 'Suspended';
    if (data['vendorStatus'] == 'approved') return 'Active';
    return 'Pending';
  }

  Color _statusColor(String status) {
    if (status == 'Active') return Colors.green;
    if (status == 'Pending') return Colors.orange;
    return Colors.red;
  }

  Future<void> _approveVendor(String uid, String name) async {
    final confirmed = await _confirm(
      'Approve $name?',
      'They will immediately gain access to the vendor dashboard.',
      confirmLabel: 'Approve',
      confirmColor: Colors.green,
    );
    if (!confirmed) return;
    try {
      await _functions.httpsCallable('approveVendor').call({
        'vendorUid': uid,
        'decision': 'approve',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name approved'), backgroundColor: Colors.green),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve $name: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectVendor(String uid, String name) async {
    final confirmed = await _confirm(
      'Reject $name?',
      'Their vendor application will be declined.',
      confirmLabel: 'Reject',
      confirmColor: Colors.red,
    );
    if (!confirmed) return;
    try {
      await _functions.httpsCallable('approveVendor').call({
        'vendorUid': uid,
        'decision': 'reject',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor application rejected')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject $name: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _suspendVendor(String uid, String name) async {
    final confirmed = await _confirm(
      'Suspend $name?',
      'They will lose access to the vendor dashboard immediately.',
      confirmLabel: 'Suspend',
      confirmColor: Colors.red,
    );
    if (!confirmed) return;
    try {
      await _db.collection('users').doc(uid).update({
        'accountStatus': 'suspended',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name suspended'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to suspend $name: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reactivateVendor(String uid, String name) async {
    try {
      await _db.collection('users').doc(uid).update({
        'accountStatus': 'active',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name reactivated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reactivate $name: $e'), backgroundColor: Colors.red),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Vendors'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = f == _filter;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
                      ),
                      child: Text(f, style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('users').where('role', isEqualTo: 'vendor').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState(message: 'Loading vendors…');
                }
                if (snapshot.hasError) {
                  return AppErrorState(onRetry: () => setState(() {}));
                }

                var docs = snapshot.data?.docs ?? [];

                // Apply display-status filter
                if (_filter != 'All') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return _displayStatus(data) == _filter;
                  }).toList();
                }

                // Apply search
                if (_search.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = (data['businessName'] as String? ?? data['name'] as String? ?? '').toLowerCase();
                    final email = (data['email'] as String? ?? '').toLowerCase();
                    return name.contains(_search) || email.contains(_search);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.store_mall_directory_outlined,
                    title: _filter == 'All' ? 'No vendors yet' : 'No $_filter vendors',
                    subtitle: _search.isNotEmpty ? 'Try a different search term.' : 'Vendor applications will appear here once submitted.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = doc.id;
                    final displayStatus = _displayStatus(data);
                    final statusColor = _statusColor(displayStatus);
                    final businessName = data['businessName'] as String? ?? data['name'] as String? ?? 'Unknown';
                    final email = data['email'] as String? ?? '';
                    final category = data['businessCategory'] as String? ?? '—';
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final joined = createdAt != null
                        ? '${createdAt.month}/${createdAt.day}/${createdAt.year}'
                        : '—';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(businessName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface), overflow: TextOverflow.ellipsis),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(displayStatus, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(email, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                          Text(category, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Joined $joined', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (displayStatus == 'Pending') ...[
                                Expanded(child: _actionBtn('Approve', Colors.green, () => _approveVendor(uid, businessName))),
                                const SizedBox(width: 8),
                                Expanded(child: _actionBtn('Reject', Colors.red, () => _rejectVendor(uid, businessName))),
                              ] else if (displayStatus == 'Active') ...[
                                Expanded(child: _actionBtn('Suspend', Colors.red, () => _suspendVendor(uid, businessName))),
                                const SizedBox(width: 8),
                                Expanded(child: _outlineBtn('Details', cs, () => context.push('/admin/vendor-details', extra: {...data, 'uid': uid}))),
                              ] else if (displayStatus == 'Suspended') ...[
                                Expanded(child: _actionBtn('Reactivate', Colors.green, () => _reactivateVendor(uid, businessName))),
                                const SizedBox(width: 8),
                                Expanded(child: _outlineBtn('Details', cs, () => context.push('/admin/vendor-details', extra: {...data, 'uid': uid}))),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _outlineBtn(String label, ColorScheme cs, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

}
