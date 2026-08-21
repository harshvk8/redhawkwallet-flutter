import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserOffersScreen extends StatefulWidget {
  const UserOffersScreen({super.key});

  @override
  State<UserOffersScreen> createState() => _UserOffersScreenState();
}

class _UserOffersScreenState extends State<UserOffersScreen> {
  static const _colors = [
    Color(0xFF8B1A2E),
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.teal,
  ];

  // .snapshots() below returns a fresh Stream instance each time this widget
  // rebuilds, so just forcing a rebuild is enough to tear down a stuck
  // subscription and open a brand new one — the only way to recover from a
  // dead listener short of restarting the whole app.
  Future<void> _refresh() async => setState(() {});

  // Goes through redeemOffer rather than writing usedCount directly —
  // firestore.rules no longer allows that write, since it had no per-user
  // record and let anyone inflate the count by calling update() in a loop.
  Future<void> _redeem(
    BuildContext context,
    String offerId,
    String title,
  ) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('redeemOffer')
          .call<Map<String, dynamic>>({'offerId': offerId});
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (context.mounted && uid != null) {
        _openRedemptionScreen(context, offerId, uid, title);
      }
    } on FirebaseFunctionsException catch (e) {
      // Already redeemed isn't really a failure from the student's point of
      // view — they still need to be able to pull the QR back up to show
      // the vendor, and verifyOfferRedemption already handles a rescanned
      // code gracefully (flags it "Already Redeemed" instead of erroring).
      if (e.code == 'already-exists') {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (context.mounted && uid != null) {
          _openRedemptionScreen(context, offerId, uid, title);
        }
        return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Could not redeem this offer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // A toast alone gives the student nothing durable to show once it fades —
  // a full screen (not a dialog — a dialog rendered blank/invisible on some
  // builds) stays up until they navigate away, and the vendor scans it (via
  // verifyOfferRedemption) rather than trusting a claimed screenshot, same
  // pattern as the payment-request and student-ID QR flows.
  void _openRedemptionScreen(BuildContext context, String offerId, String uid, String title) {
    context.push('/offers/redemption', extra: {'offerId': offerId, 'uid': uid, 'title': title});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: 'Back',
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Offers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Offers',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'From every approved vendor on campus',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('offers')
                    .where('active', isEqualTo: true)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        children: [
                          const SizedBox(height: 80),
                          const Center(child: Text('Failed to load offers.')),
                          const SizedBox(height: 12),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              'No offers available right now — check back soon!',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final offer = doc.data() as Map<String, dynamic>;
                        final color = _colors[index % _colors.length];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    offer['discount'] as String? ?? '',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer['title'] as String? ?? '',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      offer['vendorName'] as String? ?? '',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    if ((offer['description'] as String?)
                                            ?.isNotEmpty ==
                                        true) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        offer['description'] as String,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 84,
                                child: ElevatedButton(
                                  onPressed: () => _redeem(
                                    context,
                                    doc.id,
                                    offer['title'] as String? ?? 'offer',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Redeem',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
}
