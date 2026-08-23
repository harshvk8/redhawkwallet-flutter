import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/config/stripe_config.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // flutter_stripe has no web implementation — applySettings() throws
  // MissingPluginException there. Even on supported platforms, a failure
  // here (bad key, native init error) shouldn't take the whole app down;
  // only Stripe-dependent screens need it to have succeeded.
  if (!kIsWeb) {
    try {
      Stripe.publishableKey = stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe initialization failed: $e');
    }
  }
  runApp(const RedHawkWalletApp());
}
