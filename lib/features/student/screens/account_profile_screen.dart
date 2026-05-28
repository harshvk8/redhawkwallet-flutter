import 'package:flutter/material.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

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
                  children: [
                    _buildUniversityVerification(),
                    const SizedBox(height: 16),
                    _buildSettingsSection(),
                    const SizedBox(height: 16),
                    _buildLogout(context),
                    const SizedBox(height: 16),
                    _buildVersionNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      color: const Color(0xFF8B1A2E),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 12),
          const Text(
            'Student Name',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'student@example.com',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityVerification() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'University Verification',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.grey, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Not Verified', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.email_outlined, size: 18),
              label: const Text('Add University Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1A2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verify your .edu email to unlock student discounts, campus offers, and exclusive rewards',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final settings = [
      {'icon': Icons.person_outline, 'label': 'Edit Profile', 'color': const Color(0xFF8B1A2E)},
      {'icon': Icons.history, 'label': 'Transaction History', 'color': const Color(0xFF8B1A2E)},
      {'icon': Icons.star_outline, 'label': 'Points and Rewards', 'color': Colors.amber},
      {'icon': Icons.notifications_none, 'label': 'Notifications', 'color': const Color(0xFF8B1A2E)},
      {'icon': Icons.help_outline, 'label': 'Help and Support', 'color': const Color(0xFF8B1A2E)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          ...settings.asMap().entries.map((entry) {
            final index = entry.key;
            final setting = entry.value;
            return Column(
              children: [
                if (index > 0) Divider(height: 1, color: Colors.grey.shade100),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (setting['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(setting['icon'] as IconData, color: setting['color'] as Color, size: 20),
                  ),
                  title: Text(setting['label'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () {},
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Color(0xFF8B1A2E)),
        label: const Text('Logout', style: TextStyle(color: Color(0xFF8B1A2E), fontSize: 15)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF8B1A2E)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildVersionNote() {
    return const Column(
      children: [
        Text('Red Hawk Wallet v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 2),
        Text('Demo Mode • Real payments coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}