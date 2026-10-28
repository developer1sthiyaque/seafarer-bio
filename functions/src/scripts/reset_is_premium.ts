import * as admin from "firebase-admin";

// Usage:
//   Dry run: npx ts-node src/scripts/reset_is_premium.ts
//   Execute: npx ts-node src/scripts/reset_is_premium.ts --execute

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function resetPremiumFlags() {
  const isExecute = process.argv.includes("--execute");

  console.log("=================================================");
  console.log(`Starting isPremium reset migration [Mode: ${isExecute ? "EXECUTE" : "DRY RUN"}]`);
  console.log("=================================================");

  const collections = ["users", "profiles"];
  let totalResetCount = 0;

  for (const col of collections) {
    console.log(`\nScanning collection '${col}'...`);
    const snapshot = await db.collection(col).where("isPremium", "==", true).get();

    console.log(`Found ${snapshot.size} documents in '${col}' with isPremium == true.`);

    if (snapshot.empty) continue;

    let batch = db.batch();
    let count = 0;

    for (const doc of snapshot.docs) {
      console.log(`  - ${isExecute ? "Resetting" : "Would reset"} document ${col}/${doc.id}`);

      if (isExecute) {
        batch.update(doc.ref, {
          isPremium: false,
          premiumResetAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        count++;

        if (count >= 400) {
          await batch.commit();
          batch = db.batch();
          count = 0;
        }
      }
      totalResetCount++;
    }

    if (isExecute && count > 0) {
      await batch.commit();
    }
  }

  console.log("\n=================================================");
  if (isExecute) {
    console.log(`Migration Complete: Successfully reset ${totalResetCount} records to isPremium: false.`);
  } else {
    console.log(`Dry Run Complete: ${totalResetCount} records identified for reset.`);
    console.log("To apply changes, run with: --execute");
  }
  console.log("=================================================");
}

resetPremiumFlags()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Migration failed:", err);
    process.exit(1);
  });
