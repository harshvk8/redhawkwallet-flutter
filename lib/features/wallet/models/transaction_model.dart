import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String fromUid;
  final String toUid;
  final String fromName;
  final String toName;
  final double amount;
  final String type; // top_up / payment / transfer
  final String status; // pending / completed / failed
  final DateTime createdAt;
  final String description;

  const TransactionModel({
    required this.id,
    required this.fromUid,
    required this.toUid,
    this.fromName = '',
    this.toName = '',
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.description,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      fromUid: data['fromUid'] as String? ?? '',
      toUid: data['toUid'] as String? ?? '',
      fromName: data['fromName'] as String? ?? '',
      toName: data['toName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] as String? ?? 'payment',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'toUid': toUid,
        'fromName': fromName,
        'toName': toName,
        'amount': amount,
        'type': type,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'description': description,
      };
}
