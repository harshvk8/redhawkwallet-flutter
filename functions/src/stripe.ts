import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {Timestamp} from "firebase-admin/firestore";
import Stripe from "stripe";
import {db} from "./lib/init";

// Set with `firebase functions:secrets:set STRIPE_SECRET_KEY` /
// `STRIPE_WEBHOOK_SECRET` before deploying — never committed.
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

const MIN_TOPUP = 1; // $1 — matches the Add Money screen's minimum deposit.
const MAX_TOPUP = 2000; // $2,000 — sandbox sanity ceiling.

interface CreateIntentRequest {
  amount: number;
}

interface CreateIntentResult {
  clientSecret: string;
}

/** Starts a card top-up: creates a Stripe PaymentIntent the client confirms via PaymentSheet. */
export const createStripePaymentIntent = onCall<CreateIntentRequest, Promise<CreateIntentResult>>(
  {secrets: [stripeSecretKey]},
  async (request) => {
    const auth = request.auth;
    if (!auth) {
      throw new HttpsError("unauthenticated", "You must be signed in to add funds.");
    }

    const {amount} = request.data;
    if (typeof amount !== "number" || !Number.isFinite(amount) || amount < MIN_TOPUP || amount > MAX_TOPUP) {
      throw new HttpsError("invalid-argument", `Enter an amount between $${MIN_TOPUP} and $${MAX_TOPUP}.`);
    }

    const stripe = new Stripe(stripeSecretKey.value());
    const intent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency: "usd",
      metadata: {uid: auth.uid},
      automatic_payment_methods: {enabled: true},
    });

    if (!intent.client_secret) {
      throw new HttpsError("internal", "Could not start payment.");
    }
    return {clientSecret: intent.client_secret};
  }
);

/**
 * Stripe webhook target — the source of truth for crediting a wallet.
 * Only a signature-verified event from Stripe (not the client's
 * "PaymentSheet succeeded" callback) proves the card actually charged, so
 * this is the only place a top-up ever touches wallet balance. Register
 * this function's deployed URL as the endpoint in the Stripe dashboard to
 * get the value for STRIPE_WEBHOOK_SECRET.
 */
export const confirmStripePayment = onRequest(
  {secrets: [stripeSecretKey, stripeWebhookSecret]},
  async (req, res) => {
    const signature = req.headers["stripe-signature"];
    if (!signature) {
      res.status(400).send("Missing signature");
      return;
    }

    const stripe = new Stripe(stripeSecretKey.value());
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(req.rawBody, signature, stripeWebhookSecret.value());
    } catch (err) {
      res.status(400).send(`Webhook signature verification failed: ${err}`);
      return;
    }

    if (event.type !== "payment_intent.succeeded") {
      res.status(200).send("ignored");
      return;
    }

    const intent = event.data.object as Stripe.PaymentIntent;
    const uid = intent.metadata?.uid;
    if (!uid) {
      res.status(200).send("no uid in metadata");
      return;
    }
    const amount = intent.amount_received / 100;

    // Idempotency — Stripe retries webhook deliveries, so skip if this
    // PaymentIntent was already credited.
    const existing = await db.collection("transactions")
      .where("stripePaymentIntentId", "==", intent.id)
      .limit(1)
      .get();
    if (!existing.empty) {
      res.status(200).send("already processed");
      return;
    }

    const userSnap = await db.collection("users").doc(uid).get();
    const userName = (userSnap.data()?.name as string | undefined) ?? "";
    const walletRef = db.collection("wallets").doc(uid);
    const transactionRef = db.collection("transactions").doc();

    await db.runTransaction(async (tx) => {
      const walletSnap = await tx.get(walletRef);
      const balance = (walletSnap.data()?.balance as number | undefined) ?? 0;
      const now = Timestamp.now();
      tx.set(walletRef, {balance: balance + amount, updatedAt: now}, {merge: true});
      tx.set(transactionRef, {
        fromUid: "stripe",
        toUid: uid,
        participants: [uid],
        fromName: "Stripe",
        toName: userName,
        amount,
        type: "deposit",
        status: "completed",
        createdAt: now,
        description: "Added via card",
        stripePaymentIntentId: intent.id,
      });
      tx.set(db.collection("notifications").doc(), {
        uid,
        title: `Wallet topped up`,
        detail: `\$${amount.toFixed(2)} was added to your wallet.`,
        type: "deposit",
        transactionId: transactionRef.id,
        read: false,
        createdAt: now,
      });
    });

    res.status(200).send("ok");
  }
);
