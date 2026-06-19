const { Sequelize } = require("sequelize");

const {
  DB_NAME,
  DB_USERNAME,
  DB_PASSWORD,
  DB_HOST,
  DB_DIALECT,
  DB_PORT,
  SSL,
} = require("../env");

const shouldUseSsl = (() => {
  const sslFlag = String(SSL || "")
    .trim()
    .toLowerCase();

  if (["true", "1", "yes", "require"].includes(sslFlag)) {
    return true;
  }

  if (["false", "0", "no", "disable"].includes(sslFlag)) {
    return false;
  }

  return !["localhost", "127.0.0.1", "::1"].includes(DB_HOST);
})();

const postgres = new Sequelize(DB_NAME, DB_USERNAME, DB_PASSWORD, {
  host: DB_HOST,
  dialect: DB_DIALECT || "postgres",
  port: DB_PORT,
  pool: {
    max: 50,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
  logging: false,
  timezone: "+05:45",
  dialectOptions: {
    ssl: shouldUseSsl ? { require: true, rejectUnauthorized: false } : false,
  },
});

const testPostgresConnection = async () => {
  try {
    await postgres.authenticate();
    const { applyAssociations } = require("../../model/association");

    applyAssociations();
    await postgres.sync({ alter: true });

    console.info(
      "\x1b[38;5;34m 👾 Postgres Database Synced Successfully. \x1b[0m",
    );
    console.info("\x1b[38;5;34m ✅ Connected to Postgres Database... \x1b[0m");
  } catch (error) {
    if (String(error?.message || "").includes("no encryption")) {
      console.error("❌ Postgres requires SSL. Set SSL=true in server/.env");
    }
    console.error("❌ Unable to connect to Postgres:", error);
  }
};

module.exports = { postgres, testPostgresConnection };
