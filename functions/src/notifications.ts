import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {FieldValue} from "firebase-admin/firestore";
import {db} from "./lib/init";

/**
 * Delivers a real push notification for every doc written to
 * `notifications/{id}` — every writer in this codebase (transfers,
 * deposits, vendor approvals, ...) just writes the Firestore doc as before;
 * this is the one place that turns it into a push, so none of them need to
 * know about FCM. Tokens FCM reports as unregistered (uninstalled app,
 * expired token) are dropped instead of being retried forever.
 */
export const sendNotificationPush = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const notification = event.data?.data();
  if (!notification) return;

  const uid = notification.uid as string | undefined;
  const title = notification.title as string | undefined;
  if (!uid || !title) return;

  const userSnap = await db.collection("users").doc(uid).get();
  const tokens = (userSnap.data()?.fcmTokens as string[] | undefined) ?? [];
  if (tokens.length === 0) return;

  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: {
      title,
      body: (notification.detail as string | undefined) ?? "",
    },
    data: {
      notificationId: event.params.notificationId,
      type: (notification.type as string | undefined) ?? "",
    },
  });

  const staleTokens = response.responses
    .map((result, i) => (!result.success && result.error?.code === "messaging/registration-token-not-registered" ? tokens[i] : null))
    .filter((token): token is string => token !== null);

  if (staleTokens.length > 0) {
    await db.collection("users").doc(uid).update({
      fcmTokens: FieldValue.arrayRemove(...staleTokens),
    });
  }
});
