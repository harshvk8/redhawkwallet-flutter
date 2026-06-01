import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final List<Map<String, dynamic>> _recentTransactions = const [
    {
      'name': 'Campus Coffee House',
      'date': 'May 27, 2026 • 9:45 AM',
      'amount': '-\$5.50',
      'isDebit': true,
      'icon': Icons.local_cafe,
    },
    {
      'name': 'Added Funds',
      'date': 'May 26, 2026 • 2:30 PM',
      'amount': '+\$25.00',
      'isDebit': false,
      'icon': Icons.add_circle_outline,
    },
    {
      'name': 'Student Bookstore',
      'date': 'May 25, 2026 • 11:20 AM',
      'amount': '-\$42.99',
      'isDebit': true,
      'icon': Icons.menu_book,
    },
  ];

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(),
                    const SizedBox(height: 16),
                    _buildDemoNote(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFF8B1A2E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                _displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                  Icons.notifications_none, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8B1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '\$0.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'USD',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Funds'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B1A2E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/transactions'),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side:
                          BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.qr_code,
        'label': 'QR ID',
        'route': '/qr-id',
      },
      {
        'icon': Icons.qr_code_scanner,
        'label': 'Scan',
        'route': '/qr-scanner',
      },
      {
        'icon': Icons.local_offer,
        'label': 'Offers',
        'route': null,
      },
      {
        'icon': Icons.history,
        'label': 'History',
        'route': '/transactions',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            final route = action['route'] as String?;
            return Expanded(
              child: GestureDetector(
                onTap: route != null ? () => context.go(route) : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: const Color(0xFF8B1A2E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
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

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/transactions'),
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF8B1A2E)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentTransactions.map((tx) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tx['isDebit'] as bool
                          ? const Color(0xFFFFF0F0)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      tx['icon'] as IconData,
                      color: tx['isDebit'] as bool
                          ? const Color(0xFF8B1A2E)
                          : Colors.green,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tx['date'] as String,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tx['amount'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color:
                              tx['isDebit'] as bool ? Colors.black : Colors.green,
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.grey, size: 18),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDemoNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'This is a demo wallet. Start using Red Hawk Wallet to see your real transactions here!',
        style: TextStyle(color: Colors.grey, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', true, onTap: null),
          _navItem(Icons.account_balance_wallet, 'Wallet', false,
              onTap: null),
          _navItemQR(),
          _navItem(Icons.local_offer, 'Offers', false, onTap: null),
          _navItem(Icons.person, 'Account', false,
              onTap: () => context.go('/profile')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive,
      {required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive ? const Color(0xFF8B1A2E) : Colors.grey,
              size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFF8B1A2E) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItemQR() {
    return GestureDetector(
      onTap: () => context.go('/qr-id'),
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Color(0xFF8B1A2E),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.qr_code, color: Colors.white, size: 26),
      ),
    );
  }
}
