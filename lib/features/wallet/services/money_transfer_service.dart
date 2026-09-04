import 'package:cloud_functions/cloud_functions.dart';

class MoneyTransferException implements Exception {
  final String message;
  const MoneyTransferException(this.message);

  @override
  String toString() => message;
}

class MoneyTransferService {
  final _functions = FirebaseFunctions.instance;

  /// Calls the `transferMoney` Cloud Function for peer-to-peer sends — the
  /// only path that can move wallet balances between two users;
  /// firestore.rules blocks every client-side balance edit. For paying a
  /// vendor, use [payVendor] instead. Returns the id of the `transactions`
  /// doc the function created.
  Future<String> transfer({
    required String toUid,
    required double amount,
    String note = '',
  }) async {
    try {
      final result = await _functions.httpsCallable('transferMoney').call<Map<String, dynamic>>({
        'toUid': toUid,
        'amount': amount,
        'note': note,
      });
      return result.data['transactionId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw MoneyTransferException(e.message ?? 'Transfer failed.');
    }
  }

  /// Calls the `processPayment` Cloud Function — student → approved-vendor
  /// payments only. Returns the id of the `transactions` doc the function
  /// created.
  Future<String> payVendor({
    required String toUid,
    required double amount,
    String note = '',
  }) async {
    try {
      final result = await _functions.httpsCallable('processPayment').call<Map<String, dynamic>>({
        'toUid': toUid,
        'amount': amount,
        'note': note,
      });
      return result.data['transactionId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw MoneyTransferException(e.message ?? 'Payment failed.');
    }
  }

  /// Calls the `sendMoneyViaQr` Cloud Function — student → student payment
  /// initiated by scanning a Receive Money or Student ID QR code. Capped at
  /// $100/day server-side; a resource-exhausted error means that cap was hit.
  Future<String> sendMoneyViaQr({
    required String toUid,
    required double amount,
    String note = '',
  }) async {
    try {
      final result = await _functions.httpsCallable('sendMoneyViaQr').call<Map<String, dynamic>>({
        'toUid': toUid,
        'amount': amount,
        'note': note,
      });
      return result.data['transactionId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw MoneyTransferException(e.message ?? 'Payment failed.');
    }
  }
}
