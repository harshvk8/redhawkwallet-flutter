import 'package:cloud_functions/cloud_functions.dart';

class MoneyTransferException implements Exception {
  final String message;
  const MoneyTransferException(this.message);

  @override
  String toString() => message;
}

class MoneyTransferService {
  final _functions = FirebaseFunctions.instance;

  /// Calls the `transferMoney` Cloud Function, the only path that can move
  /// wallet balances — firestore.rules blocks every client-side balance edit.
  /// Returns the id of the `transactions` doc the function created.
  Future<String> transfer({
    required String toUid,
    required double amount,
    String note = '',
    String type = 'transfer',
  }) async {
    try {
      final result = await _functions.httpsCallable('transferMoney').call<Map<String, dynamic>>({
        'toUid': toUid,
        'amount': amount,
        'note': note,
        'type': type,
      });
      return result.data['transactionId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw MoneyTransferException(e.message ?? 'Transfer failed.');
    }
  }
}
