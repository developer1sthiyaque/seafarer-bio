import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

export interface RevenueCatEvent {
  id: string;
  type: string;
  app_user_id: string;
  original_app_user_id?: string;
  aliases?: string[];
  product_id?: string;
  purchased_at_ms?: number;
  expiration_at_ms?: number | null;
  event_timestamp_ms?: number;
  environment?: string;
  entitlement_id?: string | null;
  entitlement_ids?: string[] | null;
  cancel_reason?: string | null;
}

export interface RevenueCatWebhookPayload {
  api_version: string;
  event: RevenueCatEvent;
}

export interface WebhookRequest {
  method?: string;
  headers: Record<string, string | string[] | undefined>;
  body: any;
}

export interface WebhookResponse {
  status: (code: number) => { send: (body: string) => void };
}

export async function processWebhook(
  req: WebhookRequest,
  res: WebhookResponse,
  firestoreDb: admin.firestore.Firestore = db,
  expectedSecret?: string
): Promise<void> {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  // 1. Verify Authorization Header (supporting Bearer and raw secret)
  const secret = (expectedSecret ?? process.env.REVENUECAT_WEBHOOK_AUTH)?.trim();
  const rawAuth = Array.isArray(req.headers.authorization)
    ? req.headers.authorization[0]
    : req.headers.authorization;
  const incomingAuth = rawAuth?.replace(/^Bearer\s+/i, "").trim();

  if (!secret || incomingAuth !== secret) {
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
  let uid = event.app_user_id;

  // Resolve aliased or original UID if primary app_user_id is anonymous
  if (!uid || uid.startsWith("$RCAnonymousID")) {
    if (event.original_app_user_id && !event.original_app_user_id.startsWith("$RCAnonymousID")) {
      uid = event.original_app_user_id;
    } else if (Array.isArray(event.aliases)) {
      const nonAnon = event.aliases.find((a) => a && !a.startsWith("$RCAnonymousID"));
      if (nonAnon) {
        uid = nonAnon;
      }
    }
  }

  // 2. Ignore unresolved anonymous RevenueCat user IDs
  if (!uid || uid.startsWith("$RCAnonymousID")) {
    functions.logger.info(`Ignoring anonymous or missing app_user_id: ${event.app_user_id}`);
    res.status(200).send("Ignored anonymous user");
    return;
  }

  const userRef = firestoreDb.collection("users").doc(uid);
  const profileRef = firestoreDb.collection("profiles").doc(uid);

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
      if (eventTimestamp < storedUpdatedAtMs) {
        functions.logger.info(
          `Ignoring outdated event for ${uid}. Event ts: ${eventTimestamp}, stored ts: ${storedUpdatedAtMs}`
        );
        res.status(200).send("Event ignored (outdated)");
        return;
      }
    }

    // 4. Handle Entitlement & Event Types
    const entitlementIds: string[] = [
      ...(Array.isArray(event.entitlement_ids) ? event.entitlement_ids : []),
      ...(event.entitlement_id ? [event.entitlement_id] : []),
    ];

    if (eventType === "BILLING_ISSUE") {
      functions.logger.warn(`Billing issue detected for user ${uid}. Grace period active; retaining status.`);
      res.status(200).send("Logged billing issue");
      return;
    }

    let isPremium = false;
    let willRenew = false;
    const now = Date.now();

    switch (eventType) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "PRODUCT_CHANGE":
      case "UNCANCELLATION":
      case "NON_RENEWING_PURCHASE":
      case "TEMPORARY_ENTITLEMENT_GRANT":
        // Only grant premium if the entitlement is 'premium' (or unspecified test event)
        if (entitlementIds.length > 0 && !entitlementIds.includes("premium")) {
          functions.logger.info(
            `Ignoring purchase event without 'premium' entitlement for ${uid}: [${entitlementIds.join(", ")}]`
          );
          res.status(200).send("Ignored non-premium entitlement");
          return;
        }
        isPremium = true;
        willRenew = eventType !== "NON_RENEWING_PURCHASE";
        break;

      case "CANCELLATION":
        // Keep access until current billing period ends
        isPremium = expirationMs !== null ? expirationMs > now : false;
        willRenew = false;
        break;

      case "EXPIRATION":
      case "REVOCATION":
      case "REFUND":
        isPremium = false;
        willRenew = false;
        break;

      default:
        functions.logger.info(`Ignorable event type: ${eventType} for ${uid}`);
        res.status(200).send(`Ignored event type: ${eventType}`);
        return;
    }

    const updateData: Record<string, any> = {
      isPremium,
      premiumExpiresAt: expirationMs ? admin.firestore.Timestamp.fromMillis(expirationMs) : null,
      premiumProductId: productId,
      premiumWillRenew: willRenew,
      premiumEnvironment: event.environment ?? "PRODUCTION",
      premiumUpdatedAt: admin.firestore.Timestamp.fromMillis(eventTimestamp),
    };

    const batch = firestoreDb.batch();
    batch.set(userRef, updateData, { merge: true });
    batch.set(profileRef, updateData, { merge: true });

    await batch.commit();

    functions.logger.info(
      `Firestore write complete for ${uid}: isPremium=${isPremium}, type=${eventType}, product=${productId}, env=${updateData.premiumEnvironment}`
    );
    res.status(200).send("OK");
  } catch (error) {
    functions.logger.error("Error processing RevenueCat webhook:", error);
    res.status(500).send("Internal Server Error");
  }
}

export const revenuecatWebhook = functions
  .runWith({
    secrets: ["REVENUECAT_WEBHOOK_AUTH"],
  })
  .https.onRequest(async (req, res) => {
    await processWebhook(req, res, db, process.env.REVENUECAT_WEBHOOK_AUTH);
  });

