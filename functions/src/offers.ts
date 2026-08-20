import {onCall, HttpsError} from "firebase-functions/v2/https";
import {FieldValue} from "firebase-admin/firestore";
import {db} from "./lib/init";

interface RedeemOfferRequest {
  offerId: string;
}

interface RedeemOfferResult {
  usedCount: number;
}

/**
 * Redemption goes exclusively through this function — firestore.rules no
 * longer lets a client bump `usedCount` directly, since that had no per-user
 * record and let anyone inflate an offer's redemption count by calling
 * update() in a loop. The per-uid redemption doc here is both the dedupe
 * check and the audit trail.
 */
export const redeemOffer = onCall<RedeemOfferRequest, Promise<RedeemOfferResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const {offerId} = request.data;
  if (typeof offerId !== "string" || offerId.length === 0) {
    throw new HttpsError("invalid-argument", "An offer is required.");
  }

  const offerRef = db.collection("offers").doc(offerId);
  const redemptionRef = offerRef.collection("redemptions").doc(auth.uid);

  const usedCount = await db.runTransaction(async (tx) => {
    const [offerSnap, redemptionSnap] = await Promise.all([tx.get(offerRef), tx.get(redemptionRef)]);
    if (!offerSnap.exists) {
      throw new HttpsError("not-found", "Offer not found.");
    }
    if (offerSnap.data()?.active !== true) {
      throw new HttpsError("failed-precondition", "This offer is no longer active.");
    }
    if (redemptionSnap.exists) {
      throw new HttpsError("already-exists", "You've already redeemed this offer.");
    }

    const nextCount = ((offerSnap.data()?.usedCount as number | undefined) ?? 0) + 1;
    tx.set(redemptionRef, {uid: auth.uid, redeemedAt: FieldValue.serverTimestamp()});
    tx.update(offerRef, {usedCount: nextCount});
    return nextCount;
  });

  return {usedCount};
});
