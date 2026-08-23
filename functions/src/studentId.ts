import {onCall, HttpsError} from "firebase-functions/v2/https";
import {randomBytes} from "crypto";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "./lib/init";

const TOKEN_TTL_SECONDS = 90;

interface IssueTokenResult {
  token: string;
  expiresAt: number; // epoch millis
}

/**
 * Mints a short-lived, server-issued token proving who the caller is, for
 * display as a rotating QR code on the student's own ID screen. The token
 * (not the raw uid/email) is what's encoded in the QR — a future verifier
 * looks it up here rather than trusting whatever identity data a scanned
 * QR claims, so a forged/replayed QR can't impersonate a student.
 */
export const issueStudentIdToken = onCall<void, Promise<IssueTokenResult>>(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const userSnap = await db.collection("users").doc(auth.uid).get();
  if (!userSnap.exists) {
    throw new HttpsError("failed-precondition", "Your account could not be found.");
  }
  const userData = userSnap.data()!;

  const token = randomBytes(24).toString("hex");
  const now = Timestamp.now();
  const expiresAt = Timestamp.fromMillis(now.toMillis() + TOKEN_TTL_SECONDS * 1000);

  await db.collection("studentIdTokens").doc(token).set({
    uid: auth.uid,
    name: (userData.name as string | undefined) ?? "",
    email: (userData.email as string | undefined) ?? "",
    isUniversityVerified: (userData.isUniversityVerified as boolean | undefined) ?? false,
    createdAt: now,
    expiresAt,
  });

  return {token, expiresAt: expiresAt.toMillis()};
});
