import {onCall, HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "./lib/init";

const MAX_TRANSFER_AMOUNT = 100000; // $100,000 — sanity ceiling, not a real product limit.
const QR_TRANSFER_DAILY_CAP = 100; // $100/day — safety rail on opportunistic QR-scan sends.
// 2% back in points on every Red Hawk Dollars spend, 1 point = $0.01 —
// perk redemption isn't designed yet, this is just the earning side.
const POINTS_PER_DOLLAR_SPENT = 2;

interface MoneyMoveResult {
  transactionId: string;
}

/** Midnight UTC of the given date — the reset boundary for the QR daily cap. */
function startOfUtcDay(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
}

/**
 * Atomically moves money between two wallets and writes the ledger entry.
 * This is the only place wallet balances change — firestore.rules blocks
 * every client-side write to `wallets/{uid}.balance`, so the callers below
 * (running under the Admin SDK, which bypasses those rules) are the sole
 * path for real money movement between users.
 */
async function moveMoney(opts: {
  fromUid: string;
  toUid: string;
  amount: number;
  note?: string;
  type: "transfer" | "payment" | "qr_transfer";
}): Promise<MoneyMoveResult> {
  const {fromUid, toUid, amount, note, type} = opts;

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
  const description = typeof note === "string" ? note.slice(0, 300) : "";

  const fromUserRef = db.collection("users").doc(fromUid);
  const toUserRef = db.collection("users").doc(toUid);
  const fromWalletRef = db.collection("wallets").doc(fromUid);
  const toWalletRef = db.collection("wallets").doc(toUid);
  const transactionRef = db.collection("transactions").doc();

  // Firestore transactions require all reads before any writes, so the
  // daily-cap query (only relevant for qr_transfer) has to happen up front
  // alongside the other reads rather than inline further down.
  const todaysQrSendsQuery = type === "qr_transfer" ?
    db.collection("transactions")
      .where("fromUid", "==", fromUid)
      .where("type", "==", "qr_transfer")
      .where("createdAt", ">=", Timestamp.fromDate(startOfUtcDay(new Date()))) :
    null;

  return db.runTransaction(async (tx) => {
    const [fromUserSnap, toUserSnap, fromWalletSnap, toWalletSnap, todaysQrSendsSnap] = await Promise.all([
      tx.get(fromUserRef),
      tx.get(toUserRef),
      tx.get(fromWalletRef),
      tx.get(toWalletRef),
      todaysQrSendsQuery ? tx.get(todaysQrSendsQuery) : Promise.resolve(null),
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
    if (type === "payment") {
      if (toUserData.role !== "vendor") {
        throw new HttpsError("failed-precondition", "Recipient is not a vendor.");
      }
      if (toUserData.vendorStatus !== "approved") {
        throw new HttpsError("failed-precondition", "Vendor is not approved yet.");
      }
    } else if (type === "qr_transfer") {
      if (toUserData.role !== "normal_user" && toUserData.role !== "verified_student") {
        throw new HttpsError("failed-precondition", "You can only send money via QR to another student.");
      }
    } else if (toUserData.role === "vendor") {
      // Peer transfers are user<->user only; vendor payments go through processPayment
      // so they always get the role/approval check above.
      throw new HttpsError("failed-precondition", "Use Pay Vendor to send money to a vendor.");
    }

    if (todaysQrSendsSnap) {
      const alreadySentToday = todaysQrSendsSnap.docs.reduce(
        (sum, doc) => sum + ((doc.data().amount as number | undefined) ?? 0),
        0
      );
      if (alreadySentToday + safeAmount > QR_TRANSFER_DAILY_CAP) {
        const remaining = Math.max(0, QR_TRANSFER_DAILY_CAP - alreadySentToday);
        throw new HttpsError(
          "resource-exhausted",
          `Daily QR transfer limit reached. You can send up to $${remaining.toFixed(2)} more today.`
        );
      }
    }

    const fromBalance = (fromWalletSnap.data()?.balance as number | undefined) ?? 0;
    const toBalance = (toWalletSnap.data()?.balance as number | undefined) ?? 0;
    const fromPoints = (fromWalletSnap.data()?.points as number | undefined) ?? 0;

    if (fromBalance < safeAmount) {
      throw new HttpsError("failed-precondition", "Insufficient balance.");
    }

    const now = Timestamp.now();
    const pointsEarned = Math.round(safeAmount * POINTS_PER_DOLLAR_SPENT);
    const fromName = (fromUserData.name as string | undefined) ?? "";
    const toName = (toUserData.businessName as string | undefined) ?? (toUserData.name as string | undefined) ?? "";

    tx.set(fromWalletRef, {balance: fromBalance - safeAmount, points: fromPoints + pointsEarned, updatedAt: now}, {merge: true});
    tx.set(toWalletRef, {balance: toBalance + safeAmount, updatedAt: now}, {merge: true});
    tx.set(transactionRef, {
      fromUid,
      toUid,
      participants: [fromUid, toUid],
      fromName,
      toName,
      amount: safeAmount,
      type,
      status: "completed",
      createdAt: now,
      description,
      pointsEarned,
    });

    tx.set(db.collection("notifications").doc(), {
      uid: fromUid,
      title: type === "payment" ? `Paid ${toName}` : `Sent \$${safeAmount.toFixed(2)}`,
      detail: `You sent \$${safeAmount.toFixed(2)} to ${toName}. +${pointsEarned} points earned!`,
      type: "transaction",
      transactionId: transactionRef.id,
      read: false,
      createdAt: now,
    });
    tx.set(db.collection("notifications").doc(), {
      uid: toUid,
      title: `You received \$${safeAmount.toFixed(2)}`,
      detail: `${fromName} sent you \$${safeAmount.toFixed(2)}.`,
      type: "transaction",
      transactionId: transactionRef.id,
      read: false,
      createdAt: now,
    });

    return {transactionId: transactionRef.id};
  });
}

interface TransferRequest {
  toUid: string;
  amount: number;
  note?: string;
}

/** Peer-to-peer money transfer between two users. Not for vendor payments — see processPayment. */
export const transferMoney = onCall<TransferRequest, Promise<MoneyMoveResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in to send money.");
  }
  return moveMoney({fromUid: auth.uid, ...request.data, type: "transfer"});
});

interface ProcessPaymentRequest {
  toUid: string;
  amount: number;
  note?: string;
}

/**
 * Student → vendor payment. Requires the recipient to be an approved
 * vendor — kept separate from transferMoney so peer sends and vendor
 * payments get independently-tuned validation instead of branching on a
 * client-supplied type.
 */
export const processPayment = onCall<ProcessPaymentRequest, Promise<MoneyMoveResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in to pay.");
  }
  return moveMoney({fromUid: auth.uid, ...request.data, type: "payment"});
});

interface SendMoneyViaQrRequest {
  toUid: string;
  amount: number;
  note?: string;
}

/**
 * Student → student payment initiated by scanning a Receive Money or
 * Student ID QR code. Capped at $100/day (UTC) since QR scans are more
 * opportunistic/social-pressure-prone than the deliberate Send Money flow,
 * which has no such cap. Always moves Red Hawk Dollars (wallets.balance) —
 * same as every other money-moving function here.
 */
export const sendMoneyViaQr = onCall<SendMoneyViaQrRequest, Promise<MoneyMoveResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in to send money.");
  }
  return moveMoney({fromUid: auth.uid, ...request.data, type: "qr_transfer"});
});
