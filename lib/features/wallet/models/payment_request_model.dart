import 'package:cloud_firestore/cloud_firestore.dart';

/// Prefix for the QR code payload so the scanner can tell a Red Hawk Wallet
/// payment request apart from an arbitrary QR code someone might scan.
const String _qrPrefix = 'redhawkwallet:pay:';

class PaymentRequestModel {
  final String id;
  final String vendorUid;
  final String vendorName;
  final double amount;
  final double? originalAmount;
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
    this.originalAmount,
    required this.note,
    required this.discount,
    required this.status,
    this.studentUid,
    this.studentName,
    this.transactionId,
    required this.createdAt,
    this.paidAt,
  });

  /// True when a discount actually reduced the charged amount below the
  /// vendor's originally-entered price (non-percentage discounts like "Buy 1
  /// Get 1" don't change `amount`, so this stays false for those).
  bool get hasDiscount => originalAmount != null && originalAmount! > amount;

  factory PaymentRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentRequestModel(
      id: doc.id,
      vendorUid: data['vendorUid'] as String? ?? '',
      vendorName: data['vendorName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      originalAmount: (data['originalAmount'] as num?)?.toDouble(),
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

  /// The string encoded into the vendor-facing QR code for this request.
  String get qrPayload => '$_qrPrefix$id';

  /// Extracts the request id from a scanned QR value, or null if it's not
  /// a Red Hawk Wallet payment QR.
  static String? requestIdFromQr(String value) =>
      value.startsWith(_qrPrefix) ? value.substring(_qrPrefix.length) : null;

  Map<String, dynamic> toMap() => {
        'vendorUid': vendorUid,
        'vendorName': vendorName,
        'amount': amount,
        'originalAmount': originalAmount,
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
