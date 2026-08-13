import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/models/user_model.dart';
import '../../wallet/models/transaction_model.dart';
import '../../wallet/models/wallet_balance_type.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  static const _prefsKey = 'dashboard_wallet_balance_type';

  WalletBalanceType _selectedBalance = WalletBalanceType.redHawkDollars;

  @override
  void initState() {
    super.initState();
    _loadSelectedBalance();
  }

  Future<void> _loadSelectedBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = WalletBalanceType.fromName(prefs.getString(_prefsKey));
    if (saved != null && mounted) {
      setState(() => _selectedBalance = saved);
    }
  }

  Future<void> _selectBalance(WalletBalanceType type) async {
    setState(() => _selectedBalance = type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, type.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletCard(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(context),
                    const SizedBox(height: 16),
                    _buildDemoNote(context),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, const Color(0xFFC8102E)]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 14)),
              if (uid == null)
                Text('Student', style: TextStyle(color: colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold))
              else
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                  builder: (context, snapshot) {
                    final name = snapshot.hasData && snapshot.data!.exists
                        ? UserModel.fromFirestore(snapshot.data!).name
                        : '';
                    return Text(
                      name.isNotEmpty ? name : 'Student',
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  },
                ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none, color: colorScheme.onPrimary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, const Color(0xFFC8102E)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/wallet'),
                child: Text(_selectedBalance.label, style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 14)),
              ),
              const SizedBox(width: 2),
              // Sibling of the GestureDetector above, not nested inside it —
              // nesting a PopupMenuButton inside a tap-to-navigate
              // GestureDetector makes both fire on a single tap.
              PopupMenuButton<WalletBalanceType>(
                tooltip: 'Choose a balance to show',
                padding: EdgeInsets.zero,
                icon: Icon(Icons.keyboard_arrow_down, size: 18, color: colorScheme.onPrimary.withValues(alpha: 0.8)),
                onSelected: _selectBalance,
                itemBuilder: (context) => WalletBalanceType.values
                    .map((type) => CheckedPopupMenuItem(
                          value: type,
                          checked: type == _selectedBalance,
                          child: Text(type.label),
                        ))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/wallet'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (uid == null)
                  Text('\$0.00', style: TextStyle(color: colorScheme.onPrimary, fontSize: 36, fontWeight: FontWeight.bold))
                else
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('wallets').doc(uid).snapshots(),
                    builder: (context, snapshot) {
                      final walletData = snapshot.data?.data() as Map<String, dynamic>?;
                      return Text(
                        _selectedBalance.format(walletData),
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: 36, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/wallet/add'),
              icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
              label: const Text('Add Funds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actions = [
      {'icon': Icons.qr_code, 'label': 'QR ID', 'route': '/qr-id'},
      {'icon': Icons.qr_code_scanner, 'label': 'Scan', 'route': '/qr-scanner'},
      {'icon': Icons.local_offer, 'label': 'Offers', 'route': '/offers'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: colorScheme.onPrimary, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: () => context.push(action['route'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(action['icon'] as IconData, color: colorScheme.primary, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(action['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.push('/transactions'),
              child: Text('View All', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (uid == null)
          Text('Not signed in.', style: TextStyle(color: colorScheme.onSurfaceVariant))
        else
          StreamBuilder<QuerySnapshot>(
            // array-contains + orderBy on a different field needs a composite
            // index, so sort client-side — same approach as Transaction History.
            stream: FirebaseFirestore.instance
                .collection('transactions')
                .where('participants', arrayContains: uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: LinearProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Could not load transactions.', style: TextStyle(color: colorScheme.onSurfaceVariant));
              }
              final transactions = (snapshot.data?.docs ?? []).map(TransactionModel.fromFirestore).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              if (transactions.isEmpty) {
                return Text('No transactions yet.', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant));
              }
              return Column(
                children: transactions.take(3).map((tx) {
                  final isReceived = tx.toUid == uid;
                  final counterparty = isReceived
                      ? (tx.fromName.isNotEmpty ? tx.fromName : 'Someone')
                      : (tx.toName.isNotEmpty ? tx.toName : 'Vendor');
                  return GestureDetector(
                    onTap: () => context.push('/transaction-details', extra: {
                      'id': tx.id,
                      'fromName': tx.fromName.isNotEmpty ? tx.fromName : 'Someone',
                      'toName': tx.toName.isNotEmpty ? tx.toName : 'Vendor',
                      'amount': tx.amount,
                      'status': tx.status[0].toUpperCase() + tx.status.substring(1),
                      'createdAt': tx.createdAt,
                      'description': tx.description,
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isReceived ? Colors.green.withValues(alpha: 0.1) : colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isReceived ? Icons.call_received : Icons.call_made,
                              color: isReceived ? Colors.green : colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(counterparty, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                  '${tx.createdAt.month}/${tx.createdAt.day}/${tx.createdAt.year}',
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isReceived ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isReceived ? Colors.green : colorScheme.onSurface),
                              ),
                              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDemoNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'This is a demo wallet. Start using Red Hawk Wallet to see your real transactions here!',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home, 'Home', '/home', true, colorScheme),
          _navItem(context, Icons.account_balance_wallet, 'Wallet', '/wallet', false, colorScheme),
          _navItemQR(context),
          _navItem(context, Icons.local_offer, 'Offers', '/offers', false, colorScheme),
          _navItem(context, Icons.person, 'Account', '/profile', false, colorScheme),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, String route, bool isActive, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _navItemQR(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.push('/qr-id'),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
        child: Icon(Icons.qr_code, color: colorScheme.onPrimary, size: 26),
      ),
    );
  }
}
