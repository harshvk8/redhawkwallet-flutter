import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String selectedRole = 'All';
  final List<String> roles = ['All', 'Normal User', 'Verified Student', 'Vendor', 'Admin'];

  final List<Map<String, dynamic>> users = [
    {'name': 'Alex Johnson', 'email': 'alex@montclair.edu', 'role': 'Verified Student', 'emailVerified': true, 'uniVerified': true, 'created': 'May 10, 2026'},
    {'name': 'Sara Lee', 'email': 'sara@gmail.com', 'role': 'Normal User', 'emailVerified': true, 'uniVerified': false, 'created': 'May 15, 2026'},
    {'name': 'Mike Chen', 'email': 'mike@montclair.edu', 'role': 'Verified Student', 'emailVerified': true, 'uniVerified': true, 'created': 'May 18, 2026'},
    {'name': 'John Smith', 'email': 'john@redhawk.edu', 'role': 'Vendor', 'emailVerified': true, 'uniVerified': false, 'created': 'May 12, 2026'},
    {'name': 'Admin User', 'email': 'admin@redhawk.edu', 'role': 'Admin', 'emailVerified': true, 'uniVerified': false, 'created': 'May 1, 2026'},
  ];

  Color _roleColor(String role) {
    if (role == 'Admin') return Colors.purple;
    if (role == 'Vendor') return Colors.blue;
    if (role == 'Verified Student') return Colors.green;
    return Colors.grey;
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (selectedRole == 'All') return users;
    return users.where((u) => u['role'] == selectedRole).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Manage Users'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: roles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final role = roles[index];
                  final selected = role == selectedRole;
                  return GestureDetector(
                    onTap: () => setState(() => selectedRole = role),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF8B1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? const Color(0xFF8B1A2E) : Colors.grey.shade200),
                      ),
                      child: Text(role, style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final roleColor = _roleColor(user['role']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
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
                                  backgroundColor: const Color(0xFFFFF0F0),
                                  child: Text(user['name'][0], style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(user['email'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(user['role'], style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _verifiedBadge('Email', user['emailVerified']),
                            const SizedBox(width: 8),
                            _verifiedBadge('University', user['uniVerified']),
                            const Spacer(),
                            Text('Joined ${user['created']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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