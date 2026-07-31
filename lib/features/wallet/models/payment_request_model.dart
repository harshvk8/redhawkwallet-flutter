import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRequestModel {
  final String id;
  final String vendorUid;
  final String vendorName;
  final double amount;
  final String note;
  final String discount;
  final String status; // pending / paid / cancelled
  final String? studentUid;
  final String? studentName;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? paidAt;

  const PaymentRequestModel({
    required this.id,
    required this.vendorUid,
    required this.vendorName,
    required this.amount,
    required this.note,
    required this.discount,
    required this.status,
    this.studentUid,
    this.studentName,
    this.transactionId,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentRequestModel(
      id: doc.id,
      vendorUid: data['vendorUid'] as String? ?? '',
      vendorName: data['vendorName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      note: data['note'] as String? ?? '',
      discount: data['discount'] as String? ?? 'No Discount',
      status: data['status'] as String? ?? 'pending',
      studentUid: data['studentUid'] as String?,
      studentName: data['studentName'] as String?,
      transactionId: data['transactionId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'vendorUid': vendorUid,
        'vendorName': vendorName,
        'amount': amount,
        'note': note,
        'discount': discount,
        'status': status,
        'studentUid': studentUid,
        'studentName': studentName,
        'transactionId': transactionId,
        'createdAt': Timestamp.fromDate(createdAt),
        'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      };
}
