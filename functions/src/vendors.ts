import {onCall, HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "./lib/init";

interface ApproveVendorRequest {
  vendorUid: string;
  decision: "approve" | "reject";
}

interface ApproveVendorResult {
  vendorStatus: "approved" | "rejected";
}

/**
 * Vendor approval/rejection goes exclusively through this function —
 * firestore.rules no longer lets admins write `vendorStatus` directly from
 * the client, so this Admin-SDK path is the only way that field changes.
 */
export const approveVendor = onCall<ApproveVendorRequest, Promise<ApproveVendorResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerSnap = await db.collection("users").doc(auth.uid).get();
  if (callerSnap.data()?.role !== "admin") {
    throw new HttpsError("permission-denied", "Only an admin can approve vendors.");
  }

  const {vendorUid, decision} = request.data;
  if (typeof vendorUid !== "string" || vendorUid.length === 0) {
    throw new HttpsError("invalid-argument", "A vendor is required.");
  }
  if (decision !== "approve" && decision !== "reject") {
    throw new HttpsError("invalid-argument", "Decision must be approve or reject.");
  }

  const vendorRef = db.collection("users").doc(vendorUid);
  const vendorSnap = await vendorRef.get();
  if (!vendorSnap.exists) {
    throw new HttpsError("not-found", "Vendor not found.");
  }
  if (vendorSnap.data()?.role !== "vendor") {
    throw new HttpsError("failed-precondition", "That account is not a vendor.");
  }

  const vendorStatus = decision === "approve" ? "approved" : "rejected";
  const now = Timestamp.now();
  await vendorRef.update({
    vendorStatus,
    accountStatus: "active",
    updatedAt: now,
  });
  await db.collection("notifications").add({
    uid: vendorUid,
    title: vendorStatus === "approved" ? "Vendor application approved" : "Vendor application declined",
    detail: vendorStatus === "approved" ?
      "You're approved! You can now accept payments." :
      "Your vendor application was declined.",
    type: "vendor_status",
    read: false,
    createdAt: now,
  });

  return {vendorStatus};
});
