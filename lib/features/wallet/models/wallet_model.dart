import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String uid;
  final double balance;
  final int points;
  final DateTime updatedAt;

  const WalletModel({
    required this.uid,
    required this.balance,
    required this.points,
    required this.updatedAt,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      uid: doc.id,
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      points: data['points'] as int? ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'balance': balance,
        'points': points,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
