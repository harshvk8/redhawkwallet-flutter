import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class AddFundsException implements Exception {
  final String message;
  const AddFundsException(this.message);

  @override
  String toString() => message;
}

class StripeService {
  final _functions = FirebaseFunctions.instance;

  /// Adds funds to the caller's wallet: creates a Stripe PaymentIntent via
  /// the `createStripePaymentIntent` Cloud Function, then presents Stripe's
  /// PaymentSheet for the user to enter a test card. Crediting the wallet
  /// happens asynchronously once Stripe's webhook confirms the charge
  /// (`confirmStripePayment`) — this call only proves the card was
  /// authorized, not that the balance has updated yet.
  Future<void> addFunds({required double amount}) async {
    final String clientSecret;
    try {
      final result = await _functions.httpsCallable('createStripePaymentIntent').call<Map<String, dynamic>>({
        'amount': amount,
      });
      clientSecret = result.data['clientSecret'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw AddFundsException(e.message ?? 'Could not start payment.');
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Red Hawk Wallet',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      final message = e.error.localizedMessage;
      if (e.error.code == FailureCode.Canceled) {
        throw const AddFundsException('Payment canceled.');
      }
      throw AddFundsException(message ?? 'Payment failed.');
    }
  }
}
