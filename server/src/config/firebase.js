const admin = require("firebase-admin");

const initFirebase = () => {
  if (admin.apps.length > 0) return;

  try {
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;

    if (!serviceAccountJson) {
      console.warn(
        "FIREBASE_SERVICE_ACCOUNT not found in environment variables. Firebase Admin not initialized."
      );
      return;
    }

    let raw = serviceAccountJson.trim();
    if ((raw.startsWith("'") && raw.endsWith("'")) || (raw.startsWith('"') && raw.endsWith('"'))) {
      raw = raw.slice(1, -1);
    }

    let serviceAccount;
    try {
      serviceAccount = JSON.parse(raw);
    } catch (e) {
      console.error("Failed to parse FIREBASE_SERVICE_ACCOUNT JSON:", e.message);
      return;
    }
    if (
      serviceAccount &&
      typeof serviceAccount.private_key === "string" &&
      serviceAccount.private_key.includes("\\n")
    ) {
      serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");
    }

    
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log("Firebase Admin initialized successfully");
  } catch (error) {
    console.error("Failed to initialize Firebase Admin:", error.message);
  }
};

module.exports = { admin, initFirebase };
