import 'dart:async';

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
      final result = await _functions
          .httpsCallable('createStripePaymentIntent')
          .call<Map<String, dynamic>>({'amount': amount}).timeout(const Duration(seconds: 20));
      clientSecret = result.data['clientSecret'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw AddFundsException(e.message ?? 'Could not start payment.');
    } on TimeoutException {
      throw const AddFundsException('The payment server took too long to respond. Please try again.');
    }

    try {
      // initPaymentSheet/presentPaymentSheet drive Stripe's own native UI
      // (including its Radar fraud check, which can briefly show a
      // challenge) — a generous timeout here is a safety net against that
      // hanging indefinitely, not a normal-path expectation.
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              merchantDisplayName: 'Red Hawk Wallet',
            ),
          )
          .timeout(const Duration(seconds: 30));
      await Stripe.instance.presentPaymentSheet().timeout(const Duration(minutes: 5));
    } on StripeException catch (e) {
      final message = e.error.localizedMessage;
      if (e.error.code == FailureCode.Canceled) {
        throw const AddFundsException('Payment canceled.');
      }
      throw AddFundsException(message ?? 'Payment failed.');
    } on TimeoutException {
      throw const AddFundsException('The payment sheet took too long to load. Please try again.');
    }
  }
}
