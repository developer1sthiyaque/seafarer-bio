import { processWebhook, RevenueCatWebhookPayload } from "../index";
import * as admin from "firebase-admin";

describe("RevenueCat Webhook Handler", () => {
  const secretKey = "test-secret-key-12345";
  let mockRes: {
    statusCode: number;
    responseBody: string;
    status: jest.Mock;
    send: jest.Mock;
  };

  let mockBatch: {
    set: jest.Mock;
    commit: jest.Mock;
  };

  let mockUserDocData: Record<string, any> | undefined;
  let mockUserDoc: {
    get: jest.Mock;
  };

  let mockDb: any;

  beforeEach(() => {
    mockRes = {
      statusCode: 200,
      responseBody: "",
      status: jest.fn().mockImplementation((code: number) => {
        mockRes.statusCode = code;
        return {
          send: jest.fn().mockImplementation((body: string) => {
            mockRes.responseBody = body;
          }),
        };
      }),
      send: jest.fn().mockImplementation((body: string) => {
        mockRes.responseBody = body;
      }),
    };

    mockBatch = {
      set: jest.fn(),
      commit: jest.fn().mockResolvedValue(undefined),
    };

    mockUserDocData = undefined;
    mockUserDoc = {
      get: jest.fn().mockImplementation(async () => ({
        exists: mockUserDocData !== undefined,
        data: () => mockUserDocData,
      })),
    };

    mockDb = {
      collection: jest.fn().mockImplementation((collName: string) => ({
        doc: jest.fn().mockImplementation((docId: string) => {
          if (collName === "users") {
            return mockUserDoc;
          }
          return {
            id: docId,
            path: `${collName}/${docId}`,
          };
        }),
      })),
      batch: jest.fn().mockReturnValue(mockBatch),
    };
  });

  describe("Authentication", () => {
    test("returns 401 when Authorization header is missing", async () => {
      const req = {
        method: "POST",
        headers: {},
        body: {},
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockBatch.commit).not.toHaveBeenCalled();
    });

    test("returns 401 when Authorization header does not match", async () => {
      const req = {
        method: "POST",
        headers: { authorization: "wrong-secret" },
        body: {},
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockBatch.commit).not.toHaveBeenCalled();
    });

    test("returns 405 for non-POST methods", async () => {
      const req = {
        method: "GET",
        headers: { authorization: secretKey },
        body: {},
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(405);
      expect(mockBatch.commit).not.toHaveBeenCalled();
    });
  });

  describe("Anonymous User Filtering", () => {
    test("ignores anonymous users starting with $RCAnonymousID", async () => {
      const payload: RevenueCatWebhookPayload = {
        api_version: "1.0",
        event: {
          id: "evt_1",
          type: "INITIAL_PURCHASE",
          app_user_id: "$RCAnonymousID:1234567890abcdef",
          product_id: "seafarer_pro_monthly",
          event_timestamp_ms: 1700000000000,
        },
      };

      const req = {
        method: "POST",
        headers: { authorization: secretKey },
        body: payload,
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockBatch.commit).not.toHaveBeenCalled();
    });
  });

  describe("Purchase Events", () => {
    test("handles INITIAL_PURCHASE and marks user as premium", async () => {
      const futureExpiry = Date.now() + 30 * 24 * 60 * 60 * 1000;
      const payload: RevenueCatWebhookPayload = {
        api_version: "1.0",
        event: {
          id: "evt_purchase_1",
          type: "INITIAL_PURCHASE",
          app_user_id: "firebase_user_abc",
          product_id: "seafarer_pro_monthly",
          event_timestamp_ms: 1700000000000,
          expiration_at_ms: futureExpiry,
        },
      };

      const req = {
        method: "POST",
        headers: { authorization: secretKey },
        body: payload,
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockBatch.set).toHaveBeenCalledTimes(2); // users/{uid} and profiles/{uid}
      const setCallArgs = mockBatch.set.mock.calls[0][1];
      expect(setCallArgs.isPremium).toBe(true);
      expect(setCallArgs.premiumProductId).toBe("seafarer_pro_monthly");
      expect(setCallArgs.premiumExpiresAt).toBeInstanceOf(admin.firestore.Timestamp);
      expect(setCallArgs.premiumUpdatedAt).toBeInstanceOf(admin.firestore.Timestamp);
      expect(mockBatch.commit).toHaveBeenCalled();
    });

    test("handles RENEWAL and updates expiration and premiumUpdatedAt", async () => {
      const futureExpiry = Date.now() + 60 * 24 * 60 * 60 * 1000;
      const payload: RevenueCatWebhookPayload = {
        api_version: "1.0",
        event: {
          id: "evt_renewal_1",
          type: "RENEWAL",
          app_user_id: "firebase_user_abc",
          product_id: "seafarer_pro_yearly",
          event_timestamp_ms: 1700005000000,
          expiration_at_ms: futureExpiry,
        },
      };

      const req = {
        method: "POST",
        headers: { authorization: secretKey },
        body: payload,
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      const setCallArgs = mockBatch.set.mock.calls[0][1];
      expect(setCallArgs.isPremium).toBe(true);
      expect(setCallArgs.premiumProductId).toBe("seafarer_pro_yearly");
      expect(mockBatch.commit).toHaveBeenCalled();
    });
  });

  describe("Expiration and Refund Events", () => {
    test("handles EXPIRATION and revokes premium access", async () => {
      const payload: RevenueCatWebhookPayload = {
        api_version: "1.0",
        event: {
          id: "evt_exp_1",
          type: "EXPIRATION",
          app_user_id: "firebase_user_abc",
          product_id: "seafarer_pro_monthly",
          event_timestamp_ms: 1700010000000,
          expiration_at_ms: 1700010000000,
        },
      };

      const req = {
        method: "POST",
        headers: { authorization: secretKey },
        body: payload,
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      const setCallArgs = mockBatch.set.mock.calls[0][1];
      expect(setCallArgs.isPremium).toBe(false);
      expect(mockBatch.commit).toHaveBeenCalled();
    });

    test("handles REFUND and immediately revokes premium access", async () => {
      const payload: RevenueCatWebhookPayload = {
        api_version: "1.0",
        event: {
          id: "evt_ref_1",
          type: "REFUND",
          app_user_id: "firebase_user_abc",
          product_id: "seafarer_pro_monthly",
          event_timestamp_ms: 1700020000000,
        },
      };

      const req = {
        method: "POST",
        headers: { authorization: secretKey },
        body: payload,
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      const setCallArgs = mockBatch.set.mock.calls[0][1];
      expect(setCallArgs.isPremium).toBe(false);
      expect(mockBatch.commit).toHaveBeenCalled();
    });
  });

  describe("Idempotency and Out-of-Order Events", () => {
    test("ignores out-of-order events where event timestamp <= stored premiumUpdatedAt", async () => {
      const storedTimeMs = 1700050000000;
      mockUserDocData = {
        isPremium: true,
        premiumUpdatedAt: admin.firestore.Timestamp.fromMillis(storedTimeMs),
      };

      const payload: RevenueCatWebhookPayload = {
        api_version: "1.0",
        event: {
          id: "evt_old_1",
          type: "CANCELLATION",
          app_user_id: "firebase_user_abc",
          product_id: "seafarer_pro_monthly",
          event_timestamp_ms: storedTimeMs - 5000, // Older event arriving late
        },
      };

      const req = {
        method: "POST",
        headers: { authorization: secretKey },
        body: payload,
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      // Batch commit should NOT have been called because event was discarded as outdated
      expect(mockBatch.commit).not.toHaveBeenCalled();
    });

    test("processes newer event when event timestamp > stored premiumUpdatedAt", async () => {
      const storedTimeMs = 1700050000000;
      mockUserDocData = {
        isPremium: true,
        premiumUpdatedAt: admin.firestore.Timestamp.fromMillis(storedTimeMs),
      };

      const payload: RevenueCatWebhookPayload = {
        api_version: "1.0",
        event: {
          id: "evt_new_1",
          type: "EXPIRATION",
          app_user_id: "firebase_user_abc",
          product_id: "seafarer_pro_monthly",
          event_timestamp_ms: storedTimeMs + 5000, // Newer event
        },
      };

      const req = {
        method: "POST",
        headers: { authorization: secretKey },
        body: payload,
      };

      await processWebhook(req, mockRes, mockDb, secretKey);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockBatch.commit).toHaveBeenCalled();
      const setCallArgs = mockBatch.set.mock.calls[0][1];
      expect(setCallArgs.isPremium).toBe(false);
    });
  });
});
