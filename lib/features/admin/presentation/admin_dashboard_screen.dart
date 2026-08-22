import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _db = FirebaseFirestore.instance;
  bool _loading = true;
  String? _error;

  int _totalUsers = 0;
  int _vendors = 0;
  int _transactions = 0;
  int _pending = 0;
  int _suspended = 0;
  int _verified = 0;

  bool _activityLoading = true;
  List<_ActivityItem> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadRecentActivity() async {
    setState(() => _activityLoading = true);
    try {
      final results = await Future.wait([
        _db.collection('users').orderBy('createdAt', descending: true).limit(5).get(),
        _db.collection('transactions').orderBy('createdAt', descending: true).limit(5).get(),
        _db.collection('offers').orderBy('createdAt', descending: true).limit(5).get(),
      ]);

      final items = <_ActivityItem>[];

      for (final doc in results[0].docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) continue;
        final isVendor = data['role'] == 'vendor';
        items.add(_ActivityItem(
          action: isVendor ? 'New vendor registered' : 'New user joined',
          detail: isVendor
              ? (data['businessName'] as String?) ?? (data['name'] as String?) ?? 'Unknown vendor'
              : (data['name'] as String?) ?? (data['email'] as String?) ?? 'Unknown user',
          time: createdAt,
        ));
      }

      for (final doc in results[1].docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) continue;
        final status = data['status'] as String? ?? 'pending';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final counterparty = (data['toName'] as String?) ?? (data['fromName'] as String?) ?? '';
        items.add(_ActivityItem(
          action: switch (status) {
            'completed' => 'Transaction completed',
            'failed' => 'Transaction failed',
            _ => 'Transaction pending',
          },
          detail: '\$${amount.toStringAsFixed(2)}${counterparty.isNotEmpty ? ' at $counterparty' : ''}',
          time: createdAt,
        ));
      }

      for (final doc in results[2].docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) continue;
        items.add(_ActivityItem(
          action: 'Offer created',
          detail: (data['title'] as String?) ?? 'Untitled offer',
          time: createdAt,
        ));
      }

      items.sort((a, b) => b.time.compareTo(a.time));
      if (!mounted) return;
      setState(() {
        _recentActivity = items.take(6).toList();
        _activityLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _activityLoading = false);
    }
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadStats(), _loadRecentActivity()]);
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${time.month}/${time.day}/${time.year}';
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = _db.collection('users');
      final results = await Future.wait([
        users.count().get(),
        users.where('role', isEqualTo: 'vendor').count().get(),
        _db.collection('transactions').count().get(),
        users.where('role', isEqualTo: 'vendor').where('vendorStatus', isEqualTo: 'pending').count().get(),
        users.where('accountStatus', isEqualTo: 'suspended').count().get(),
        users.where('isUniversityVerified', isEqualTo: true).count().get(),
      ]);
      if (!mounted) return;
      setState(() {
        _totalUsers = results[0].count ?? 0;
        _vendors = results[1].count ?? 0;
        _transactions = results[2].count ?? 0;
        _pending = results[3].count ?? 0;
        _suspended = results[4].count ?? 0;
        _verified = results[5].count ?? 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadAll,
          ),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => context.push('/notifications')),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text('Failed to load stats: $_error', style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Red Hawk Wallet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Admin Control Panel', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _headerStat(_loading ? '…' : '$_totalUsers', 'Total Users'),
                        _headerStat(_loading ? '…' : '$_vendors', 'Vendors'),
                        _headerStat(_loading ? '…' : '$_transactions', 'Transactions'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _statCard('Pending', _loading ? '…' : '$_pending', Icons.pending_actions, Colors.orange),
                  const SizedBox(width: 10),
                  _statCard('Suspended', _loading ? '…' : '$_suspended', Icons.block, Colors.red),
                  const SizedBox(width: 10),
                  _statCard('Verified', _loading ? '…' : '$_verified', Icons.verified_user, Colors.green),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Admin Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _actionButton(context, Icons.manage_accounts, 'Manage Vendors', '/admin/vendors'),
              const SizedBox(height: 8),
              _actionButton(context, Icons.bar_chart, 'View All Transactions', '/admin/transactions'),
              const SizedBox(height: 8),
              _actionButton(context, Icons.local_offer, 'Manage Offers', '/admin/offers'),
              const SizedBox(height: 8),
              _actionButton(context, Icons.event, 'Manage Events', '/admin/events'),
              const SizedBox(height: 8),
              _actionButton(context, Icons.people, 'Manage Users', '/admin/users'),
              const SizedBox(height: 8),
              _actionButton(context, Icons.support_agent, 'Support Chats', '/admin/support'),
              const SizedBox(height: 8),
              _actionButton(context, Icons.settings, 'Admin Settings', '/admin/settings'),
              const SizedBox(height: 20),
              const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_activityLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_recentActivity.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('No recent activity yet', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                )
              else
                ..._recentActivity.map((activity) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: cs.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(activity.action, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
                                  Text(activity.detail, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(_formatRelativeTime(activity.time), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _headerStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, String? route) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (route != null) {
            context.push(route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label coming in MVP')),
            );
          }
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _ActivityItem {
  final String action;
  final String detail;
  final DateTime time;

  const _ActivityItem({required this.action, required this.detail, required this.time});
}
