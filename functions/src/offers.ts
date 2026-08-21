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

interface VerifyOfferRedemptionRequest {
  offerId: string;
  uid: string;
}

interface VerifyOfferRedemptionResult {
  studentName: string;
  offerTitle: string;
  redeemedAt: string;
  alreadyVerified: boolean;
}

/**
 * Called by a vendor scanning a student's redemption QR. Looks up the
 * redemption doc redeemOffer already wrote server-side rather than trusting
 * the offerId/uid encoded in the QR on their own — that's just a pointer,
 * same reasoning as the studentId QR flow. Restricted to the offer's own
 * vendor (or admin) so a QR can't be verified against the wrong business.
 * First scan stamps verifiedAt as a light anti-replay signal; later scans
 * still succeed but come back flagged so the vendor can catch a reused QR.
 */
export const verifyOfferRedemption = onCall<VerifyOfferRedemptionRequest, Promise<VerifyOfferRedemptionResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const {offerId, uid} = request.data;
  if (typeof offerId !== "string" || offerId.length === 0 || typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "A redemption code is required.");
  }

  const offerRef = db.collection("offers").doc(offerId);
  const redemptionRef = offerRef.collection("redemptions").doc(uid);

  const [offerSnap, redemptionSnap] = await Promise.all([offerRef.get(), redemptionRef.get()]);
  if (!offerSnap.exists) {
    throw new HttpsError("not-found", "Offer not found.");
  }

  const callerSnap = await db.collection("users").doc(auth.uid).get();
  const isAdmin = callerSnap.data()?.role === "admin";
  if (offerSnap.data()?.vendorUid !== auth.uid && !isAdmin) {
    throw new HttpsError("permission-denied", "This offer belongs to a different vendor.");
  }

  if (!redemptionSnap.exists) {
    throw new HttpsError("not-found", "This redemption code is invalid.");
  }

  const redemptionData = redemptionSnap.data()!;
  const alreadyVerified = redemptionData.verifiedAt !== undefined;
  if (!alreadyVerified) {
    await redemptionRef.update({verifiedAt: FieldValue.serverTimestamp(), verifiedBy: auth.uid});
  }

  const studentSnap = await db.collection("users").doc(uid).get();
  const studentName = (studentSnap.data()?.name as string | undefined) ?? "Student";
  const redeemedAt = (redemptionData.redeemedAt?.toDate() as Date | undefined) ?? new Date();

  return {
    studentName,
    offerTitle: (offerSnap.data()?.title as string | undefined) ?? "Offer",
    redeemedAt: redeemedAt.toISOString(),
    alreadyVerified,
  };
});
