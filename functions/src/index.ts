import {onCall, HttpsError} from "firebase-functions/v2/https";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

const MAX_TRANSFER_AMOUNT = 100000; // $100,000 — sanity ceiling, not a real product limit.

interface TransferRequest {
  toUid: string;
  amount: number;
  note?: string;
  type?: "transfer" | "payment";
}

interface TransferResult {
  transactionId: string;
}

/**
 * Atomically moves money between two wallets and writes the ledger entry.
 * This is the only place wallet balances change — firestore.rules blocks
 * every client-side write to `wallets/{uid}.balance`, so this function
 * (running under the Admin SDK, which bypasses those rules) is the sole
 * path for real money movement.
 */
export const transferMoney = onCall<TransferRequest, Promise<TransferResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in to send money.");
  }

  const fromUid = auth.uid;
  const {toUid, amount, note, type} = request.data;

  if (typeof toUid !== "string" || toUid.length === 0) {
    throw new HttpsError("invalid-argument", "A recipient is required.");
  }
  if (toUid === fromUid) {
    throw new HttpsError("invalid-argument", "You can't send money to yourself.");
  }
  if (typeof amount !== "number" || !Number.isFinite(amount) || amount <= 0) {
    throw new HttpsError("invalid-argument", "Enter a valid amount.");
  }

  // Round to cents to avoid float noise, then re-validate against the ceiling.
  const cents = Math.round(amount * 100);
  if (cents <= 0 || cents > MAX_TRANSFER_AMOUNT * 100) {
    throw new HttpsError("invalid-argument", "Enter a valid amount.");
  }
  const safeAmount = cents / 100;
  const transferType = type === "payment" ? "payment" : "transfer";
  const description = typeof note === "string" ? note.slice(0, 300) : "";

  const fromUserRef = db.collection("users").doc(fromUid);
  const toUserRef = db.collection("users").doc(toUid);
  const fromWalletRef = db.collection("wallets").doc(fromUid);
  const toWalletRef = db.collection("wallets").doc(toUid);
  const transactionRef = db.collection("transactions").doc();

  return db.runTransaction(async (tx) => {
    const [fromUserSnap, toUserSnap, fromWalletSnap, toWalletSnap] = await Promise.all([
      tx.get(fromUserRef),
      tx.get(toUserRef),
      tx.get(fromWalletRef),
      tx.get(toWalletRef),
    ]);

    if (!fromUserSnap.exists) {
      throw new HttpsError("failed-precondition", "Your account could not be found.");
    }
    if (!toUserSnap.exists) {
      throw new HttpsError("not-found", "Recipient not found.");
    }

    const fromUserData = fromUserSnap.data()!;
    const toUserData = toUserSnap.data()!;

    if (fromUserData.accountStatus === "suspended") {
      throw new HttpsError("permission-denied", "Your account is suspended.");
    }
    if (toUserData.accountStatus === "suspended") {
      throw new HttpsError("failed-precondition", "Recipient's account is suspended.");
    }
    if (transferType === "payment") {
      if (toUserData.role !== "vendor") {
        throw new HttpsError("failed-precondition", "Recipient is not a vendor.");
      }
      if (toUserData.vendorStatus !== "approved") {
        throw new HttpsError("failed-precondition", "Vendor is not approved yet.");
      }
    }

    const fromBalance = (fromWalletSnap.data()?.balance as number | undefined) ?? 0;
    const toBalance = (toWalletSnap.data()?.balance as number | undefined) ?? 0;

    if (fromBalance < safeAmount) {
      throw new HttpsError("failed-precondition", "Insufficient balance.");
    }

    const now = Timestamp.now();

    tx.set(fromWalletRef, {balance: fromBalance - safeAmount, updatedAt: now}, {merge: true});
    tx.set(toWalletRef, {balance: toBalance + safeAmount, updatedAt: now}, {merge: true});
    tx.set(transactionRef, {
      fromUid,
      toUid,
      participants: [fromUid, toUid],
      fromName: (fromUserData.name as string | undefined) ?? "",
      toName: (toUserData.businessName as string | undefined) ?? (toUserData.name as string | undefined) ?? "",
      amount: safeAmount,
      type: transferType,
      status: "completed",
      createdAt: now,
      description,
    });

    return {transactionId: transactionRef.id};
  });
});
