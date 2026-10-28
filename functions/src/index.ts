import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

interface RevenueCatEvent {
  id: string;
  type: string;
  app_user_id: string;
  original_app_user_id?: string;
  product_id?: string;
  purchased_at_ms?: number;
  expiration_at_ms?: number | null;
  event_timestamp_ms?: number;
  environment?: string;
  entitlement_id?: string | null;
  entitlement_ids?: string[] | null;
  cancel_reason?: string | null;
}

interface RevenueCatWebhookPayload {
  api_version: string;
  event: RevenueCatEvent;
}

export const revenuecatWebhook = functions
  .runWith({
    secrets: ["REVENUECAT_WEBHOOK_AUTH"],
  })
  .https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    // 1. Verify Authorization Header
    const expectedAuth = process.env.REVENUECAT_WEBHOOK_AUTH;
    const incomingAuth = req.headers.authorization;

    if (!expectedAuth || incomingAuth !== expectedAuth) {
      functions.logger.warn("Unauthorized webhook request received.");
      res.status(401).send("Unauthorized");
      return;
    }

    const payload = req.body as RevenueCatWebhookPayload;
    if (!payload || !payload.event) {
      res.status(400).send("Bad Request: Missing event payload");
      return;
    }

    const event = payload.event;
    const uid = event.app_user_id;

    // 2. Ignore anonymous RevenueCat user IDs
    if (!uid || uid.startsWith("$RCAnonymousID")) {
      functions.logger.info(`Ignoring anonymous or missing app_user_id: ${uid}`);
      res.status(200).send("Ignored anonymous user");
      return;
    }

    const userRef = db.collection("users").doc(uid);
    const profileRef = db.collection("profiles").doc(uid);

    const eventTimestamp = event.event_timestamp_ms ?? Date.now();
    const eventType = event.type;
    const productId = event.product_id ?? "unknown";
    const expirationMs = event.expiration_at_ms ?? null;

    try {
      // 3. Idempotency Check: Ignore events older than stored premiumUpdatedAt
      const userDoc = await userRef.get();
      const existingData = userDoc.data();

      if (existingData?.premiumUpdatedAt) {
        const storedUpdatedAtMs = existingData.premiumUpdatedAt.toMillis();
        if (eventTimestamp <= storedUpdatedAtMs) {
          functions.logger.info(
            `Ignoring outdated or duplicate event for ${uid}. Event ts: ${eventTimestamp}, stored ts: ${storedUpdatedAtMs}`
          );
          res.status(200).send("Event ignored (outdated)");
          return;
        }
      }

      // 4. Determine isPremium based on event type
      let isPremium = false;
      const now = Date.now();

      switch (eventType) {
        case "INITIAL_PURCHASE":
        case "RENEWAL":
        case "PRODUCT_CHANGE":
        case "UNCANCELLATION":
          isPremium = true;
          break;

        case "CANCELLATION":
        case "BILLING_ISSUE":
          // User may have cancelled renewal but still retains access until period ends
          isPremium = expirationMs !== null ? expirationMs > now : false;
          break;

        case "EXPIRATION":
        case "REVOCATION":
        case "REFUND":
          isPremium = false;
          break;

        default:
          functions.logger.info(`Unhandled event type: ${eventType}`);
          isPremium = expirationMs !== null ? expirationMs > now : false;
          break;
      }

      const updateData = {
        isPremium,
        premiumExpiresAt: expirationMs ? admin.firestore.Timestamp.fromMillis(expirationMs) : null,
        premiumProductId: productId,
        premiumUpdatedAt: admin.firestore.Timestamp.fromMillis(eventTimestamp),
      };

      const batch = db.batch();
      batch.set(userRef, updateData, { merge: true });
      batch.set(profileRef, updateData, { merge: true });

      await batch.commit();

      functions.logger.info(
        `Successfully updated user ${uid}: isPremium=${isPremium}, type=${eventType}, product=${productId}`
      );
      res.status(200).send("OK");
    } catch (error) {
      functions.logger.error("Error processing RevenueCat webhook:", error);
      res.status(500).send("Internal Server Error");
    }
  });
