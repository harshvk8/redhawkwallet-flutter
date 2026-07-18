import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _filter = 'All';
  String _search = '';
  final _filters = ['All', 'Normal User', 'Verified Student', 'Vendor', 'Admin', 'Suspended'];
  final _db = FirebaseFirestore.instance;

  Future<void> _suspendUser(String uid, String name) async {
    final confirmed = await _confirm(
      'Suspend $name?',
      'They will be redirected to the login screen and unable to access the app.',
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

  Future<void> _reactivateUser(String uid, String name) async {
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

  Color _roleColor(String role) {
    if (role == 'admin') return Colors.purple;
    if (role == 'vendor') return Colors.blue;
    if (role == 'verified_student') return Colors.green;
    return Colors.grey;
  }

  String _roleLabel(String role) {
    if (role == 'admin') return 'Admin';
    if (role == 'vendor') return 'Vendor';
    if (role == 'verified_student') return 'Verified Student';
    return 'Normal User';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? cs.primary : Colors.grey.shade200),
                      ),
                      child: Text(f, style: TextStyle(color: selected ? Colors.white : cs.onSurface, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('users').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: cs.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        const Text('Failed to load users', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data?.docs ?? [];

                // Filter by role/status
                if (_filter == 'Suspended') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['accountStatus'] == 'suspended';
                  }).toList();
                } else if (_filter != 'All') {
                  final roleMap = {
                    'Normal User': 'normal_user',
                    'Verified Student': 'verified_student',
                    'Vendor': 'vendor',
                    'Admin': 'admin',
                  };
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['role'] == roleMap[_filter];
                  }).toList();
                }

                // Search
                if (_search.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    final email = (data['email'] as String? ?? '').toLowerCase();
                    return name.contains(_search) || email.contains(_search);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, color: Colors.grey.shade400, size: 48),
                        const SizedBox(height: 8),
                        Text(_filter == 'All' ? 'No users yet.' : 'No $_filter users.',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = doc.id;
                    final name = data['name'] as String? ?? 'Unknown';
                    final email = data['email'] as String? ?? '';
                    final role = data['role'] as String? ?? 'normal_user';
                    final isSuspended = data['accountStatus'] == 'suspended';
                    final emailVerified = data['isEmailVerified'] as bool? ?? false;
                    final uniVerified = data['isUniversityVerified'] as bool? ?? false;
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final joined = createdAt != null
                        ? '${createdAt.month}/${createdAt.day}/${createdAt.year}'
                        : '—';
                    final roleColor = _roleColor(role);
                    final roleLabel = _roleLabel(role);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSuspended ? Colors.red.shade100 : Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: cs.primary.withValues(alpha: 0.1),
                                    child: Text(name.isNotEmpty ? name[0] : '?', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                                      Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                    child: Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                  if (isSuspended) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                      child: const Text('Suspended', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _verifiedBadge('Email', emailVerified),
                              const SizedBox(width: 8),
                              _verifiedBadge('University', uniVerified),
                              const Spacer(),
                              Text('Joined $joined', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          if (role != 'admin') ...[
                            const SizedBox(height: 10),
                            isSuspended
                                ? ElevatedButton(
                                    onPressed: () => _reactivateUser(uid, name),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Reactivate', style: TextStyle(fontSize: 13)),
                                  )
                                : ElevatedButton(
                                    onPressed: () => _suspendUser(uid, name),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Suspend', style: TextStyle(fontSize: 13)),
                                  ),
                          ],
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

  Widget _verifiedBadge(String label, bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: verified ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(verified ? Icons.check_circle : Icons.cancel, size: 12, color: verified ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: verified ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }
}
