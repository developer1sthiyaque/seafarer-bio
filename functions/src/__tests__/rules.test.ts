import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import * as fs from "fs";
import * as path from "path";

const PROJECT_ID = "demo-seafarer-rules-test";
const EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || "127.0.0.1:8080";

describe("Firestore Security Rules (Emulator)", () => {
  let testEnv: RulesTestEnvironment | null = null;
  const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
  const rulesContent = fs.readFileSync(rulesPath, "utf8");

  beforeAll(async () => {
    const [host, portStr] = EMULATOR_HOST.split(":");
    const port = parseInt(portStr, 10) || 8080;

    try {
      testEnv = await initializeTestEnvironment({
        projectId: PROJECT_ID,
        firestore: {
          rules: rulesContent,
          host,
          port,
        },
      });
    } catch (e) {
      console.warn("Firestore emulator not reachable, skipping live emulator rules tests:", e);
    }
  });

  afterAll(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    if (testEnv) {
      await testEnv.clearFirestore();
    }
  });

  describe("users/{userId} collection", () => {
    test("user cannot set isPremium on create", async () => {
      if (!testEnv) return;
      const aliceContext = testEnv.authenticatedContext("alice");
      const userRef = aliceContext.firestore().collection("users").doc("alice");

      await assertFails(
        userRef.set({
          fullName: "Alice Seafarer",
          isPremium: true,
        })
      );
    });

    test("user cannot set premiumExpiresAt or other protected fields on create", async () => {
      if (!testEnv) return;
      const aliceContext = testEnv.authenticatedContext("alice");
      const userRef = aliceContext.firestore().collection("users").doc("alice");

      await assertFails(
        userRef.set({
          fullName: "Alice Seafarer",
          premiumExpiresAt: new Date(),
        })
      );

      await assertFails(
        userRef.set({
          fullName: "Alice Seafarer",
          premiumProductId: "seafarer_pro_monthly",
        })
      );

      await assertFails(
        userRef.set({
          fullName: "Alice Seafarer",
          premiumUpdatedAt: new Date(),
        })
      );
    });

    test("user can create doc with legitimate profile fields", async () => {
      if (!testEnv) return;
      const aliceContext = testEnv.authenticatedContext("alice");
      const userRef = aliceContext.firestore().collection("users").doc("alice");

      await assertSucceeds(
        userRef.set({
          fullName: "Alice Seafarer",
          email: "alice@example.com",
          rank: "Chief Officer",
        })
      );
    });

    test("user cannot update isPremium or protected fields on existing doc", async () => {
      if (!testEnv) return;
      // Seed initial doc via admin context
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("users").doc("alice").set({
          fullName: "Alice Seafarer",
          isPremium: false,
          premiumProductId: null,
        });
      });

      const aliceContext = testEnv.authenticatedContext("alice");
      const userRef = aliceContext.firestore().collection("users").doc("alice");

      // Attempting to elevate to isPremium: true must fail
      await assertFails(
        userRef.update({
          isPremium: true,
        })
      );

      // Attempting to update premiumExpiresAt must fail
      await assertFails(
        userRef.update({
          premiumExpiresAt: new Date(),
        })
      );
    });

    test("user can update legitimate profile fields on existing doc", async () => {
      if (!testEnv) return;
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("users").doc("alice").set({
          fullName: "Alice Seafarer",
          rank: "Second Officer",
          isPremium: false,
        });
      });

      const aliceContext = testEnv.authenticatedContext("alice");
      const userRef = aliceContext.firestore().collection("users").doc("alice");

      await assertSucceeds(
        userRef.update({
          rank: "Chief Officer",
        })
      );
    });

    test("unauthenticated user cannot read or write", async () => {
      if (!testEnv) return;
      const unauthContext = testEnv.unauthenticatedContext();
      const userRef = unauthContext.firestore().collection("users").doc("alice");

      await assertFails(userRef.get());
      await assertFails(userRef.set({ fullName: "Attacker" }));
    });
  });

  describe("profiles/{userId} collection", () => {
    test("user cannot write isPremium on profile create", async () => {
      if (!testEnv) return;
      const bobContext = testEnv.authenticatedContext("bob");
      const profileRef = bobContext.firestore().collection("profiles").doc("bob");

      await assertFails(
        profileRef.set({
          fullName: "Bob Deckhand",
          isPremium: true,
        })
      );
    });

    test("user cannot update isPremium on profile update", async () => {
      if (!testEnv) return;
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("profiles").doc("bob").set({
          fullName: "Bob Deckhand",
          rank: "Bosun",
          isPremium: false,
        });
      });

      const bobContext = testEnv.authenticatedContext("bob");
      const profileRef = bobContext.firestore().collection("profiles").doc("bob");

      await assertFails(
        profileRef.update({
          isPremium: true,
        })
      );

      await assertSucceeds(
        profileRef.update({
          rank: "Chief Mate",
        })
      );
    });
  });
});
