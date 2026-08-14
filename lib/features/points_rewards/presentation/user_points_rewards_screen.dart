import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserPointsRewardsScreen extends StatelessWidget {
  const UserPointsRewardsScreen({super.key});

  final List<Map<String, dynamic>> rewards = const [
    {'title': 'Free Coffee', 'points': 300, 'icon': Icons.local_cafe, 'available': false},
    {'title': '\$5 Off Any Purchase', 'points': 500, 'icon': Icons.discount, 'available': false},
    {'title': 'Free Meal Swipe', 'points': 750, 'icon': Icons.restaurant, 'available': false},
    {'title': '\$10 Bonus Dollars', 'points': 1000, 'icon': Icons.card_giftcard, 'available': false},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const int currentPoints = 250;
    const int nextRewardPoints = 300;
    const double progress = currentPoints / nextRewardPoints;

    final canPop = context.canPop();
    void goBack() {
      if (canPop) {
        context.pop();
      } else {
        context.go('/home');
      }
    }

    return PopScope(
      // Let the pop actually happen when there's something to pop — this
      // must not be unconditionally false, or the fallback below vetoes
      // its own context.pop() call and neither the button nor the system
      // back gesture can ever complete a pop.
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Points & Rewards'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: goBack,
          ),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  const Text('Your Points', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const Text('250', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Next reward at 300 points', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('50 more points to go', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Available Rewards', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
            ),
            const SizedBox(height: 12),
            ...rewards.map((reward) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(reward['icon'] as IconData, color: cs.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reward['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                        Text('${reward['points']} points required', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: reward['available'] as bool ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: cs.surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Redeem', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
      ),
    );
  }
}
